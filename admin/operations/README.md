# File Server Operations Hub

This directory contains all operational documentation for managing and maintaining the OurFileServer.

## Quick Links

- [**Server Administration Guide**](./server-administration.md) - Complete guide to managing the file server
- [**Troubleshooting Guide**](./troubleshooting.md) - Common issues and solutions
- [**Network Configuration**](./network-setup.md) - WSL2 networking and port forwarding
- [**Backup and Recovery**](./backup-recovery.md) - Data protection strategies
- [**Security Considerations**](./security.md) - Security best practices

## Current Status

- ✅ **File Server**: Running (Filebrowser on Docker)
- ✅ **Storage**: External drive mounted at `/mnt/s/fileserver`
- ✅ **Network Access**: WSL2 with Windows port forwarding
- ✅ **Authentication**: Disabled (no-auth mode for home use)

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
