# Network Setup Guide

Complete guide for configuring network access to the OurFileServer from WSL2.

## Overview

The file server runs in WSL2 but needs to be accessible from other devices on your home network. This requires Windows port forwarding to bridge the WSL2 network with your home network.

## Network Architecture

```
Home Network (192.168.50.0/24)
    ↓
Windows Host (192.168.50.X)
    ↓ (Port Forwarding)
WSL2 Network (192.168.147.0/24)
    ↓
Filebrowser Container (192.168.147.153:8080)
```

## Prerequisites

- Windows 10/11 with WSL2
- Docker Desktop or Docker in WSL2
- Administrator access to Windows
- Home network access

## Step-by-Step Setup

### 1. Get Network Information

**Get WSL2 IP:**
```bash
# In WSL2
hostname -I
# Example output: 192.168.147.153
```

**Get Windows IP:**
```cmd
# In Windows Command Prompt
ipconfig
# Look for your network adapter (Ethernet/Wi-Fi)
# Example: 192.168.50.123
```

### 2. Configure Windows Port Forwarding

**Run as Administrator in Windows PowerShell:**

```powershell
# Create port forwarding rule
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=8080 connectaddress=192.168.147.153 connectport=8080

# Add Windows Firewall rule
New-NetFirewallRule -DisplayName "WSL File Server" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8080

# Verify the rules were created
netsh interface portproxy show all
Get-NetFirewallRule -DisplayName "WSL File Server"
```

### 3. Test Network Access

**From WSL2 (should work):**
```bash
curl -I http://localhost:8080
curl -I http://192.168.147.153:8080
```

**From Windows (should work):**
```cmd
curl -I http://localhost:8080
curl -I http://192.168.50.123:8080
```

**From other devices (should work):**
- Phone: `http://192.168.50.123:8080`
- Steam Deck: `http://192.168.50.123:8080`
- Other computers: `http://192.168.50.123:8080`

## Troubleshooting Network Issues

### Port Forwarding Not Working

**Check if rules exist:**
```powershell
netsh interface portproxy show all
```

**If missing, recreate:**
```powershell
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=8080 connectaddress=192.168.147.153 connectport=8080
```

### Firewall Blocking Access

**Check firewall rules:**
```powershell
Get-NetFirewallRule -DisplayName "WSL File Server"
```

**If missing, create:**
```powershell
New-NetFirewallRule -DisplayName "WSL File Server" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8080
```

### WSL IP Changed

**Get new WSL IP:**
```bash
hostname -I
```

**Update port forwarding:**
```powershell
# Remove old rule
netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=8080

# Add new rule with updated IP
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=8080 connectaddress=NEW_WSL_IP connectport=8080
```

### Container Not Accessible

**Check container status:**
```bash
docker compose ps
```

**Check if port is listening:**
```bash
netstat -tlnp | grep :8080
```

**Test local access:**
```bash
curl -I http://localhost:8080
```

## Network Security Considerations

### Current Setup (Home Network Only)

- ✅ Accessible from home network only
- ✅ No authentication required
- ✅ Suitable for trusted home environment
- ⚠️ Not suitable for internet access

### If Moving to Internet Access

1. **Enable Authentication**
   ```yaml
   # Remove FB_NOAUTH from docker-compose.yml
   environment:
     - FB_ROOT=/srv
   ```

2. **Use HTTPS/TLS**
   - Set up reverse proxy (nginx/traefik)
   - Obtain SSL certificates
   - Configure HTTPS redirect

3. **Implement Firewall Rules**
   - Restrict access to specific IPs
   - Use VPN for remote access
   - Monitor access logs

4. **Regular Security Updates**
   - Keep Filebrowser updated
   - Monitor security advisories
   - Regular backup procedures

## Advanced Network Configuration

### Custom Port

If you want to use a different port:

1. **Update docker-compose.yml:**
   ```yaml
   ports:
     - "9090:80"  # Change 8080 to 9090
   ```

2. **Update Windows port forwarding:**
   ```powershell
   netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=9090 connectaddress=192.168.147.153 connectport=9090
   ```

3. **Update firewall rule:**
   ```powershell
   New-NetFirewallRule -DisplayName "WSL File Server" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9090
   ```

### Multiple Services

If you want to run multiple services:

1. **Use different ports for each service**
2. **Create separate port forwarding rules**
3. **Use reverse proxy for unified access**

### Static IP for WSL2

To prevent IP changes:

1. **Configure WSL2 with static IP**
2. **Update Windows hosts file**
3. **Use consistent port forwarding rules**

## Monitoring Network Access

### Check Active Connections

```bash
# Check who's connected
netstat -an | grep :8080

# Monitor connections in real-time
watch -n 1 'netstat -an | grep :8080'
```

### Log Network Access

```bash
# Monitor Filebrowser logs for access
docker compose logs -f filebrowser | grep -E "(GET|POST|PUT|DELETE)"
```

### Test from Different Devices

**Regular testing checklist:**
- [ ] Phone browser access
- [ ] Steam Deck browser access
- [ ] Other computer access
- [ ] File upload/download test
- [ ] Large file transfer test

## Network Performance Optimization

### Wired vs Wireless

- **Use wired connection** for best performance
- **WiFi 6** for good wireless performance
- **Avoid 2.4GHz** for large file transfers

### Bandwidth Considerations

- **Monitor network usage** during transfers
- **Schedule large transfers** during off-peak hours
- **Use compression** for large files

### Local Network Optimization

- **Use Gigabit Ethernet** when possible
- **Optimize router settings** for local traffic
- **Consider network segmentation** for security

## Backup Network Configuration

### Export Current Settings

```powershell
# Export port forwarding rules
netsh interface portproxy show all > portproxy-backup.txt

# Export firewall rules
Get-NetFirewallRule -DisplayName "WSL File Server" | Export-Clixml firewall-backup.xml
```

### Restore Settings

```powershell
# Restore port forwarding (manual recreation)
# Restore firewall rules
Import-Clixml firewall-backup.xml | New-NetFirewallRule
```

## Troubleshooting Checklist

When network access isn't working:

1. **Check WSL2 IP:** `hostname -I`
2. **Check Windows IP:** `ipconfig`
3. **Verify port forwarding:** `netsh interface portproxy show all`
4. **Check firewall rules:** `Get-NetFirewallRule -DisplayName "WSL File Server"`
5. **Test container:** `docker compose ps`
6. **Test local access:** `curl -I http://localhost:8080`
7. **Test network access:** `curl -I http://192.168.50.X:8080`
8. **Check router settings** (if still not working)
9. **Restart WSL2** if IP changed
10. **Recreate port forwarding** with new IP
