# Troubleshooting Guide

Common issues and solutions for the OurFileServer.

## Table of Contents

- [Container Issues](#container-issues)
- [Network Connectivity](#network-connectivity)
- [Storage Problems](#storage-problems)
- [Performance Issues](#performance-issues)
- [WSL2 Specific Issues](#wsl2-specific-issues)

## Container Issues

### Container Won't Start

**Symptoms:**
- Container shows "Restarting" status
- `docker compose ps` shows unhealthy container

**Diagnosis:**
```bash
# Check container logs
docker compose logs filebrowser

# Check container status
docker compose ps
```

**Common Causes & Solutions:**

1. **Database Permission Issues**
   ```
   Error: open /database.db: permission denied
   ```
   **Solution:** Remove database volume mount or fix permissions
   ```bash
   docker compose down
   # Edit docker-compose.yml to remove database volume
   docker compose up -d
   ```

2. **Port Already in Use**
   ```
   Error: bind: address already in use
   ```
   **Solution:** Check what's using port 8080
   ```bash
   netstat -tlnp | grep :8080
   # Kill the process or change port in docker-compose.yml
   ```

3. **Storage Mount Issues**
   ```
   Error: mount: /mnt/s/fileserver: No such file or directory
   ```
   **Solution:** Check mount point exists
   ```bash
   ls -la /mnt/s/fileserver/
   # If missing, recreate mount or fix path
   ```

### Container Keeps Restarting

**Symptoms:**
- Container status shows "Restarting (1)"
- Logs show repeated errors

**Diagnosis:**
```bash
# Check logs for error patterns
docker compose logs filebrowser | tail -20

# Check container health
docker inspect filebrowser | grep -A 5 "Health"
```

**Solutions:**

1. **Database Issues**
   - Remove database volume mount
   - Use `FB_NOAUTH=true` for simple setup

2. **Configuration Issues**
   - Check environment variables in docker-compose.yml
   - Verify volume mount paths

3. **Resource Issues**
   - Check available disk space
   - Check memory usage

## Network Connectivity

### Can't Access from Other Devices

**Symptoms:**
- Works on localhost but not from phone/Steam Deck
- "Connection refused" or timeout errors

**Diagnosis:**
```bash
# Check WSL IP
hostname -I

# Check if port is listening
netstat -tlnp | grep :8080

# Test local access
curl -I http://localhost:8080
```

**Solutions:**

1. **Windows Port Forwarding Not Set Up**
   ```powershell
   # Run in Windows PowerShell as Administrator
   netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=8080 connectaddress=192.168.147.153 connectport=8080
   New-NetFirewallRule -DisplayName "WSL File Server" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8080
   ```

2. **Windows Firewall Blocking**
   ```powershell
   # Check firewall rules
   Get-NetFirewallRule -DisplayName "WSL File Server"
   
   # If missing, create rule
   New-NetFirewallRule -DisplayName "WSL File Server" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8080
   ```

3. **Wrong IP Address**
   - Get Windows IP: `ipconfig` in Windows Command Prompt
   - Use Windows IP, not WSL IP for network access

### "Connection Reset by Peer" Error

**Symptoms:**
- Browser shows connection reset
- curl fails with "Connection reset by peer"

**Causes & Solutions:**

1. **Container Not Running**
   ```bash
   docker compose ps
   # If not running, start it
   docker compose up -d
   ```

2. **Port Forwarding Issues**
   ```powershell
   # Check port forwarding rules
   netsh interface portproxy show all
   
   # Recreate if missing
   netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=8080 connectaddress=192.168.147.153 connectport=8080
   ```

3. **WSL Network Issues**
   ```bash
   # Restart WSL
   wsl --shutdown
   # Then restart WSL and try again
   ```

## Storage Problems

### Can't Access Files

**Symptoms:**
- Empty file browser
- "Permission denied" errors
- Files not showing up

**Diagnosis:**
```bash
# Check mount point
ls -la /mnt/s/fileserver/

# Check permissions
ls -ld /mnt/s/fileserver/

# Check if files exist
find /mnt/s/fileserver -type f | head -10
```

**Solutions:**

1. **Mount Point Issues**
   ```bash
   # Check if drive is mounted
   mount | grep /mnt/s
   
   # If not mounted, mount it
   sudo mkdir -p /mnt/s/fileserver
   sudo mount -t drvfs S: /mnt/s
   ```

2. **Permission Issues**
   ```bash
   # Fix permissions (if possible)
   sudo chmod -R 755 /mnt/s/fileserver/
   sudo chown -R grimmjones:grimmjones /mnt/s/fileserver/
   ```

3. **Drive Not Connected**
   - Check if external drive is connected
   - Verify drive letter in Windows
   - Reconnect drive if necessary

### Low Disk Space

**Symptoms:**
- Uploads fail
- "No space left on device" errors

**Diagnosis:**
```bash
# Check disk usage
df -h /mnt/s/fileserver

# Find large files
find /mnt/s/fileserver -type f -size +100M -exec ls -lh {} \;
```

**Solutions:**

1. **Clean Temporary Files**
   ```bash
   find /mnt/s/fileserver/temp -type f -mtime +7 -delete
   ```

2. **Archive Old Files**
   ```bash
   # Create archive of old files
   tar -czf /mnt/s/fileserver/backups/old-files-$(date +%Y%m%d).tar.gz /mnt/s/fileserver/old-directory
   ```

3. **Expand Storage**
   - Add more space to external drive
   - Use disk cleanup tools in Windows

## Performance Issues

### Slow File Transfers

**Symptoms:**
- Uploads/downloads are very slow
- Timeouts during transfers

**Diagnosis:**
```bash
# Check network speed
speedtest-cli

# Check system resources
htop
docker stats filebrowser
```

**Solutions:**

1. **Network Issues**
   - Use wired connection instead of WiFi
   - Check for network congestion
   - Restart router if needed

2. **Resource Constraints**
   - Close other applications
   - Increase Docker memory limits
   - Check for disk I/O bottlenecks

3. **File Size Issues**
   - Compress large files before transfer
   - Transfer files in smaller batches
   - Use file compression tools

### High CPU/Memory Usage

**Symptoms:**
- System becomes slow
- Container uses excessive resources

**Diagnosis:**
```bash
# Check container resources
docker stats filebrowser

# Check system resources
htop
free -h
```

**Solutions:**

1. **Container Limits**
   ```yaml
   # Add to docker-compose.yml
   deploy:
     resources:
       limits:
         memory: 512M
         cpus: '0.5'
   ```

2. **System Optimization**
   - Close unnecessary applications
   - Restart WSL if needed
   - Check for background processes

## WSL2 Specific Issues

### WSL Network Changes

**Symptoms:**
- IP address changes after restart
- Network access stops working

**Solution:**
```bash
# Get new WSL IP
hostname -I

# Update Windows port forwarding with new IP
# Run in Windows PowerShell as Administrator:
netsh interface portproxy delete v4tov4 listenaddress=0.0.0.0 listenport=8080
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=8080 connectaddress=NEW_WSL_IP connectport=8080
```

### Docker Context Issues

**Symptoms:**
- "Cannot connect to Docker daemon"
- "Protocol not available" errors

**Solutions:**

1. **Check Docker Context**
   ```bash
   docker context ls
   docker context use default
   ```

2. **Restart Docker**
   ```bash
   # In WSL
   sudo service docker restart
   
   # Or restart Docker Desktop in Windows
   ```

3. **Use Windows Docker**
   ```bash
   # Switch to Windows Docker context
   docker context use desktop-windows
   ```

### File Permission Issues

**Symptoms:**
- Can't create files in mounted directories
- Permission denied errors

**Solutions:**

1. **Fix WSL Mount Permissions**
   ```bash
   # Add to /etc/wsl.conf
   [automount]
   enabled = true
   options = "metadata,umask=022,fmask=111"
   ```

2. **Restart WSL**
   ```bash
   wsl --shutdown
   # Then restart WSL
   ```

## Emergency Recovery

### Complete Reset

If everything is broken:

1. **Stop everything**
   ```bash
   docker compose down
   docker system prune -a
   ```

2. **Restart WSL**
   ```bash
   wsl --shutdown
   # Restart WSL
   ```

3. **Recreate setup**
   ```bash
   cd /home/grimmjones/Projects/OurFileServer
   docker compose up -d
   ```

4. **Reconfigure Windows networking**
   ```powershell
   # Get new WSL IP
   wsl hostname -I
   
   # Recreate port forwarding
   netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=8080 connectaddress=NEW_IP connectport=8080
   ```

### Data Recovery

If files are missing:

1. **Check Windows drive directly**
   - Open File Explorer
   - Navigate to S: drive
   - Check if files exist

2. **Check WSL mount**
   ```bash
   ls -la /mnt/s/fileserver/
   ```

3. **Remount if necessary**
   ```bash
   sudo umount /mnt/s
   sudo mount -t drvfs S: /mnt/s
   ```

## Getting Help

If you can't resolve an issue:

1. **Check logs first**
   ```bash
   docker compose logs filebrowser
   ```

2. **Document the problem**
   - What were you trying to do?
   - What error messages did you see?
   - What troubleshooting steps did you try?

3. **Check system status**
   ```bash
   docker compose ps
   hostname -I
   df -h /mnt/s/fileserver
   ```

4. **Try the emergency recovery steps above**
