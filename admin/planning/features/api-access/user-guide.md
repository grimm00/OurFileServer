# User Guide: Shared Admin Account

**Purpose:** Simple guide for using the shared admin account  
**Status:** Complete  
**Last Updated:** 2025-01-22  
**Priority:** High

---

## 📋 Overview

This guide explains how to use the file server with the new shared admin account. The setup is designed to be as simple as possible while enabling API access for automation.

---

## 🔑 Shared Credentials

**Everyone uses the same login:**
- **Username:** `admin`
- **Password:** `cEGiUWGN48mC3jGO`

**Who uses these credentials:**
- You (the administrator)
- Your partner
- All devices (laptop, phone, Steam Deck, etc.)
- Any automation scripts or applications

---

## 🌐 Web Interface Access

### First Time Login

1. **Open your browser**
2. **Go to:** `http://[your-ip]:8080`
3. **Enter credentials:**
   - Username: `admin`
   - Password: `cEGiUWGN48mC3jGO`
4. **Click "Login"**

### After Login

- **You're logged in for 1 year** - no need to login again
- **Use the file server exactly as before**
- **All your files are in the same place**
- **Same performance and functionality**

### On Each Device

**Login once on each device:**
- [ ] Your laptop browser
- [ ] Your partner's laptop browser  
- [ ] Your phone browser
- [ ] Your partner's phone browser
- [ ] Steam Deck browser
- [ ] Any other devices

**After that:** Each device stays logged in automatically for 1 year.

---

## 📱 Mobile Access

### Phone/Tablet Browser

1. **Open browser** (Chrome, Safari, Firefox, etc.)
2. **Go to:** `http://[your-ip]:8080`
3. **Login with shared credentials**
4. **Bookmark the page** for easy access
5. **Stay logged in** - no need to login again

### Mobile App Integration

If you want to create a mobile app:
- **Use the API** with authentication tokens
- **Generate tokens** from the web interface
- **Include token** in app requests

---

## 🎮 Steam Deck Access

### Browser Access

1. **Open browser** on Steam Deck
2. **Go to:** `http://[your-ip]:8080`
3. **Login with shared credentials**
4. **Access your game files** (mods, saves, ROMs)
5. **Stay logged in** for easy access

### Game Integration

- **Download mods** directly to Steam Deck
- **Upload save files** from Steam Deck
- **Share ROMs** between devices
- **All using the same shared account**

---

## 🔧 API Access for Automation

### What is API Access?

API access lets external applications (scripts, apps, tools) access your files programmatically.

### When to Use API Access

- **Automated backups** - scripts that backup files
- **File synchronization** - sync files between devices
- **Mobile apps** - custom apps for file access
- **Integration tools** - connect with other services

### How to Get API Access

1. **Login to web interface**
2. **Go to Settings** (gear icon)
3. **Find "API" section**
4. **Generate new token**
5. **Copy the token**
6. **Use token in your applications**

### Example API Usage

**List files:**
```bash
curl -H "X-Auth: YOUR_TOKEN" http://[your-ip]:8080/api/resources
```

**Upload file:**
```bash
curl -H "X-Auth: YOUR_TOKEN" -F "file=@myfile.txt" http://[your-ip]:8080/api/resources
```

---

## 🔒 Security for Home Use

### Is This Secure?

**For home network use:** Yes, this is secure and appropriate.

**Why it's secure:**
- **Home network only** - not accessible from internet
- **Trusted users** - you and your partner
- **Can revoke access** - if device is lost
- **Audit trail** - can see who accessed what

### What Changed Security-Wise

**Before:** Anyone on your network could access files
**After:** Only people with the shared password can access files

**Benefits:**
- **Protection** if someone else connects to your network
- **Control** over who can access your files
- **API access** for automation while maintaining security

---

## 🆘 Common Questions

### Q: Do I need to login every time?
**A:** No! Login once per device, stay logged in for 1 year.

### Q: What if I forget the password?
**A:** The password is `cEGiUWGN48mC3jGO`. You can change it if you want.

### Q: Can I change the password?
**A:** Yes, but everyone will need the new password. See the operations guide.

### Q: What if I get logged out?
**A:** Just login again with the same credentials. Sessions last 1 year, so this should be rare.

### Q: Can I have separate accounts for different people?
**A:** Not in the current setup. Everyone shares the same admin account for simplicity.

### Q: What if I want separate accounts later?
**A:** That's possible but more complex. The current setup is designed for simplicity.

### Q: Do my files change?
**A:** No! All your files are exactly the same. Only the access method changed.

### Q: Is this slower than before?
**A:** No, same performance. The authentication adds minimal overhead.

---

## 🔄 What to Do If Something Goes Wrong

### Can't Login

1. **Check password:** Make sure it's exactly `cEGiUWGN48mC3jGO`
2. **Check username:** Make sure it's exactly `admin`
3. **Try different browser:** Sometimes browser cache causes issues
4. **Clear browser data:** Clear cookies and localStorage

### Lost Access

1. **Check if container is running:** `docker compose ps`
2. **Restart container:** `docker compose restart`
3. **Check logs:** `docker compose logs filebrowser`

### Want to Go Back to No-Auth

1. **Follow rollback guide** in migration documentation
2. **This will remove authentication** and return to direct access
3. **All files remain the same**

---

## 📚 Getting Help

### Documentation

- **[Migration Guide](migration-guide.md)** - How the change was made
- **[API Documentation](api-documentation.md)** - For developers
- **[Operations Guide](../../../operations/api-management.md)** - For administrators

### Quick Commands

**Check if server is running:**
```bash
docker compose ps
```

**Restart server:**
```bash
docker compose restart
```

**View server logs:**
```bash
docker compose logs filebrowser
```

---

## 🎯 Summary

### What You Need to Do

1. **Login once on each device** with shared credentials
2. **Use the file server exactly as before**
3. **Stay logged in for 1 year** on each device
4. **Generate API tokens** if you need automation

### What Stays the Same

- **All your files** are in the same place
- **Same performance** and functionality
- **Same network access** and ports
- **Same file operations** (upload, download, create, delete)

### What's New

- **Login required** (but only once per device per year)
- **API access** for automation and external applications
- **Better security** for your home network
- **Token-based authentication** for scripts and apps

---

**Last Updated:** 2025-01-22  
**Status:** Ready for Use  
**Next:** Login on all your devices and start using the file server
