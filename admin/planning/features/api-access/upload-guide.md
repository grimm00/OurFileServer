# File Upload Guide

**Purpose:** Step-by-step instructions for uploading files to the server  
**Status:** Complete  
**Last Updated:** 2025-01-22  
**Priority:** High

---

## 📋 Overview

This guide provides comprehensive instructions for uploading files to the file server using both the web interface and API methods. Choose the method that best fits your needs.

---

## 🌐 Web Interface Upload

### Method 1: Drag and Drop (Easiest)

1. **Login to the web interface**
   - Go to `http://[your-ip]:8080`
   - Username: `admin`
   - Password: `yourpassword`

2. **Navigate to target directory**
   - Click on the folder where you want to upload files
   - Example: Click "documents" to upload to `/documents/`

3. **Drag and drop files**
   - Open your file manager (Windows Explorer, Finder, etc.)
   - Select the files you want to upload
   - Drag them directly onto the web interface
   - Drop them in the file list area

4. **Monitor upload progress**
   - Watch the progress bar for each file
   - Wait for "Upload complete" message

### Method 2: Upload Button

1. **Navigate to target directory**
   - Click on the folder where you want to upload files

2. **Click the upload button**
   - Look for the upload icon (usually a cloud or arrow pointing up)
   - Click "Upload" or the upload button

3. **Select files**
   - Choose files from your computer
   - You can select multiple files at once
   - Click "Open" or "Select"

4. **Confirm upload**
   - Review the file list
   - Click "Upload" to start the process

### Method 3: Create Directory First

1. **Create a new directory**
   - Click "New Folder" or "+" button
   - Enter directory name (e.g., "my-uploads")
   - Press Enter to create

2. **Navigate into the new directory**
   - Click on the newly created folder

3. **Upload files using Method 1 or 2 above**

---

## 🔌 API Upload Methods

### Prerequisites

**Get API Token:**
```bash
# Get JWT token
TOKEN=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"yourpassword"}' \
  http://[your-ip]:8080/api/login)
```

### Single File Upload

**Upload to root directory:**
```bash
curl -H "X-Auth: $TOKEN" \
     -F "file=@/path/to/local/file.txt" \
     "http://[your-ip]:8080/api/resources/"
```

**Upload to specific directory:**
```bash
curl -H "X-Auth: $TOKEN" \
     -F "file=@/path/to/local/file.txt" \
     "http://[your-ip]:8080/api/resources/documents/"
```

### Multiple File Upload

**Upload multiple files at once:**
```bash
curl -H "X-Auth: $TOKEN" \
     -F "file=@file1.txt" \
     -F "file=@file2.txt" \
     -F "file=@file3.txt" \
     "http://[your-ip]:8080/api/resources/"
```

### Create Directory Then Upload

**Step 1: Create directory**
```bash
curl -H "X-Auth: $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"dir": true}' \
     "http://[your-ip]:8080/api/resources/my-new-folder"
```

**Step 2: Upload to new directory**
```bash
curl -H "X-Auth: $TOKEN" \
     -F "file=@/path/to/file.txt" \
     "http://[your-ip]:8080/api/resources/my-new-folder/"
```

---

## 🐍 Python Upload Examples

### Basic Upload Function

```python
import requests
import os

def upload_file(server_url, token, local_file_path, remote_path=""):
    """
    Upload a file to the file server
    
    Args:
        server_url: Base URL of the file server
        token: JWT authentication token
        local_file_path: Path to local file to upload
        remote_path: Remote directory path (empty for root)
    """
    url = f"{server_url}/api/resources/{remote_path}"
    headers = {"X-Auth": token}
    
    with open(local_file_path, 'rb') as f:
        files = {'file': f}
        response = requests.post(url, headers=headers, files=files)
    
    if response.status_code == 200:
        print(f"✅ Upload successful: {os.path.basename(local_file_path)}")
        return True
    else:
        print(f"❌ Upload failed: {response.status_code}")
        return False

# Usage example
SERVER_URL = "http://192.168.50.100:8080"
TOKEN = "your_jwt_token_here"

# Upload single file
upload_file(SERVER_URL, TOKEN, "/home/user/document.pdf", "documents/")

# Upload to root
upload_file(SERVER_URL, TOKEN, "/home/user/image.jpg")
```

### Batch Upload Function

```python
import requests
import os
from pathlib import Path

def batch_upload(server_url, token, local_directory, remote_directory=""):
    """
    Upload all files from a local directory
    
    Args:
        server_url: Base URL of the file server
        token: JWT authentication token
        local_directory: Local directory containing files
        remote_directory: Remote directory path
    """
    local_path = Path(local_directory)
    
    if not local_path.exists():
        print(f"❌ Directory not found: {local_directory}")
        return
    
    files_uploaded = 0
    files_failed = 0
    
    for file_path in local_path.iterdir():
        if file_path.is_file():
            success = upload_file(server_url, token, str(file_path), remote_directory)
            if success:
                files_uploaded += 1
            else:
                files_failed += 1
    
    print(f"📊 Upload complete: {files_uploaded} successful, {files_failed} failed")

# Usage example
batch_upload(SERVER_URL, TOKEN, "/home/user/photos", "media/photos/")
```

### Complete Upload Client

```python
import requests
import os
from pathlib import Path

class FileServerUploader:
    def __init__(self, server_url, username, password):
        self.server_url = server_url.rstrip('/')
        self.token = self._get_token(username, password)
        self.headers = {'X-Auth': self.token}
    
    def _get_token(self, username, password):
        """Get JWT token from server"""
        response = requests.post(
            f"{self.server_url}/api/login",
            json={"username": username, "password": password}
        )
        return response.text
    
    def create_directory(self, path):
        """Create a directory on the server"""
        response = requests.post(
            f"{self.server_url}/api/resources{path}",
            headers={**self.headers, 'Content-Type': 'application/json'},
            json={'dir': True}
        )
        return response.status_code == 200
    
    def upload_file(self, local_path, remote_path=""):
        """Upload a single file"""
        url = f"{self.server_url}/api/resources/{remote_path}"
        
        with open(local_path, 'rb') as f:
            files = {'file': f}
            response = requests.post(url, headers=self.headers, files=files)
        
        return response.status_code == 200
    
    def upload_directory(self, local_dir, remote_dir=""):
        """Upload entire directory recursively"""
        local_path = Path(local_dir)
        
        # Create remote directory if it doesn't exist
        if remote_dir and not remote_dir.endswith('/'):
            remote_dir += '/'
        
        # Upload all files
        for file_path in local_path.rglob('*'):
            if file_path.is_file():
                relative_path = file_path.relative_to(local_path)
                remote_file_path = remote_dir + str(relative_path).replace('\\', '/')
                
                success = self.upload_file(str(file_path), remote_file_path)
                if success:
                    print(f"✅ Uploaded: {relative_path}")
                else:
                    print(f"❌ Failed: {relative_path}")

# Usage example
uploader = FileServerUploader('http://192.168.50.100:8080', 'admin', 'yourpassword')

# Upload single file
uploader.upload_file('/home/user/document.pdf', 'documents/')

# Upload entire directory
uploader.upload_directory('/home/user/photos', 'media/photos/')
```

---

## 🔧 Shell Script Examples

### Basic Upload Script

```bash
#!/bin/bash

# Configuration
SERVER="http://192.168.50.100:8080"
USERNAME="admin"
PASSWORD="yourpassword"
TOKEN=""

# Get authentication token
get_token() {
    TOKEN=$(curl -s -X POST -H "Content-Type: application/json" \
        -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" \
        "$SERVER/api/login")
    
    if [ -z "$TOKEN" ]; then
        echo "❌ Failed to get authentication token"
        exit 1
    fi
    
    echo "✅ Authentication successful"
}

# Upload single file
upload_file() {
    local local_file="$1"
    local remote_path="$2"
    
    if [ ! -f "$local_file" ]; then
        echo "❌ File not found: $local_file"
        return 1
    fi
    
    echo "📤 Uploading: $(basename "$local_file")"
    
    response=$(curl -s -w "%{http_code}" -H "X-Auth: $TOKEN" \
        -F "file=@$local_file" \
        "$SERVER/api/resources/$remote_path")
    
    http_code="${response: -3}"
    
    if [ "$http_code" = "200" ]; then
        echo "✅ Upload successful"
        return 0
    else
        echo "❌ Upload failed (HTTP $http_code)"
        return 1
    fi
}

# Create directory
create_directory() {
    local dir_path="$1"
    
    echo "📁 Creating directory: $dir_path"
    
    response=$(curl -s -w "%{http_code}" -H "X-Auth: $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"dir": true}' \
        "$SERVER/api/resources/$dir_path")
    
    http_code="${response: -3}"
    
    if [ "$http_code" = "200" ]; then
        echo "✅ Directory created"
        return 0
    else
        echo "❌ Directory creation failed (HTTP $http_code)"
        return 1
    fi
}

# Main execution
main() {
    get_token
    
    # Example usage
    create_directory "uploads/$(date +%Y%m%d)"
    upload_file "/home/user/document.pdf" "uploads/$(date +%Y%m%d)/"
    upload_file "/home/user/image.jpg" "media/"
}

# Run main function
main "$@"
```

### Batch Upload Script

```bash
#!/bin/bash

# Batch upload script
SERVER="http://192.168.50.100:8080"
USERNAME="admin"
PASSWORD="yourpassword"
UPLOAD_DIR="$1"
REMOTE_DIR="$2"

if [ -z "$UPLOAD_DIR" ]; then
    echo "Usage: $0 <local_directory> [remote_directory]"
    echo "Example: $0 /home/user/photos media/photos/"
    exit 1
fi

if [ ! -d "$UPLOAD_DIR" ]; then
    echo "❌ Directory not found: $UPLOAD_DIR"
    exit 1
fi

# Get token
echo "🔐 Authenticating..."
TOKEN=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" \
    "$SERVER/api/login")

if [ -z "$TOKEN" ]; then
    echo "❌ Authentication failed"
    exit 1
fi

echo "✅ Authentication successful"

# Create remote directory if specified
if [ -n "$REMOTE_DIR" ]; then
    echo "📁 Creating remote directory: $REMOTE_DIR"
    curl -s -H "X-Auth: $TOKEN" \
         -H "Content-Type: application/json" \
         -d '{"dir": true}' \
         "$SERVER/api/resources/$REMOTE_DIR"
fi

# Upload all files
echo "📤 Starting batch upload..."
uploaded=0
failed=0

for file in "$UPLOAD_DIR"/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "📤 Uploading: $filename"
        
        response=$(curl -s -w "%{http_code}" -H "X-Auth: $TOKEN" \
            -F "file=@$file" \
            "$SERVER/api/resources/$REMOTE_DIR")
        
        http_code="${response: -3}"
        
        if [ "$http_code" = "200" ]; then
            echo "✅ Success: $filename"
            ((uploaded++))
        else
            echo "❌ Failed: $filename (HTTP $http_code)"
            ((failed++))
        fi
    fi
done

echo "📊 Upload complete: $uploaded successful, $failed failed"
```

---

## 🆘 Troubleshooting

### Common Issues

**Authentication Errors (401 Unauthorized)**
- **Problem:** Invalid username/password or expired token
- **Solution:** 
  - Verify credentials: `admin` / `yourpassword`
  - Generate fresh token
  - Check if container is running: `docker compose ps`

**Permission Denied (403 Forbidden)**
- **Problem:** Insufficient permissions
- **Solution:**
  - Verify `"create": true` in settings
  - Check if user has upload permissions
  - Restart container: `docker compose restart`

**File Size Limits**
- **Problem:** Large files fail to upload
- **Solution:**
  - Check available disk space: `df -h /mnt/s/fileserver`
  - Split large files into smaller chunks
  - Use API for large files (better error handling)

**Network Timeouts**
- **Problem:** Upload fails due to network issues
- **Solution:**
  - Check network connectivity: `ping [server-ip]`
  - Try smaller files first
  - Use wired connection instead of WiFi
  - Check Windows port forwarding: `netsh interface portproxy show all`

**Disk Space Issues**
- **Problem:** No space left on device
- **Solution:**
  - Check disk usage: `df -h`
  - Clean up old files
  - Expand storage if needed

### Debug Commands

**Check server status:**
```bash
docker compose ps
docker compose logs filebrowser --tail 20
```

**Test API connectivity:**
```bash
curl -I http://[your-ip]:8080/
curl -H "X-Auth: $TOKEN" http://[your-ip]:8080/api/resources
```

**Check file permissions:**
```bash
ls -la /mnt/s/fileserver/
```

**Monitor upload progress:**
```bash
# Watch container logs during upload
docker compose logs filebrowser -f
```

---

## 📊 File Size Considerations

### Recommended Limits

- **Web Interface:** Up to 100MB per file
- **API Upload:** Up to 1GB per file
- **Batch Upload:** Up to 50 files at once

### Large File Strategy

**For files > 100MB:**
1. Use API upload instead of web interface
2. Upload during off-peak hours
3. Monitor disk space before starting
4. Consider splitting very large files

**For many small files:**
1. Use batch upload scripts
2. Upload in batches of 10-20 files
3. Monitor server performance

---

## 📚 Related Documentation

- **[API Access Guide](api-access-guide.md)** - Complete API usage guide
- **[User Guide](user-guide.md)** - Web interface usage
- **[API Management](../../../operations/api-management.md)** - Server administration

---

**Last Updated:** 2025-01-22  
**Status:** Complete  
**Next:** Start uploading files to your server!
