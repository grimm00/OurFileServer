# External Storage Setup

**Purpose:** Plan and document external hard drive setup for file server storage  
**Status:** In Progress  
**Last Updated:** 2025-01-06  
**Priority:** High

---

## 📋 Overview

This document covers setting up an external hard drive for the file server, including partitioning, formatting, and integrating with the Filebrowser Docker container.

---

## 🎯 Storage Requirements

### Current Plan
- **Storage Size:** 500GB (512GB) dedicated partition
- **File System:** NTFS (Windows compatibility) or ext4 (Linux performance)
- **Usage:** Gaming files (mods, ROMs, saves) + general file sharing
- **Access:** Via Filebrowser web interface

### Storage Breakdown
- **Gaming Files:** ~200GB
  - Game mods: ~50GB
  - ROMs: ~100GB
  - Save files: ~10GB
  - Game assets: ~40GB
- **General Files:** ~200GB
  - Documents: ~20GB
  - Photos: ~50GB
  - Videos: ~100GB
  - Other: ~30GB
- **Buffer:** ~100GB for growth

---

## 🔧 Setup Options

### Option 1: Dedicated Partition (Recommended)

**Benefits:**
- ✅ Isolated from other data
- ✅ Easy to manage
- ✅ Can be formatted optimally for file server
- ✅ Easy backup of entire partition

**Setup Steps:**
1. **Backup existing data** on external drive
2. **Shrink existing partition** to free up 500GB
3. **Create new partition** for file server
4. **Format with appropriate file system**
5. **Mount and configure** with Docker

### Option 2: Dedicated Folder

**Benefits:**
- ✅ No partitioning required
- ✅ Simpler setup
- ✅ Can use existing file system

**Drawbacks:**
- ❌ Mixed with other data
- ❌ Harder to manage
- ❌ Backup complexity

---

## 🖥️ Platform-Specific Setup

### Windows Setup

**Step 1: Access Disk Management**
```cmd
# Open Disk Management
diskmgmt.msc
```

**Step 2: Shrink Existing Partition**
1. Right-click on external drive partition
2. Select "Shrink Volume"
3. Enter **512000 MB** (500GB)
4. Click "Shrink"

**Step 3: Create New Partition**
1. Right-click on unallocated space
2. Select "New Simple Volume"
3. Follow wizard:
   - Size: 512000 MB
   - Drive letter: Choose available letter
   - File system: **NTFS**
   - Volume label: "FileServerStorage"

**Step 4: Configure Permissions**
```cmd
# Set permissions for Docker access
icacls "E:\" /grant "Users:(OI)(CI)F"
```

### Linux Setup

**Step 1: Identify External Drive**
```bash
# List all drives
lsblk

# Find external drive (usually /dev/sdb or /dev/sdc)
sudo fdisk -l
```

**Step 2: Create Partition**
```bash
# Open fdisk for external drive
sudo fdisk /dev/sdX  # Replace X with your drive

# In fdisk:
# n - new partition
# p - primary partition
# 2 - partition number (if 1 exists)
# Enter - use default first sector
# +500G - size (500GB)
# w - write changes
```

**Step 3: Format Partition**
```bash
# Format with ext4 (better performance)
sudo mkfs.ext4 /dev/sdX2

# Or format with NTFS (Windows compatibility)
sudo mkfs.ntfs /dev/sdX2
```

**Step 4: Create Mount Point**
```bash
# Create mount point
sudo mkdir /mnt/fileserver

# Mount partition
sudo mount /dev/sdX2 /mnt/fileserver

# Set permissions
sudo chown $USER:$USER /mnt/fileserver
sudo chmod 755 /mnt/fileserver
```

**Step 5: Auto-mount (Optional)**
```bash
# Get UUID
sudo blkid /dev/sdX2

# Add to fstab
echo "UUID=your-uuid-here /mnt/fileserver ext4 defaults 0 2" | sudo tee -a /etc/fstab
```

---

## 🐳 Docker Integration

### Updated Filebrowser Setup

**Windows:**
```bash
# Create directories
mkdir C:\fileserver\data
mkdir C:\fileserver\config

# Run Filebrowser with external drive
docker run -d \
  --name filebrowser \
  -p 8080:80 \
  -v "E:\FileServerStorage:/srv" \
  -v "C:\fileserver\config\database.db:/database.db" \
  --restart unless-stopped \
  filebrowser/filebrowser:latest
```

**Linux:**
```bash
# Create directories
mkdir -p ~/fileserver/config

# Run Filebrowser with external drive
docker run -d \
  --name filebrowser \
  -p 8080:80 \
  -v "/mnt/fileserver:/srv" \
  -v "~/fileserver/config/database.db:/database.db" \
  --restart unless-stopped \
  filebrowser/filebrowser:latest
```

### Docker Compose Setup (Recommended)

**Create docker-compose.yml:**
```yaml
version: '3.8'
services:
  filebrowser:
    image: filebrowser/filebrowser:latest
    container_name: filebrowser
    ports:
      - "8080:80"
    volumes:
      # Windows: "E:\FileServerStorage:/srv"
      # Linux: "/mnt/fileserver:/srv"
      - /mnt/fileserver:/srv
      - ./config/database.db:/database.db
    restart: unless-stopped
    environment:
      - FB_DATABASE=/database.db
      - FB_ROOT=/srv
```

**Run with Docker Compose:**
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f
```

---

## 📁 File Organization

### Recommended Folder Structure
```
/mnt/fileserver/ (or E:\FileServerStorage\)
├── gaming/
│   ├── mods/
│   │   ├── steam/
│   │   ├── epic/
│   │   └── other/
│   ├── roms/
│   │   ├── nintendo/
│   │   ├── playstation/
│   │   └── other/
│   ├── saves/
│   │   ├── steam/
│   │   ├── epic/
│   │   └── other/
│   └── assets/
│       ├── textures/
│       ├── models/
│       └── other/
├── documents/
│   ├── personal/
│   ├── work/
│   └── shared/
├── media/
│   ├── photos/
│   ├── videos/
│   └── music/
└── temp/
    └── uploads/
```

### Create Folder Structure
```bash
# Create main directories
mkdir -p /mnt/fileserver/{gaming/{mods/{steam,epic,other},roms/{nintendo,playstation,other},saves/{steam,epic,other},assets/{textures,models,other}},documents/{personal,work,shared},media/{photos,videos,music},temp/uploads}

# Set permissions
chmod -R 755 /mnt/fileserver
chown -R $USER:$USER /mnt/fileserver
```

---

## 🔒 Security Considerations

### File Permissions
```bash
# Set appropriate permissions
chmod 755 /mnt/fileserver                    # Root directory
chmod 755 /mnt/fileserver/gaming             # Gaming files
chmod 755 /mnt/fileserver/documents          # Documents
chmod 755 /mnt/fileserver/media              # Media files
chmod 777 /mnt/fileserver/temp               # Temp uploads
```

### Backup Strategy
```bash
# Create backup script
cat > ~/backup-fileserver.sh << EOF
#!/bin/bash
SOURCE="/mnt/fileserver"
BACKUP="/path/to/backup/location"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup
tar -czf "$BACKUP/fileserver_backup_$DATE.tar.gz" "$SOURCE"

# Keep only last 7 backups
ls -t "$BACKUP"/fileserver_backup_*.tar.gz | tail -n +8 | xargs rm -f
EOF

chmod +x ~/backup-fileserver.sh
```

---

## 📊 Performance Considerations

### File System Choice

**NTFS (Windows):**
- ✅ Windows compatibility
- ✅ Large file support
- ✅ Good for mixed environments
- ❌ Slightly slower than ext4

**ext4 (Linux):**
- ✅ Better performance
- ✅ Better for Linux servers
- ✅ Journaling support
- ❌ Windows compatibility issues

**Recommendation:** Use NTFS if you need Windows compatibility, ext4 if Linux-only.

### Optimization Tips
```bash
# Mount with performance options (Linux)
sudo mount -o noatime,nodiratime /dev/sdX2 /mnt/fileserver

# Add to fstab for permanent mount
echo "UUID=your-uuid /mnt/fileserver ext4 defaults,noatime,nodiratime 0 2" | sudo tee -a /etc/fstab
```

---

## 🚀 Implementation Steps

### Phase 1: Preparation
1. **Backup existing data** on external drive
2. **Plan partition layout** (500GB for file server)
3. **Choose file system** (NTFS vs ext4)

### Phase 2: Setup
1. **Create partition** using disk management tools
2. **Format partition** with chosen file system
3. **Create mount point** and mount partition
4. **Set permissions** for Docker access

### Phase 3: Integration
1. **Update Docker configuration** to use external drive
2. **Create folder structure** for organization
3. **Test file operations** (upload/download)
4. **Verify performance** and access

### Phase 4: Production
1. **Start using for gaming files**
2. **Organize existing files** into structure
3. **Set up backup routine**
4. **Monitor storage usage**

---

## 📚 Related Documents

### Planning
- [Use Case and Requirements](use-case-and-requirements.md) - Requirements
- [Laptop Hosting Considerations](laptop-hosting-considerations.md) - Hosting guide

### Research
- [Technology Decision](../decisions/technology-decision.md) - Filebrowser choice
- [Quick Start Comparison](../research/quick-start-comparison.md) - Setup guides

---

## 🎯 Next Steps

1. **Backup external drive data** before partitioning
2. **Choose file system** (NTFS for Windows compatibility, ext4 for Linux)
3. **Create 500GB partition** using disk management tools
4. **Update Docker setup** to use external drive
5. **Test file operations** and performance

---

**Last Updated:** 2025-01-06  
**Status:** Ready for Implementation  
**Next:** Begin external drive setup and partitioning


