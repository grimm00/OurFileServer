# Server Administration Guide

Complete guide for managing and maintaining the OurFileServer.

## Table of Contents

- [Daily Operations](#daily-operations)
- [Container Management](#container-management)
- [Storage Management](#storage-management)
- [User Management](#user-management)
- [Monitoring and Logs](#monitoring-and-logs)
- [Maintenance Tasks](#maintenance-tasks)

## Daily Operations

### Starting the Server

```bash
cd /home/grimmjones/Projects/OurFileServer
docker compose up -d
```

### Stopping the Server

```bash
docker compose down
```

### Checking Server Status

```bash
# Check container status
docker compose ps

# Check if service is responding
curl -I http://localhost:8080

# Check disk usage
df -h /mnt/s/fileserver
```

## Container Management

### Viewing Logs

```bash
# View recent logs
docker compose logs filebrowser

# Follow logs in real-time
docker compose logs -f filebrowser

# View last 50 lines
docker compose logs --tail=50 filebrowser
```

### Restarting the Container

```bash
# Restart just the filebrowser service
docker compose restart filebrowser

# Full restart (stop and start)
docker compose down && docker compose up -d
```

### Updating Filebrowser

```bash
# Pull latest image
docker compose pull

# Restart with new image
docker compose up -d
```

## Storage Management

### Checking Storage Usage

```bash
# Check overall disk usage
df -h /mnt/s/fileserver

# Check directory sizes
du -sh /mnt/s/fileserver/*

# Find largest files
find /mnt/s/fileserver -type f -size +100M -exec ls -lh {} \;
```

### Cleaning Up Storage

```bash
# Clean temporary files
find /mnt/s/fileserver/temp -type f -mtime +7 -delete

# Remove empty directories
find /mnt/s/fileserver -type d -empty -delete
```

### Adding New Directories

```bash
# Create new directory structure
mkdir -p /mnt/s/fileserver/projects
mkdir -p /mnt/s/fileserver/backups
mkdir -p /mnt/s/fileserver/shared

# Set appropriate permissions
chmod 755 /mnt/s/fileserver/projects
```

## User Management

### Current Configuration

The server is currently configured with **no authentication** (`FB_NOAUTH=true`). This means:

- ✅ Anyone on the network can access files
- ✅ No login required
- ✅ Full read/write access to all files
- ⚠️ **Security Risk**: Only suitable for trusted home networks

### Enabling Authentication (Optional)

If you want to add authentication later:

1. **Edit docker-compose.yml**:
   ```yaml
   environment:
     - FB_ROOT=/srv
     # Remove or comment out: - FB_NOAUTH=true
   ```

2. **Restart the container**:
   ```bash
   docker compose down && docker compose up -d
   ```

3. **Create admin user**:
   ```bash
   docker compose exec filebrowser filebrowser users add admin yourpassword --perm.admin
   ```

## Monitoring and Logs

### Health Checks

```bash
# Check if container is healthy
docker compose ps

# Test web interface
curl -s http://localhost:8080 | grep -i "filebrowser"

# Check network connectivity
netstat -tlnp | grep :8080
```

### Log Analysis

```bash
# Check for errors
docker compose logs filebrowser | grep -i error

# Check for warnings
docker compose logs filebrowser | grep -i warning

# Monitor access logs
docker compose logs -f filebrowser | grep -E "(GET|POST|PUT|DELETE)"
```

## Maintenance Tasks

### Weekly Tasks

- [ ] Check disk usage: `df -h /mnt/s/fileserver`
- [ ] Review logs for errors: `docker compose logs filebrowser | grep -i error`
- [ ] Clean temporary files: `find /mnt/s/fileserver/temp -type f -mtime +7 -delete`
- [ ] Test network access from different devices

### Monthly Tasks

- [ ] Update Filebrowser: `docker compose pull && docker compose up -d`
- [ ] Review and organize file structure
- [ ] Check for large files that might need archiving
- [ ] Verify backup procedures (if implemented)

### Troubleshooting Common Issues

See [Troubleshooting Guide](./troubleshooting.md) for detailed solutions to common problems.

## Performance Optimization

### Container Resources

Monitor resource usage:

```bash
# Check container resource usage
docker stats filebrowser

# Check system resources
htop
```

### File Transfer Optimization

- Use wired connections for large file transfers
- Consider file compression for large archives
- Monitor network bandwidth during transfers

## Security Considerations

### Current Security Level: **Low** (Home Network Only)

- No authentication required
- Accessible to anyone on the network
- Suitable only for trusted home environments

### If Moving to Internet Access

1. **Enable authentication**
2. **Use HTTPS/TLS encryption**
3. **Implement firewall rules**
4. **Regular security updates**
5. **Monitor access logs**

See [Security Guide](./security.md) for detailed security recommendations.
