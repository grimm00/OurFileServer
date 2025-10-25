# API Documentation

**Purpose:** Complete API reference for Filebrowser with authentication  
**Status:** Complete  
**Last Updated:** 2025-01-22  
**Priority:** High

---

## 📋 Overview

This document provides complete API documentation for accessing the file server programmatically. All API endpoints require authentication using JWT tokens generated from the shared admin account.

---

## 🔐 Authentication

### Getting an API Token

1. **Login to web interface** with admin credentials
2. **Go to Settings** (gear icon)
3. **Navigate to API section**
4. **Generate new token**
5. **Copy the token** for use in applications

### Using the Token

**Required Header:**
```
X-Auth: [YOUR_API_TOKEN]
```

**Example:**
```bash
curl -H "X-Auth: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
     http://192.168.50.100:8080/api/resources
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

**Parameters:**
- `path` (optional): Directory path to list (default: root)

**Example Request:**
```bash
curl -H "X-Auth: YOUR_TOKEN" \
     "http://192.168.50.100:8080/api/resources?path=/games"
```

**Example Response:**
```json
[
  {
    "name": "mods",
    "size": 0,
    "modTime": "2025-01-22T10:30:00Z",
    "mode": "drwxr-xr-x",
    "isDir": true,
    "type": "dir"
  },
  {
    "name": "save1.sav",
    "size": 1024,
    "modTime": "2025-01-22T09:15:00Z",
    "mode": "-rw-r--r--",
    "isDir": false,
    "type": "file"
  }
]
```

### Get File Information

**Endpoint:** `GET /api/resources/{path}`

**Description:** Get information about a specific file or directory

**Example Request:**
```bash
curl -H "X-Auth: YOUR_TOKEN" \
     "http://192.168.50.100:8080/api/resources/games/mods"
```

**Example Response:**
```json
{
  "name": "mods",
  "size": 0,
  "modTime": "2025-01-22T10:30:00Z",
  "mode": "drwxr-xr-x",
  "isDir": true,
  "type": "dir"
}
```

### Download File

**Endpoint:** `GET /api/resources/{path}`

**Description:** Download a file (use with `Accept: application/octet-stream`)

**Example Request:**
```bash
curl -H "X-Auth: YOUR_TOKEN" \
     -H "Accept: application/octet-stream" \
     "http://192.168.50.100:8080/api/resources/games/save1.sav" \
     -o save1.sav
```

### Upload File

**Endpoint:** `POST /api/resources/{path}`

**Description:** Upload a file to the specified path

**Content-Type:** `multipart/form-data`

**Example Request:**
```bash
curl -H "X-Auth: YOUR_TOKEN" \
     -F "file=@/path/to/local/file.txt" \
     "http://192.168.50.100:8080/api/resources/games/"
```

**Example Response:**
```json
{
  "message": "File uploaded successfully",
  "path": "/games/file.txt"
}
```

### Create Directory

**Endpoint:** `POST /api/resources/{path}`

**Description:** Create a new directory

**Content-Type:** `application/json`

**Example Request:**
```bash
curl -H "X-Auth: YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"dir": true}' \
     "http://192.168.50.100:8080/api/resources/games/newmods"
```

### Update File

**Endpoint:** `PUT /api/resources/{path}`

**Description:** Update/replace a file

**Content-Type:** `application/octet-stream`

**Example Request:**
```bash
curl -H "X-Auth: YOUR_TOKEN" \
     -H "Content-Type: application/octet-stream" \
     -X PUT \
     --data-binary @/path/to/local/file.txt \
     "http://192.168.50.100:8080/api/resources/games/save1.sav"
```

### Delete File or Directory

**Endpoint:** `DELETE /api/resources/{path}`

**Description:** Delete a file or directory

**Example Request:**
```bash
curl -H "X-Auth: YOUR_TOKEN" \
     -X DELETE \
     "http://192.168.50.100:8080/api/resources/games/oldfile.txt"
```

**Example Response:**
```json
{
  "message": "File deleted successfully"
}
```

### Rename File or Directory

**Endpoint:** `PATCH /api/resources/{path}`

**Description:** Rename a file or directory

**Content-Type:** `application/json`

**Example Request:**
```bash
curl -H "X-Auth: YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     -X PATCH \
     -d '{"name": "newfilename.txt"}' \
     "http://192.168.50.100:8080/api/resources/games/oldfile.txt"
```

---

## 🔧 Common Use Cases

### Backup Script

**Purpose:** Automatically backup files from local machine to file server

**Example:**
```bash
#!/bin/bash
TOKEN="YOUR_API_TOKEN"
SERVER="http://192.168.50.100:8080"

# Upload backup file
curl -H "X-Auth: $TOKEN" \
     -F "file=@/home/user/backup.tar.gz" \
     "$SERVER/api/resources/backups/$(date +%Y%m%d).tar.gz"
```

### File Synchronization

**Purpose:** Sync files between devices

**Example:**
```bash
#!/bin/bash
TOKEN="YOUR_API_TOKEN"
SERVER="http://192.168.50.100:8080"

# Download latest save file
curl -H "X-Auth: $TOKEN" \
     -H "Accept: application/octet-stream" \
     "$SERVER/api/resources/games/latest.sav" \
     -o /local/games/save.sav
```

### Game Mod Management

**Purpose:** Download and manage game mods

**Example:**
```bash
#!/bin/bash
TOKEN="YOUR_API_TOKEN"
SERVER="http://192.168.50.100:8080"

# List available mods
curl -H "X-Auth: $TOKEN" \
     "$SERVER/api/resources/games/mods" | jq '.[].name'

# Download specific mod
curl -H "X-Auth: $TOKEN" \
     -H "Accept: application/octet-stream" \
     "$SERVER/api/resources/games/mods/awesome_mod.zip" \
     -o /local/games/mods/awesome_mod.zip
```

---

## 📱 Mobile App Integration

### Android Example (Java)

```java
public class FileServerClient {
    private String baseUrl = "http://192.168.50.100:8080";
    private String token = "YOUR_API_TOKEN";
    
    public void downloadFile(String remotePath, String localPath) {
        try {
            URL url = new URL(baseUrl + "/api/resources" + remotePath);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestProperty("X-Auth", token);
            conn.setRequestProperty("Accept", "application/octet-stream");
            
            InputStream input = conn.getInputStream();
            FileOutputStream output = new FileOutputStream(localPath);
            
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = input.read(buffer)) != -1) {
                output.write(buffer, 0, bytesRead);
            }
            
            input.close();
            output.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

### iOS Example (Swift)

```swift
import Foundation

class FileServerClient {
    let baseUrl = "http://192.168.50.100:8080"
    let token = "YOUR_API_TOKEN"
    
    func downloadFile(remotePath: String, localPath: String) {
        let url = URL(string: "\(baseUrl)/api/resources\(remotePath)")!
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "X-Auth")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                try? data.write(to: URL(fileURLWithPath: localPath))
            }
        }.resume()
    }
}
```

---

## 🐍 Python Integration

### Basic Client Class

```python
import requests
import json
from pathlib import Path

class FileServerClient:
    def __init__(self, base_url, token):
        self.base_url = base_url.rstrip('/')
        self.headers = {'X-Auth': token}
    
    def list_files(self, path='/'):
        """List files and directories"""
        response = requests.get(
            f"{self.base_url}/api/resources",
            headers=self.headers,
            params={'path': path}
        )
        return response.json()
    
    def download_file(self, remote_path, local_path):
        """Download a file"""
        response = requests.get(
            f"{self.base_url}/api/resources{remote_path}",
            headers={**self.headers, 'Accept': 'application/octet-stream'}
        )
        with open(local_path, 'wb') as f:
            f.write(response.content)
    
    def upload_file(self, local_path, remote_path):
        """Upload a file"""
        with open(local_path, 'rb') as f:
            files = {'file': f}
            response = requests.post(
                f"{self.base_url}/api/resources{remote_path}",
                headers=self.headers,
                files=files
            )
        return response.json()
    
    def create_directory(self, path):
        """Create a directory"""
        response = requests.post(
            f"{self.base_url}/api/resources{path}",
            headers={**self.headers, 'Content-Type': 'application/json'},
            json={'dir': True}
        )
        return response.json()
    
    def delete_file(self, path):
        """Delete a file or directory"""
        response = requests.delete(
            f"{self.base_url}/api/resources{path}",
            headers=self.headers
        )
        return response.json()

# Usage example
client = FileServerClient('http://192.168.50.100:8080', 'YOUR_TOKEN')

# List files
files = client.list_files('/games')
print(files)

# Download a file
client.download_file('/games/save1.sav', '/local/save1.sav')

# Upload a file
client.upload_file('/local/mod.zip', '/games/mods/mod.zip')
```

---

## 🔧 Error Handling

### Common HTTP Status Codes

- **200 OK:** Request successful
- **201 Created:** Resource created successfully
- **400 Bad Request:** Invalid request parameters
- **401 Unauthorized:** Invalid or missing authentication token
- **403 Forbidden:** Insufficient permissions
- **404 Not Found:** Resource not found
- **500 Internal Server Error:** Server error

### Error Response Format

```json
{
  "error": "Error message",
  "code": 400
}
```

### Example Error Handling

```python
def safe_api_call(func, *args, **kwargs):
    try:
        response = func(*args, **kwargs)
        if response.status_code == 200:
            return response.json()
        elif response.status_code == 401:
            print("Authentication failed - check your token")
        elif response.status_code == 404:
            print("Resource not found")
        else:
            print(f"API error: {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"Network error: {e}")
    return None
```

---

## 🔒 Security Best Practices

### Token Management

1. **Store tokens securely** - don't hardcode in source code
2. **Use environment variables** for token storage
3. **Rotate tokens periodically** if needed
4. **Don't share tokens** in logs or error messages

### Network Security

1. **Use HTTPS** if accessing from internet (future enhancement)
2. **Validate server certificates** in production
3. **Use secure token storage** on mobile devices
4. **Implement request rate limiting** in applications

### Example Secure Token Storage

```python
import os
from getpass import getpass

# Get token from environment variable
token = os.getenv('FILESERVER_TOKEN')

# Or prompt user for token
if not token:
    token = getpass("Enter file server token: ")

client = FileServerClient('http://192.168.50.100:8080', token)
```

---

## 📊 Performance Considerations

### Request Optimization

1. **Use appropriate content types** for different operations
2. **Implement retry logic** for failed requests
3. **Use streaming** for large file downloads
4. **Batch operations** when possible

### Example Streaming Download

```python
def download_large_file(self, remote_path, local_path):
    """Download large file with streaming"""
    response = requests.get(
        f"{self.base_url}/api/resources{remote_path}",
        headers={**self.headers, 'Accept': 'application/octet-stream'},
        stream=True
    )
    
    with open(local_path, 'wb') as f:
        for chunk in response.iter_content(chunk_size=8192):
            if chunk:
                f.write(chunk)
```

---

## 🧪 Testing

### Test API Connectivity

```bash
# Test basic connectivity
curl -H "X-Auth: YOUR_TOKEN" \
     "http://192.168.50.100:8080/api/resources"

# Test file upload
echo "test content" > test.txt
curl -H "X-Auth: YOUR_TOKEN" \
     -F "file=@test.txt" \
     "http://192.168.50.100:8080/api/resources/"

# Test file download
curl -H "X-Auth: YOUR_TOKEN" \
     -H "Accept: application/octet-stream" \
     "http://192.168.50.100:8080/api/resources/test.txt" \
     -o downloaded_test.txt
```

### Python Test Script

```python
def test_api_connection():
    client = FileServerClient('http://192.168.50.100:8080', 'YOUR_TOKEN')
    
    # Test list files
    files = client.list_files()
    print(f"Found {len(files)} items in root directory")
    
    # Test create directory
    result = client.create_directory('/test_dir')
    print(f"Created directory: {result}")
    
    # Test upload file
    with open('test.txt', 'w') as f:
        f.write('Hello, File Server!')
    
    result = client.upload_file('test.txt', '/test_dir/test.txt')
    print(f"Uploaded file: {result}")
    
    # Test download file
    client.download_file('/test_dir/test.txt', 'downloaded_test.txt')
    print("Downloaded file successfully")
    
    # Cleanup
    client.delete_file('/test_dir/test.txt')
    client.delete_file('/test_dir')
    print("Cleanup completed")

if __name__ == "__main__":
    test_api_connection()
```

---

## 📚 Related Documentation

- **[Token Management](token-management.md)** - Detailed token procedures
- **[Python Examples](examples/python-client.md)** - Python integration examples
- **[Shell Scripts](examples/shell-scripts.md)** - Bash automation examples
- **[Mobile Integration](examples/mobile-integration.md)** - Mobile app patterns

---

**Last Updated:** 2025-01-22  
**Status:** Complete  
**Next:** Create integration examples and test API access
