# Backup and Recovery Guide

Data protection strategies for the OurFileServer.

## Table of Contents

- [Backup Strategy](#backup-strategy)
- [Automated Backups](#automated-backups)
- [Manual Backup Procedures](#manual-backup-procedures)
- [Recovery Procedures](#recovery-procedures)
- [Disaster Recovery](#disaster-recovery)

## Backup Strategy

### Current Setup

- **Primary Storage**: External drive (S: drive, 500GB partition)
- **File Server**: Filebrowser with Docker
- **Data Location**: `/mnt/s/fileserver/`
- **Backup Frequency**: Manual (recommend weekly)

### Recommended Backup Levels

1. **File-Level Backups** (Daily/Weekly)
   - Copy important files to secondary location
   - Version control for critical documents
   - Cloud backup for irreplaceable files

2. **System Configuration Backups** (Monthly)
   - Docker Compose configuration
   - Network configuration scripts
   - Documentation and setup files

3. **Full System Backups** (Quarterly)
   - Complete external drive backup
   - WSL2 system backup
   - Windows configuration backup

## Automated Backups

### Simple File Backup Script

Create a backup script for regular file synchronization:

```bash
#!/bin/bash
# /home/grimmjones/Projects/OurFileServer/scripts/backup-files.sh

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
SOURCE_DIR="/mnt/s/fileserver"
BACKUP_DIR="/mnt/s/backups"
LOG_FILE="/home/grimmjones/Projects/OurFileServer/logs/backup-${BACKUP_DATE}.log"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create logs directory
mkdir -p "$(dirname "$LOG_FILE")"

echo "Starting backup at $(date)" >> "$LOG_FILE"

# Backup important directories
rsync -av --delete \
  "$SOURCE_DIR/documents/" \
  "$BACKUP_DIR/documents-backup-$BACKUP_DATE/" \
  >> "$LOG_FILE" 2>&1

rsync -av --delete \
  "$SOURCE_DIR/gaming/" \
  "$BACKUP_DIR/gaming-backup-$BACKUP_DATE/" \
  >> "$LOG_FILE" 2>&1

# Clean up old backups (keep last 7 days)
find "$BACKUP_DIR" -type d -name "*-backup-*" -mtime +7 -exec rm -rf {} \;

echo "Backup completed at $(date)" >> "$LOG_FILE"
```

### Cron Job Setup

Set up automatic daily backups:

```bash
# Edit crontab
crontab -e

# Add this line for daily backup at 2 AM
0 2 * * * /home/grimmjones/Projects/OurFileServer/scripts/backup-files.sh
```

### Docker Configuration Backup

```bash
#!/bin/bash
# /home/grimmjones/Projects/OurFileServer/scripts/backup-config.sh

BACKUP_DATE=$(date +%Y%m%d)
CONFIG_DIR="/home/grimmjones/Projects/OurFileServer"
BACKUP_DIR="/mnt/s/backups/config"

mkdir -p "$BACKUP_DIR"

# Backup Docker Compose and configuration files
tar -czf "$BACKUP_DIR/docker-config-$BACKUP_DATE.tar.gz" \
  -C "$CONFIG_DIR" \
  docker-compose.yml \
  .gitignore \
  .dockerignore \
  setup-admin.sh

# Backup documentation
tar -czf "$BACKUP_DIR/docs-$BACKUP_DATE.tar.gz" \
  -C "$CONFIG_DIR" \
  admin/ \
  README.md \
  STATUS.md

echo "Configuration backup completed: $BACKUP_DATE"
```

## Manual Backup Procedures

### File-Level Backup

**Backup specific directories:**

```bash
# Backup documents
rsync -av /mnt/s/fileserver/documents/ /mnt/s/backups/documents-$(date +%Y%m%d)/

# Backup gaming files
rsync -av /mnt/s/fileserver/gaming/ /mnt/s/backups/gaming-$(date +%Y%m%d)/

# Backup everything
rsync -av /mnt/s/fileserver/ /mnt/s/backups/full-backup-$(date +%Y%m%d)/
```

**Compress backups:**

```bash
# Create compressed archive
tar -czf /mnt/s/backups/full-backup-$(date +%Y%m%d).tar.gz -C /mnt/s/fileserver .

# Create incremental backup
tar -czf /mnt/s/backups/incremental-$(date +%Y%m%d).tar.gz \
  --newer-mtime="1 week ago" \
  -C /mnt/s/fileserver .
```

### System Configuration Backup

**Backup Docker setup:**

```bash
# Export Docker Compose configuration
cp docker-compose.yml /mnt/s/backups/docker-compose-$(date +%Y%m%d).yml

# Export container configuration
docker compose config > /mnt/s/backups/docker-config-$(date +%Y%m%d).yml

# Backup Git repository
cd /home/grimmjones/Projects/OurFileServer
git bundle create /mnt/s/backups/repo-backup-$(date +%Y%m%d).bundle --all
```

**Backup network configuration:**

```powershell
# In Windows PowerShell (run as Administrator)
# Export port forwarding rules
netsh interface portproxy show all > C:\backups\portproxy-$(Get-Date -Format "yyyyMMdd").txt

# Export firewall rules
Get-NetFirewallRule -DisplayName "WSL File Server" | Export-Clixml C:\backups\firewall-$(Get-Date -Format "yyyyMMdd").xml
```

### Cloud Backup Options

**For critical files, consider cloud backup:**

1. **Google Drive / OneDrive**
   - Sync important documents
   - Automatic versioning
   - Cross-device access

2. **GitHub/GitLab**
   - Version control for code/configs
   - Free private repositories
   - Automatic backup

3. **AWS S3 / Google Cloud Storage**
   - Automated backup scripts
   - Cost-effective for large files
   - Versioning and lifecycle policies

## Recovery Procedures

### File Recovery

**Restore from backup:**

```bash
# Restore specific directory
rsync -av /mnt/s/backups/documents-20241021/ /mnt/s/fileserver/documents/

# Restore from compressed backup
tar -xzf /mnt/s/backups/full-backup-20241021.tar.gz -C /mnt/s/fileserver/

# Restore specific files
tar -xzf /mnt/s/backups/full-backup-20241021.tar.gz -C /mnt/s/fileserver/ path/to/specific/file
```

**Recover deleted files:**

```bash
# Check if files exist in recent backups
find /mnt/s/backups -name "*backup*" -type d | sort -r | head -5

# Restore from most recent backup
rsync -av /mnt/s/backups/full-backup-20241021/ /mnt/s/fileserver/
```

### System Recovery

**Restore Docker configuration:**

```bash
# Stop current container
docker compose down

# Restore configuration
cp /mnt/s/backups/docker-compose-20241021.yml docker-compose.yml

# Start with restored configuration
docker compose up -d
```

**Restore network configuration:**

```powershell
# In Windows PowerShell (run as Administrator)
# Restore port forwarding
netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=8080 connectaddress=192.168.147.153 connectport=8080

# Restore firewall rules
Import-Clixml C:\backups\firewall-20241021.xml | New-NetFirewallRule
```

**Restore Git repository:**

```bash
# Clone from backup bundle
git clone /mnt/s/backups/repo-backup-20241021.bundle restored-repo
cd restored-repo
```

## Disaster Recovery

### Complete System Failure

**If external drive fails:**

1. **Assess damage**
   ```bash
   # Check if drive is accessible
   ls -la /mnt/s/
   
   # Check disk health
   sudo smartctl -a /dev/sdX
   ```

2. **Recover from backups**
   ```bash
   # Mount backup drive
   sudo mkdir -p /mnt/backup
   sudo mount /dev/sdY /mnt/backup
   
   # Restore files
   rsync -av /mnt/backup/fileserver-backup/ /mnt/s/fileserver/
   ```

3. **Recreate system**
   ```bash
   # Restore Docker configuration
   cp /mnt/backup/docker-compose.yml .
   
   # Restart services
   docker compose up -d
   ```

### WSL2 System Failure

**If WSL2 becomes corrupted:**

1. **Export current data**
   ```bash
   # In Windows Command Prompt
   wsl --export Ubuntu C:\backup\wsl-backup.tar
   ```

2. **Reinstall WSL2**
   ```powershell
   # Unregister current WSL
   wsl --unregister Ubuntu
   
   # Reinstall WSL
   wsl --install Ubuntu
   ```

3. **Restore data**
   ```bash
   # Import backup
   wsl --import Ubuntu C:\WSL\Ubuntu C:\backup\wsl-backup.tar
   ```

### Windows System Failure

**If Windows needs to be reinstalled:**

1. **Backup WSL data**
   ```bash
   wsl --export Ubuntu C:\backup\wsl-complete-backup.tar
   ```

2. **Backup network configuration**
   ```powershell
   netsh interface portproxy show all > C:\backup\portproxy.txt
   Get-NetFirewallRule -DisplayName "WSL File Server" | Export-Clixml C:\backup\firewall.xml
   ```

3. **After Windows reinstall**
   - Reinstall WSL2
   - Import WSL backup
   - Restore network configuration
   - Restart file server

## Backup Verification

### Test Backup Integrity

```bash
# Verify backup files
find /mnt/s/backups -name "*.tar.gz" -exec tar -tzf {} \; > /dev/null

# Compare file counts
echo "Original files:"
find /mnt/s/fileserver -type f | wc -l

echo "Backup files:"
find /mnt/s/backups -type f | wc -l
```

### Test Recovery Process

**Regular recovery testing:**

1. **Create test directory**
   ```bash
   mkdir -p /mnt/s/fileserver/test-recovery
   echo "test file" > /mnt/s/fileserver/test-recovery/test.txt
   ```

2. **Backup test data**
   ```bash
   rsync -av /mnt/s/fileserver/test-recovery/ /mnt/s/backups/test-backup/
   ```

3. **Delete original**
   ```bash
   rm -rf /mnt/s/fileserver/test-recovery
   ```

4. **Restore from backup**
   ```bash
   rsync -av /mnt/s/backups/test-backup/ /mnt/s/fileserver/test-recovery/
   ```

5. **Verify restoration**
   ```bash
   cat /mnt/s/fileserver/test-recovery/test.txt
   ```

## Backup Monitoring

### Backup Status Monitoring

```bash
#!/bin/bash
# /home/grimmjones/Projects/OurFileServer/scripts/check-backups.sh

BACKUP_DIR="/mnt/s/backups"
LOG_FILE="/home/grimmjones/Projects/OurFileServer/logs/backup-check.log"

echo "Backup check at $(date)" >> "$LOG_FILE"

# Check if backups exist
if [ ! -d "$BACKUP_DIR" ]; then
    echo "ERROR: Backup directory not found" >> "$LOG_FILE"
    exit 1
fi

# Check recent backups
RECENT_BACKUPS=$(find "$BACKUP_DIR" -name "*backup*" -mtime -7 | wc -l)
echo "Recent backups (last 7 days): $RECENT_BACKUPS" >> "$LOG_FILE"

if [ "$RECENT_BACKUPS" -eq 0 ]; then
    echo "WARNING: No recent backups found" >> "$LOG_FILE"
fi

# Check backup sizes
echo "Backup directory sizes:" >> "$LOG_FILE"
du -sh "$BACKUP_DIR"/* >> "$LOG_FILE"

echo "Backup check completed at $(date)" >> "$LOG_FILE"
```

### Automated Monitoring

```bash
# Add to crontab for daily backup monitoring
0 8 * * * /home/grimmjones/Projects/OurFileServer/scripts/check-backups.sh
```

## Best Practices

### Backup Strategy

1. **3-2-1 Rule**
   - 3 copies of important data
   - 2 different storage types
   - 1 offsite backup

2. **Regular Testing**
   - Test backups monthly
   - Verify recovery procedures
   - Document any issues

3. **Automation**
   - Use scripts for regular backups
   - Monitor backup success
   - Alert on failures

### Storage Management

1. **Rotate Backups**
   - Keep daily backups for 1 week
   - Keep weekly backups for 1 month
   - Keep monthly backups for 1 year

2. **Compress Old Backups**
   - Compress backups older than 1 month
   - Use efficient compression (gzip, bzip2)
   - Verify compressed backups

3. **Monitor Storage Usage**
   - Check backup storage regularly
   - Clean up old backups
   - Expand storage as needed

### Security Considerations

1. **Encrypt Sensitive Backups**
   ```bash
   # Encrypt backup with GPG
   tar -czf - /mnt/s/fileserver/ | gpg --symmetric --cipher-algo AES256 > backup-encrypted.tar.gz.gpg
   ```

2. **Secure Backup Storage**
   - Use encrypted external drives
   - Secure cloud storage accounts
   - Regular security updates

3. **Access Control**
   - Limit backup access
   - Use strong passwords
   - Regular access reviews
