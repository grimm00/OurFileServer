# API Access Guide

**Purpose:** Simple guide for using the file server API with authentication  
**Status:** Complete  
**Last Updated:** 2025-01-22  
**Priority:** High

---

## 📋 Overview

This guide explains how to access the file server API using JWT authentication. The API provides programmatic access to all file operations for automation, mobile apps, and external integrations.

---

## 🔑 Authentication

### Getting an API Token

**Method 1: Programmatic Login (Recommended)**
```bash
# Get JWT token via API login
curl -X POST -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"yourpassword"}' \
  http://[your-ip]:8080/api/login
```

**Method 2: Web Interface Login**
1. Login to web interface at `http://[your-ip]:8080`
2. Username: `admin`
3. Password: `yourpassword`
4. The browser automatically stores the JWT token for API calls

### Using the Token

**Required Header:**
```
X-Auth: [JWT_TOKEN]
```

**Example:**
```bash
curl -H "X-Auth: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
     http://[your-ip]:8080/api/resources
```

---

## 🌐 Base URL

**Base URL:** `http://[your-ip]:8080`

**Examples:**
- `http://192.168.50.100:8080`
- `http://localhost:8080` (if accessing from same machine)

---

## 📁 API Endpoints

### List Files and Directories

**Endpoint:** `GET /api/resources`

**Description:** List files and directories in a given path

**Example:**
```bash
curl -H "X-Auth: $TOKEN" \
     "http://[your-ip]:8080/api/resources"
```

**Response:**
```json
{
  "items": [
    {
      "path": "documents",
      "name": "documents",
      "size": 4096,
      "isDir": true,
      "modified": "2025-10-19T22:35:25.1822383Z"
    }
  ],
  "numDirs": 4,
  "numFiles": 0
}
```

### Upload File

**Endpoint:** `POST /api/resources/{path}`

**Description:** Upload a file to the specified path

**Example:**
```bash
curl -H "X-Auth: $TOKEN" \
     -F "file=@/path/to/local/file.txt" \
     "http://[your-ip]:8080/api/resources/"
```

### Download File

**Endpoint:** `GET /api/resources/{path}`

**Description:** Download a file

**Example:**
```bash
curl -H "X-Auth: $TOKEN" \
     -H "Accept: application/octet-stream" \
     "http://[your-ip]:8080/api/resources/file.txt" \
     -o downloaded_file.txt
```

### Create Directory

**Endpoint:** `POST /api/resources/{path}`

**Description:** Create a new directory

**Example:**
```bash
curl -H "X-Auth: $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"dir": true}' \
     "http://[your-ip]:8080/api/resources/newdir"
```

### Delete File or Directory

**Endpoint:** `DELETE /api/resources/{path}`

**Description:** Delete a file or directory

**Example:**
```bash
curl -H "X-Auth: $TOKEN" \
     -X DELETE \
     "http://[your-ip]:8080/api/resources/file.txt"
```

---

## 🐍 Python Example

```python
import requests
import json

class FileServerClient:
    def __init__(self, base_url, username, password):
        self.base_url = base_url.rstrip('/')
        self.token = self._get_token(username, password)
        self.headers = {'X-Auth': self.token}
    
    def _get_token(self, username, password):
        response = requests.post(
            f"{self.base_url}/api/login",
            json={"username": username, "password": password}
        )
        return response.text
    
    def list_files(self, path='/'):
        response = requests.get(
            f"{self.base_url}/api/resources",
            headers=self.headers,
            params={'path': path}
        )
        return response.json()
    
    def upload_file(self, local_path, remote_path):
        with open(local_path, 'rb') as f:
            files = {'file': f}
            response = requests.post(
                f"{self.base_url}/api/resources{remote_path}",
                headers=self.headers,
                files=files
            )
        return response.status_code == 200

# Usage
client = FileServerClient('http://192.168.50.100:8080', 'admin', 'yourpassword')

# List files
files = client.list_files()
print(files)

# Upload file
client.upload_file('/local/file.txt', '/file.txt')
```

---

## 🔧 Shell Script Example

```bash
#!/bin/bash

# Configuration
SERVER="http://192.168.50.100:8080"
USERNAME="admin"
PASSWORD="yourpassword"

# Get token
TOKEN=$(curl -s -X POST -H "Content-Type: application/json" \
  -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" \
  "$SERVER/api/login")

# List files
echo "Files in root directory:"
curl -s -H "X-Auth: $TOKEN" "$SERVER/api/resources" | jq -r '.items[] | .name'

# Upload file
echo "Uploading file..."
curl -H "X-Auth: $TOKEN" -F "file=@/path/to/file.txt" "$SERVER/api/resources/"

# Download file
echo "Downloading file..."
curl -H "X-Auth: $TOKEN" -H "Accept: application/octet-stream" \
  "$SERVER/api/resources/file.txt" -o downloaded_file.txt
```

---

## 📱 Mobile Integration

### Android (Java)
```java
public class FileServerClient {
    private String baseUrl = "http://192.168.50.100:8080";
    private String token;
    
    public void login(String username, String password) {
        // Login and store token
        // Implementation details...
    }
    
    public void downloadFile(String remotePath, String localPath) {
        // Download file using stored token
        // Implementation details...
    }
}
```

### iOS (Swift)
```swift
class FileServerClient {
    let baseUrl = "http://192.168.50.100:8080"
    var token: String?
    
    func login(username: String, password: String) {
        // Login and store token
        // Implementation details...
    }
    
    func downloadFile(remotePath: String, localPath: String) {
        // Download file using stored token
        // Implementation details...
    }
}
```

---

## 🔒 Security Notes

### Token Management
- JWT tokens expire after 1 year (8760h)
- Store tokens securely in applications
- Don't hardcode tokens in source code
- Use environment variables for token storage

### Network Security
- API is only accessible on home network
- No HTTPS required for home network use
- For internet access, enable HTTPS and firewall rules

---

## 🆘 Troubleshooting

### Common Issues

**401 Unauthorized**
- Check username/password
- Verify token is included in X-Auth header
- Ensure token hasn't expired

**Connection Refused**
- Verify server is running: `docker compose ps`
- Check network connectivity
- Confirm correct IP address and port

**File Upload Fails**
- Check file permissions
- Verify file path exists
- Ensure sufficient disk space

### Getting Help

1. **Check container status:** `docker compose ps`
2. **View logs:** `docker compose logs filebrowser`
3. **Restart container:** `docker compose restart`
4. **Test connectivity:** `curl -I http://[ip]:8080`

---

## 📚 Related Documentation

- **[Migration Guide](migration-guide.md)** - How authentication was implemented
- **[User Guide](user-guide.md)** - Web interface usage
- **[Operations Guide](../../../operations/api-management.md)** - Server administration

---

**Last Updated:** 2025-01-22  
**Status:** Complete  
**Next:** Use API for automation and external applications
