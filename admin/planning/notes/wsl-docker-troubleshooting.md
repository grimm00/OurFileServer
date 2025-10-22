# WSL Docker Troubleshooting Guide

**Purpose:** Troubleshoot WSL and Docker volume mounting issues  
**Status:** Ready to Use  
**Last Updated:** 2025-01-06  
**Priority:** High

---

## 🚨 **Current Issues**

1. **Markdown formatting not displaying properly**
2. **WSL not showing Windows drive mounts**
3. **Docker volume mounting failing**

---

## 🔍 **WSL Mount Investigation**

### **Step 1: Check WSL Version**

```bash
# Check WSL version
wsl --version

# Check which WSL distro you're using
wsl --list --verbose
```

### **Step 2: Check Available Mounts**

```bash
# List all mounted drives
ls /mnt/

# Check if Windows drives are accessible
ls /mnt/c/
ls /mnt/d/
ls /mnt/e/
ls /mnt/f/
ls /mnt/g/
ls /mnt/s/
```

### **Step 3: Check WSL Integration**

```bash
# Check if Docker is running in WSL
docker --version

# Check Docker context
docker context ls

# Check if Docker Desktop is integrated
docker info | grep -i wsl
```

---

## 🔧 **WSL Mount Solutions**

### **Solution 1: Enable WSL Integration in Docker Desktop**

1. **Open Docker Desktop**
2. **Go to Settings → Resources → WSL Integration**
3. **Enable integration with your WSL distro**
4. **Click "Apply & Restart"**

### **Solution 2: Manually Mount Windows Drives**

If drives aren't showing in `/mnt/`:

```bash
# Create mount points
sudo mkdir -p /mnt/s
sudo mkdir -p /mnt/c

# Mount Windows drives (if not auto-mounted)
sudo mount -t drvfs S: /mnt/s
sudo mount -t drvfs C: /mnt/c
```

### **Solution 3: Use Windows Path Directly**

If WSL mounting is problematic, use Windows paths directly:

```bash
# Access Windows files through WSL
ls /mnt/c/Users/YourUsername/
ls /mnt/c/Users/YourUsername/AppData/Local/Packages/
```

---

## 🐳 **Docker Volume Mount Solutions**

### **Option 1: Use WSL Paths (If Mounts Work)**

```bash
# Create directories first
mkdir -p /mnt/c/fileserver/config
mkdir -p /mnt/s/gaming
mkdir -p /mnt/s/documents
mkdir -p /mnt/s/media

# Run Docker with WSL paths
docker run -d \
  --name filebrowser \
  -p 8080:80 \
  -v "/mnt/s/:/srv" \
  -v "/mnt/c/fileserver/config/database.db:/database.db" \
  --restart unless-stopped \
  filebrowser/filebrowser:latest
```

### **Option 2: Use WSL Home Directory**

```bash
# Create directories in WSL home
mkdir -p ~/fileserver/data
mkdir -p ~/fileserver/config

# Run Docker with WSL home paths
docker run -d \
  --name filebrowser \
  -p 8080:80 \
  -v "~/fileserver/data:/srv" \
  -v "~/fileserver/config/database.db:/database.db" \
  --restart unless-stopped \
  filebrowser/filebrowser:latest
```

### **Option 3: Use Windows Docker Desktop**

**Switch to Windows Command Prompt (not WSL):**

```cmd
# Create directories
mkdir C:\fileserver\config
mkdir S:\gaming
mkdir S:\documents
mkdir S:\media

# Run Docker with Windows paths
docker run -d --name filebrowser -p 8080:80 -v "S:\:/srv" -v "C:\fileserver\config\database.db:/database.db" --restart unless-stopped filebrowser/filebrowser:latest
```

---

## 🔍 **Diagnostic Commands**

### **Check WSL Status**

```bash
# Check WSL status
wsl --status

# Check WSL distro info
wsl --list --verbose

# Check WSL version
wsl --version
```

### **Check Docker Status**

```bash
# Check Docker version
docker --version

# Check Docker info
docker info

# Check running containers
docker ps

# Check Docker context
docker context ls
```

### **Check File System**

```bash
# Check available space
df -h

# Check mounted filesystems
mount | grep -i windows
mount | grep -i drvfs

# Check permissions
ls -la /mnt/
```

---

## 🎯 **Recommended Approach**

### **Step 1: Determine Your Setup**

```bash
# Run these commands and share the output
echo "WSL Version:"
wsl --version

echo "WSL Distros:"
wsl --list --verbose

echo "Docker Version:"
docker --version

echo "Docker Context:"
docker context ls

echo "Available Mounts:"
ls /mnt/

echo "Docker Info:"
docker info | grep -i wsl
```

### **Step 2: Choose Best Solution**

**If WSL mounts work:**
- Use WSL paths (`/mnt/s/`, `/mnt/c/`)

**If WSL mounts don't work:**
- Use WSL home directory (`~/fileserver/`)
- Or switch to Windows Docker Desktop

**If Docker Desktop integration is enabled:**
- Use Windows paths in WSL
- Or use Windows Command Prompt

---

## 🚀 **Quick Test Commands**

### **Test 1: Check WSL Mounts**

```bash
# Test if you can access Windows files
ls /mnt/c/Users/
ls /mnt/s/
```

### **Test 2: Test Docker Volume Mount**

```bash
# Test simple volume mount
docker run --rm -v /mnt/c:/test alpine ls /test
```

### **Test 3: Test Filebrowser Container**

```bash
# Test Filebrowser with simple mount
docker run --rm -p 8080:80 -v /mnt/c:/srv filebrowser/filebrowser:latest
```

---

## 📞 **Next Steps**

1. **Run the diagnostic commands** above
2. **Share the output** so I can help identify the issue
3. **Try the recommended approach** based on your setup
4. **Test with simple commands** before running the full setup

---

## 🔧 **Alternative: Use Windows Docker Desktop**

If WSL is causing too many issues:

1. **Open Windows Command Prompt** (not WSL)
2. **Use Windows paths directly**
3. **Run Docker commands in Windows**

```cmd
# Windows Command Prompt
docker run -d --name filebrowser -p 8080:80 -v "S:\:/srv" -v "C:\fileserver\config\database.db:/database.db" --restart unless-stopped filebrowser/filebrowser:latest
```

---

**Last Updated:** 2025-01-06  
**Status:** Ready to Use  
**Next:** Run diagnostic commands and share output


