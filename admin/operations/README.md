# File Server Operations Hub

This directory contains all operational documentation for managing and maintaining the OurFileServer.

## Quick Links

- [**Server Administration Guide**](./server-administration.md) - Complete guide to managing the file server
- [**API Management**](./api-management.md) - API access and authentication management
- [**Troubleshooting Guide**](./troubleshooting.md) - Common issues and solutions
- [**Network Configuration**](./network-setup.md) - WSL2 networking and port forwarding
- [**Backup and Recovery**](./backup-recovery.md) - Data protection strategies
- [**Security Considerations**](./security.md) - Security best practices

## Current Status

- ✅ **File Server**: Running (Filebrowser on Docker)
- ✅ **Storage**: External drive mounted at `/mnt/s/fileserver`
- ✅ **Network Access**: WSL2 with Windows port forwarding
- ✅ **Authentication**: JWT-based with API access enabled

## Quick Commands

```bash
# Start the server
docker compose up -d

# Stop the server
docker compose down

# Check status
docker compose ps

# View logs
docker compose logs filebrowser

# Restart the server
docker compose restart
```

## Quick Reference

### File Upload Methods

**Web Interface (Easiest):**
1. Login at `http://[your-ip]:8080` (admin/yourpassword)
2. Navigate to target directory
3. Drag & drop files or click upload button

**API Upload:**
```bash
# Get token
TOKEN=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"yourpassword"}' \
  http://[your-ip]:8080/api/login)

# Upload file
curl -H "X-Auth: $TOKEN" -F "file=@/path/to/file.txt" \
  http://[your-ip]:8080/api/resources/
```

**Create Directory:**
```bash
curl -H "X-Auth: $TOKEN" -H "Content-Type: application/json" \
  -d '{"dir": true}' http://[your-ip]:8080/api/resources/new-folder
```

### Common Operations

- **Upload Guide:** [API Access Upload Guide](../planning/features/api-access/upload-guide.md)
- **API Management:** [API Operations Guide](api-management.md)
- **Troubleshooting:** [Troubleshooting Guide](troubleshooting.md)

## Access URLs

- **Local**: http://localhost:8080
- **Network**: http://192.168.50.[WINDOWS_IP]:8080
- **WSL IP**: 192.168.147.153:8080

## Directory Structure

```
/mnt/s/fileserver/
├── documents/     # General documents
├── gaming/        # Game mods, ROMs, saves
├── media/         # Photos, videos, music
└── temp/          # Temporary files
```
