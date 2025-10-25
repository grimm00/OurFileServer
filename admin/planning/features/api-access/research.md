# Filebrowser API Authentication Research

**Purpose:** Research Filebrowser authentication methods for API access  
**Status:** Complete  
**Last Updated:** 2025-01-22  
**Priority:** High

---

## 📋 Overview

This document researches Filebrowser's authentication system, focusing on JWT token configuration, session management, and API access for external applications.

---

## 🔍 Authentication Methods

### Current Setup (No Authentication)
```yaml
environment:
  - FB_NOAUTH=true
```

**Limitations:**
- No API access for external applications
- No token-based authentication
- All access is anonymous

### Target Setup (JWT Authentication)
```yaml
environment:
  - FB_JWT_SIGNING_KEY=your-secure-random-key-here
  # Remove FB_NOAUTH=true
```

**Benefits:**
- API token generation
- Long-lasting sessions
- External application access
- Maintains web interface usability

---

## 🔐 JWT Token Configuration

### Token Expiration Settings

Filebrowser supports configurable JWT token expiration:

```json
{
  "token": {
    "expiry": "8760h"  // 1 year
  }
}
```

**Recommended Settings for Home Use:**
- **1 Year**: `"8760h"` - Login once per device per year
- **10 Years**: `"87600h"` - Essentially permanent for home use
- **Default**: `"72h"` - Too short for home convenience

### JWT Signing Key

**Requirements:**
- Must be a secure random string
- Minimum 32 characters recommended
- Same key must be used consistently
- Store securely (environment variable)

**Generation:**
```bash
# Generate secure random key
openssl rand -base64 32
# or
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

---

## 👥 User Account Management

### Single Admin Account Approach

**Command to Create Admin User:**
```bash
docker compose exec filebrowser filebrowser users add admin [password] --perm.admin
```

**Permissions for Admin Account:**
- Full file system access
- User management
- API token generation
- System configuration

### Multi-User Approach (Deferred)

**Future Enhancement:**
```bash
# Regular user (read/write files only)
docker compose exec filebrowser filebrowser users add partner [password]

# Guest user (read-only)
docker compose exec filebrowser filebrowser users add guest [password] --perm.download
```

---

## 🌐 Session Management

### Browser Session Persistence

**How It Works:**
1. User logs in with credentials
2. Filebrowser generates JWT token
3. Token stored in browser localStorage
4. Token persists across browser restarts
5. Token valid until expiration (1+ year)

**Browser Behavior:**
- **Chrome/Edge**: localStorage persists indefinitely
- **Firefox**: localStorage persists indefinitely
- **Mobile Browsers**: localStorage persists indefinitely
- **Private/Incognito**: Lost when session ends

### "Remember Me" Functionality

**Implementation:**
- JWT token automatically stored in browser
- No additional checkbox needed
- Token persists until expiration
- Can be cleared by explicit logout

---

## 🔌 API Access

### Authentication Headers

**Required Header:**
```
X-Auth: [JWT_TOKEN]
```

**Alternative (if supported):**
```
Authorization: Bearer [JWT_TOKEN]
```

### Token Generation

**Method 1: Through Web Interface**
1. Login to Filebrowser web interface
2. Go to Settings → API
3. Generate new token
4. Copy token for use in applications

**Method 2: Through CLI**
```bash
# Generate token for specific user
docker compose exec filebrowser filebrowser users token admin
```

### API Endpoints

**Common Endpoints:**
- `GET /api/resources` - List files/directories
- `POST /api/resources` - Upload files
- `GET /api/resources/{path}` - Download files
- `PUT /api/resources/{path}` - Update files
- `DELETE /api/resources/{path}` - Delete files

---

## 📁 File System Impact

### Authentication Layer

**Important:** Authentication is at the **application layer only**

**What Stays the Same:**
- Files on `/mnt/s/fileserver/` remain unchanged
- File permissions on disk unchanged
- File ownership unchanged
- Directory structure unchanged

**What Changes:**
- Access control at Filebrowser level
- API authentication required
- Web interface requires login

### User Directory Creation

**Configuration:**
```json
{
  "createUserDir": false
}
```

**Result:**
- No per-user directories created
- All users access same file system
- Maintains current file organization

---

## 🔒 Security Considerations

### Home Network Security

**Current Risk Level:** Low (trusted home network)
**After Auth:** Same risk level, but with access control

**Benefits:**
- Can revoke access if device lost
- API tokens can be rotated
- Audit trail of access
- Protection against accidental external access

### Token Security

**Best Practices:**
- Store tokens securely in applications
- Rotate tokens periodically (optional for home)
- Use HTTPS if accessing from internet (future)
- Monitor token usage

---

## ⚡ Performance Impact

### Session Management

**Overhead:**
- Minimal JWT validation on each request
- Token stored in memory
- No database queries for session validation

**Performance:**
- Negligible impact on file operations
- Same performance as no-auth for web interface
- Slight overhead for API requests (token validation)

---

## 🔄 Migration Considerations

### From No-Auth to JWT Auth

**Steps:**
1. Update docker-compose.yml
2. Create settings.json with JWT config
3. Restart container
4. Create admin user
5. Login on all devices once
6. Generate API tokens

**Rollback Plan:**
1. Restore `FB_NOAUTH=true`
2. Remove JWT configuration
3. Restart container
4. Immediate return to no-auth

### Data Preservation

**Files:** Completely untouched
**Configuration:** Only Filebrowser config changes
**Users:** Need to login once after migration

---

## 📊 Comparison: No-Auth vs JWT Auth

| Aspect | No-Auth | JWT Auth |
|--------|---------|----------|
| **Web Access** | Immediate | Login once per device |
| **API Access** | None | Full API with tokens |
| **Security** | None | Token-based |
| **File Access** | Direct | Same (app-layer only) |
| **Performance** | Fastest | Same (minimal overhead) |
| **Automation** | None | Full API automation |
| **User Management** | None | Single or multi-user |
| **Session Duration** | N/A | 1+ year configurable |

---

## 🎯 Recommendations

### For Home Network Use

**Recommended Configuration:**
- **JWT Expiration**: 8760h (1 year) or 87600h (10 years)
- **User Accounts**: Single admin account shared by all
- **Token Storage**: Browser localStorage (automatic)
- **API Tokens**: Generate as needed for automation

### Implementation Priority

1. **Phase 1**: Single admin account with long sessions
2. **Phase 2**: API token generation and documentation
3. **Phase 3**: Example integrations (Python, shell scripts)
4. **Future**: Multi-user accounts if needed

---

## 📚 References

- [Filebrowser Documentation](https://filebrowser.org/)
- [JWT Token Configuration](https://filebrowser.org/configuration)
- [API Documentation](https://filebrowser.org/api)
- [User Management](https://filebrowser.org/cli/filebrowser-users)

---

**Last Updated:** 2025-01-22  
**Status:** Research Complete  
**Next:** Create feature specification and implementation plan
