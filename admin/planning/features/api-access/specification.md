# API Access Authentication Specification

**Purpose:** Feature specification for API access with single shared admin account  
**Status:** Complete  
**Last Updated:** 2025-01-22  
**Priority:** High

---

## 📋 Overview

This specification defines the API access authentication feature for the OurFileServer project. The solution enables external application access while maintaining simplicity through a single shared admin account with long-lasting sessions.

---

## 🎯 Problem Statement

### Current State
- File server uses `FB_NOAUTH=true` for easy access
- No API access for external applications
- No token-based authentication
- All access is anonymous

### Requirements
- Enable API access for external applications
- Maintain ease of use for home network
- Preserve existing file structure
- Minimize user friction

---

## 👥 User Stories

### Primary Users

**As a home user (you and your partner), I want to:**
- Access the file server with minimal friction
- Login once per device and stay logged in
- Use the same credentials across all devices
- Have the same experience as the current no-auth setup

**As a developer, I want to:**
- Generate API tokens for automation scripts
- Access files programmatically via HTTP API
- Upload and download files through code
- Integrate with mobile applications

**As an administrator, I want to:**
- Manage a single admin account for simplicity
- Generate and revoke API tokens as needed
- Monitor API usage if required
- Maintain security for home network use

### Acceptance Criteria

- [ ] Single admin account shared by all users
- [ ] Login once per device, stay logged in for 1+ year
- [ ] API tokens can be generated from admin account
- [ ] External applications can authenticate with tokens
- [ ] All existing files remain untouched
- [ ] Same performance as current setup
- [ ] Can rollback to no-auth if needed

---

## 🔧 Technical Requirements

### Authentication Method
- **Type**: JWT (JSON Web Token) authentication
- **Session Duration**: 8760h (1 year) or 87600h (10 years)
- **User Management**: Single admin account
- **Token Storage**: Browser localStorage (automatic)

### Configuration Requirements

**Docker Compose Changes:**
```yaml
environment:
  - FB_ROOT=/srv
  - FB_JWT_SIGNING_KEY=your-secure-random-key-here
  # Remove: - FB_NOAUTH=true
```

**Settings Configuration:**
```json
{
  "signup": false,
  "createUserDir": false,
  "authMethod": "json",
  "token": {
    "expiry": "8760h"
  }
}
```

### API Requirements

**Authentication Header:**
```
X-Auth: [JWT_TOKEN]
```

**Supported Endpoints:**
- `GET /api/resources` - List files/directories
- `POST /api/resources` - Upload files
- `GET /api/resources/{path}` - Download files
- `PUT /api/resources/{path}` - Update files
- `DELETE /api/resources/{path}` - Delete files

---

## 🏗️ Architecture

### Single Account Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Web Browser   │    │   Mobile App     │    │  Python Script  │
│                 │    │                  │    │                 │
│ Username: admin │    │ Username: admin  │    │ API Token: xyz  │
│ Password: 123   │    │ Password: 123    │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Filebrowser Server                          │
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │   JWT Session   │    │   API Token     │                    │
│  │   (1+ year)     │    │   (persistent)  │                    │
│  └─────────────────┘    └─────────────────┘                    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │              File System Access                            ││
│  │         /mnt/s/fileserver/ (unchanged)                     ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Web Access**: User logs in once → JWT token stored in browser → Access files
2. **API Access**: Generate token from admin account → Use in HTTP headers → Access files
3. **File Access**: All access goes through same file system, no changes to files

---

## 🔒 Security Model

### Home Network Security

**Risk Level**: Low (trusted home network)
**Security Model**: Token-based access control

**Benefits:**
- Can revoke access if device is lost
- API tokens can be rotated
- Audit trail of access
- Protection against accidental external access

**Trade-offs:**
- Slightly more complex than no-auth
- Requires initial login on each device
- Need to manage admin password

### Token Security

**JWT Token:**
- Signed with secure key
- Long expiration (1+ year)
- Stored in browser localStorage
- Can be revoked by regenerating

**API Token:**
- Generated from admin account
- Persistent until manually revoked
- Used in HTTP headers
- Stored securely in applications

---

## 📊 Performance Requirements

### Response Time
- **Web Interface**: Same as current (no measurable difference)
- **API Requests**: < 100ms additional overhead for token validation
- **File Operations**: Same performance as current setup

### Resource Usage
- **Memory**: Minimal JWT validation overhead
- **CPU**: Negligible impact
- **Storage**: No additional storage requirements

### Scalability
- **Concurrent Users**: Same as current (limited by hardware)
- **API Requests**: Limited by network and disk I/O
- **Token Validation**: Minimal overhead per request

---

## 🧪 Testing Requirements

### Functional Testing

**Web Interface:**
- [ ] Login with admin credentials
- [ ] Session persists across browser restarts
- [ ] Access files and directories
- [ ] Upload and download files
- [ ] Create and delete directories

**API Access:**
- [ ] Generate API token from admin account
- [ ] Use token in HTTP headers
- [ ] List files via API
- [ ] Upload file via API
- [ ] Download file via API
- [ ] Delete file via API

**Cross-Device Testing:**
- [ ] Login on laptop browser
- [ ] Login on phone browser
- [ ] Login on Steam Deck browser
- [ ] Sessions persist independently

### Performance Testing

- [ ] Measure response time for web interface
- [ ] Measure response time for API requests
- [ ] Verify no performance degradation
- [ ] Test with large file uploads/downloads

### Security Testing

- [ ] Verify JWT token validation
- [ ] Test API token authentication
- [ ] Verify access control
- [ ] Test token expiration

---

## 🚀 Implementation Phases

### Phase 1: Core Implementation (Current)

**Scope:**
- Single admin account
- Long-lasting sessions
- Basic API access
- Documentation

**Deliverables:**
- Updated docker-compose.yml
- Settings configuration
- Admin account creation
- Basic API documentation

### Phase 2: Integration Examples (Current)

**Scope:**
- Python client examples
- Shell script examples
- Mobile integration patterns
- Comprehensive documentation

**Deliverables:**
- Example integrations
- API documentation
- User guides
- Operations documentation

### Phase 3: Future Enhancements (Deferred)

**Scope:**
- Multi-user accounts
- Per-user permissions
- Activity tracking
- Advanced access control

**Deliverables:**
- Multi-user setup guide
- Permission management
- Activity monitoring
- Advanced security features

---

## 📋 Success Criteria

### Primary Success Criteria

- [ ] **User Experience**: Login once per device, stay logged in for months
- [ ] **API Access**: External applications can authenticate and access files
- [ ] **File Preservation**: All existing files remain completely untouched
- [ ] **Performance**: No measurable performance degradation
- [ ] **Simplicity**: Single shared account for all users

### Secondary Success Criteria

- [ ] **Documentation**: Complete documentation for users and developers
- [ ] **Examples**: Working integration examples
- [ ] **Operations**: Clear operational procedures
- [ ] **Rollback**: Ability to return to no-auth if needed

### Future Success Criteria

- [ ] **Multi-User**: Path documented for future multi-user setup
- [ ] **Scalability**: Can scale to internet access if needed
- [ ] **Security**: Enhanced security features available
- [ ] **Monitoring**: Usage monitoring and analytics

---

## 🔄 Migration Strategy

### Pre-Migration

1. **Backup**: Ensure file server is backed up
2. **Documentation**: Review migration guide
3. **Testing**: Test in development environment (if available)

### Migration Steps

1. **Update Configuration**: Modify docker-compose.yml and create settings.json
2. **Restart Container**: Apply new configuration
3. **Create Admin Account**: Set up shared admin account
4. **Test Access**: Verify web interface works
5. **Login on Devices**: Login once on each device
6. **Generate API Tokens**: Create tokens for automation

### Post-Migration

1. **Verify Functionality**: Test all features
2. **Document Credentials**: Record admin password securely
3. **Update Documentation**: Update any relevant documentation
4. **Monitor**: Watch for any issues

### Rollback Plan

1. **Restore Configuration**: Revert docker-compose.yml changes
2. **Remove Settings**: Delete settings.json
3. **Restart Container**: Apply no-auth configuration
4. **Verify Access**: Confirm direct access works

---

## 📚 Dependencies

### Technical Dependencies

- **Filebrowser**: Version 2.44.1+ (current version supports JWT)
- **Docker**: Current Docker setup
- **Network**: Existing network configuration
- **Storage**: Existing file system setup

### Documentation Dependencies

- **Research**: Filebrowser JWT configuration research
- **Examples**: Integration examples for different platforms
- **Operations**: Server administration procedures
- **User Guides**: Simple user instructions

---

## 🎯 Future Considerations

### Multi-User Enhancement

**When to Consider:**
- Need for separate user permissions
- Activity tracking requirements
- Access control for different users
- Scaling beyond home network

**Implementation Path:**
- Document in future-enhancements.md
- Plan migration from single to multi-user
- Design permission system
- Create user management procedures

### Internet Access

**When to Consider:**
- Need for remote access
- Sharing with external users
- Cloud-like functionality
- Enhanced security requirements

**Additional Requirements:**
- HTTPS/TLS encryption
- Enhanced authentication
- Firewall configuration
- Security monitoring

---

**Last Updated:** 2025-01-22  
**Status:** Specification Complete  
**Next:** Implementation and testing
