# API Management Operations

**Purpose:** Operations guide for managing API access and authentication  
**Status:** Complete  
**Last Updated:** 2025-01-22  
**Priority:** High

---

## 📋 Overview

This guide covers the operational aspects of managing the file server API access, including user management, token operations, and troubleshooting.

---

## 👥 User Management

### Current Setup

**Single Admin Account:**
- **Username:** `admin`
- **Password:** `yourpassword`
- **Permissions:** Full access (admin, execute, create, rename, modify, delete, share, download, api)

### Changing the Password

**Command:**
```bash
docker compose exec filebrowser filebrowser users update admin --password [new_password]
```

**Example:**
```bash
docker compose exec filebrowser filebrowser users update admin --password mynewpassword123
```

### Adding Additional Users (Future)

If you need separate user accounts in the future:

```bash
# Add regular user
docker compose exec filebrowser filebrowser users add username password

# Add user with specific permissions
docker compose exec filebrowser filebrowser users add username password --perm.download --perm.create
```

---

## 🔑 Token Management

### Token Generation

**Programmatic (Recommended):**
```bash
# Get JWT token
curl -X POST -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"yourpassword"}' \
  http://[your-ip]:8080/api/login
```

**Token Properties:**
- **Expiration:** 1 year (8760h)
- **Format:** JWT (JSON Web Token)
- **Usage:** Include in `X-Auth` header for API requests

### Token Validation

**Test if token is valid:**
```bash
curl -H "X-Auth: [TOKEN]" http://[your-ip]:8080/api/resources
```

**Expected responses:**
- **200 OK:** Token is valid
- **401 Unauthorized:** Token is invalid or expired

### Token Security

**Best Practices:**
- Store tokens securely in applications
- Use environment variables for token storage
- Don't hardcode tokens in source code
- Rotate tokens periodically if needed

---

## 🔧 Configuration Management

### Current Configuration

**Docker Compose:**
```yaml
services:
  filebrowser:
    image: filebrowser/filebrowser:latest
    container_name: filebrowser
    ports:
      - "8080:80"
    volumes:
      - /mnt/s/fileserver:/srv
      - ./settings-minimal.json:/config/settings.json
      - ./data:/database
    restart: unless-stopped
    environment:
      - FB_ROOT=/srv
      - FB_JWT_SIGNING_KEY=qsgiee3hPYlIWyo-Kmh-6mQqIutmkjQ5xAbTW5vDR6g
      - FB_ADDRESS=0.0.0.0
      - FB_PORT=80
      - FB_DATABASE=/database/filebrowser.db
```

**Settings Configuration:**
- **Authentication:** JWT-based
- **Token Expiry:** 8760h (1 year)
- **API Permission:** Enabled
- **User Registration:** Disabled

### Modifying Configuration

**To change token expiration:**
1. Edit `settings-minimal.json`
2. Update `"expiry": "8760h"` to desired value
3. Restart container: `docker compose restart`

**To disable API access:**
1. Edit `settings-minimal.json`
2. Change `"api": true` to `"api": false`
3. Restart container: `docker compose restart`

---

## 📊 Monitoring and Logs

### Container Status

**Check if running:**
```bash
docker compose ps
```

**Expected output:**
```
NAME          IMAGE                            COMMAND              SERVICE       CREATED         STATUS                   PORTS
filebrowser   filebrowser/filebrowser:latest   "tini -- /init.sh"   filebrowser   2 minutes ago   Up 2 minutes (healthy)   0.0.0.0:8080->80/tcp
```

### View Logs

**Recent logs:**
```bash
docker compose logs filebrowser --tail 20
```

**Follow logs:**
```bash
docker compose logs filebrowser -f
```

### Health Checks

**Test web interface:**
```bash
curl -I http://[your-ip]:8080/
```

**Test API access:**
```bash
curl -H "X-Auth: [TOKEN]" http://[your-ip]:8080/api/resources
```

---

## 🆘 Troubleshooting

### Common Issues

**Container won't start:**
1. Check logs: `docker compose logs filebrowser`
2. Verify configuration files exist
3. Check disk space: `df -h`
4. Restart Docker: `sudo systemctl restart docker`

**API returns 401 Unauthorized:**
1. Verify token is correct
2. Check if token has expired
3. Ensure `"api": true` in settings
4. Test with fresh token

**Web interface not accessible:**
1. Check container status: `docker compose ps`
2. Verify port mapping: `netstat -tlnp | grep 8080`
3. Test local access: `curl -I http://localhost:8080/`
4. Check firewall rules

**Database errors:**
1. Check database file permissions: `ls -la data/`
2. Verify database volume mount
3. Restart container: `docker compose restart`

### Recovery Procedures

**Reset to clean state:**
```bash
# Stop container
docker compose down

# Remove database (WARNING: This will delete all user accounts)
rm -rf data/

# Recreate data directory
mkdir -p data

# Start container (will recreate admin account)
docker compose up -d
```

**Backup database:**
```bash
# Create backup
cp data/filebrowser.db data/filebrowser.db.backup.$(date +%Y%m%d)

# Restore from backup
cp data/filebrowser.db.backup.20250122 data/filebrowser.db
docker compose restart
```

---

## 🔄 Maintenance Tasks

### Regular Maintenance

**Weekly:**
- Check container health: `docker compose ps`
- Review logs for errors: `docker compose logs filebrowser --tail 50`
- Verify API functionality

**Monthly:**
- Update Filebrowser image: `docker compose pull && docker compose up -d`
- Review user accounts: `docker compose exec filebrowser filebrowser users ls`
- Check disk usage: `df -h /mnt/s/fileserver`

**As Needed:**
- Change admin password
- Generate new API tokens
- Add/remove users
- Update configuration

### Backup Strategy

**Database backup:**
```bash
# Daily backup script
#!/bin/bash
BACKUP_DIR="/home/grimmjones/backups/fileserver"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
cp data/filebrowser.db $BACKUP_DIR/filebrowser_$DATE.db

# Keep only last 7 days
find $BACKUP_DIR -name "filebrowser_*.db" -mtime +7 -delete
```

**File system backup:**
```bash
# Backup file server data
rsync -av /mnt/s/fileserver/ /backup/location/fileserver/
```

---

## 🔒 Security Considerations

### Home Network Security

**Current risk level:** Low (trusted home network)

**Security measures:**
- JWT authentication enabled
- API access requires valid tokens
- No user registration allowed
- Long-lasting sessions for convenience

### Future Internet Access

**When enabling internet access:**
1. Enable HTTPS/TLS encryption
2. Implement firewall rules
3. Use strong passwords
4. Consider multi-user setup
5. Monitor access logs
6. Regular security updates

### Token Security

**Best practices:**
- Store tokens securely in applications
- Use environment variables
- Implement token rotation
- Monitor token usage
- Revoke compromised tokens

---

## 📚 Related Documentation

- **[API Access Guide](../../planning/features/api-access/api-access-guide.md)** - Complete API usage guide
- **[User Guide](../../planning/features/api-access/user-guide.md)** - Web interface usage
- **[Troubleshooting](troubleshooting.md)** - General troubleshooting guide

---

**Last Updated:** 2025-01-22  
**Status:** Complete  
**Next:** Regular monitoring and maintenance
