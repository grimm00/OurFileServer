# External Drive Partitioning Instructions

**Purpose:** Step-by-step guide for creating 500GB partition on external drive  
**Status:** Ready to Use  
**Last Updated:** 2025-01-06  
**Priority:** High

---

## 🚨 **IMPORTANT: Click "NO" on Dynamic Disk Warning**

If you see a Windows warning about converting to dynamic disks, **click "NO"** - we want to keep it as a basic disk.

---

## 🔧 **Method 1: Using Diskpart (Recommended)**

This method bypasses the dynamic disk conversion issue entirely.

### Step 1: Open Command Prompt as Administrator

1. Press `Windows + X`
2. Select **"Command Prompt (Admin)"** or **"PowerShell (Admin)"**
3. Click **"Yes"** when prompted by User Account Control

### Step 2: Run Diskpart

```cmd
diskpart
```

### Step 3: List All Disks

```cmd
list disk
```

**Look for your external drive** - it will show as Disk 1, Disk 2, etc. Note the disk number.

### Step 4: Select Your External Drive

```cmd
select disk X
```

**Replace X with your external drive number** (e.g., `select disk 1`)

### Step 5: Create the Partition

```cmd
create partition primary size=512000
```

This creates a 500GB partition (512000 MB = 500 GB)

### Step 6: Assign Drive Letter

```cmd
assign letter=E
```

**Replace E with your preferred drive letter** (make sure it's not already in use)

### Step 7: Format the Partition

```cmd
format fs=ntfs quick label="FileServerStorage"
```

### Step 8: Exit Diskpart

```cmd
exit
```

### Step 9: Verify the Partition

1. Open **File Explorer**
2. Look for your new drive with the label "FileServerStorage"
3. It should show approximately 500GB of free space

---

## 🖥️ **Method 2: Using Disk Management (Alternative)**

If Diskpart doesn't work, try this method:

### Step 1: Open Disk Management

1. Press `Windows + R`
2. Type `diskmgmt.msc`
3. Press **Enter**

### Step 2: Locate Your External Drive

- Find your external drive in the list
- Look for **unallocated space** (black bar)

### Step 3: Create New Simple Volume

1. **Right-click** on the unallocated space
2. Select **"New Simple Volume..."**
3. Click **"Next"**

### Step 4: Set Volume Size

1. In the **"Specify Volume Size"** dialog:
   - Maximum disk space: Should show your available space
   - Simple volume size in MB: Enter **512000** (for 500GB)
2. Click **"Next"**

### Step 5: Assign Drive Letter

1. Select **"Assign the following drive letter"**
2. Choose an available letter (e.g., E, F, G)
3. Click **"Next"**

### Step 6: Format the Volume

1. Select **"Format this volume with the following settings"**
2. File system: **NTFS**
3. Allocation unit size: **Default**
4. Volume label: **FileServerStorage**
5. Check **"Perform a quick format"**
6. Click **"Next"**

### Step 7: Complete the Wizard

1. Review your settings
2. Click **"Finish"**

---

## 🔍 **Troubleshooting Common Issues**

### Issue 1: "New Simple Volume" is Grayed Out

**Cause:** Disk might be using MBR partition style with limitations

**Solution:**
1. Right-click on the **disk** (not partition) in Disk Management
2. Select **"Convert to GPT Disk"**
3. **Warning:** This will erase all data on the drive

### Issue 2: Dynamic Disk Conversion Warning

**Solution:** Click **"NO"** - we want to keep it as a basic disk

### Issue 3: Not Enough Space

**Check:**
1. How much total space does your external drive have?
2. How much space is already used by existing partitions?
3. You need at least 500GB of free space

### Issue 4: Drive Letter Already in Use

**Solution:**
1. Choose a different drive letter (F, G, H, etc.)
2. Or change an existing drive letter in Disk Management

---

## ✅ **Verification Steps**

After creating the partition:

### Step 1: Check in File Explorer

1. Open **File Explorer**
2. Look for your new drive
3. It should show:
   - Drive letter: E (or whatever you chose)
   - Label: FileServerStorage
   - Size: Approximately 500GB

### Step 2: Test Write Access

1. Right-click on the new drive
2. Select **"New" → "Folder"**
3. Name it **"test"**
4. If successful, delete the test folder

### Step 3: Check Properties

1. Right-click on the new drive
2. Select **"Properties"**
3. Verify:
   - File system: NTFS
   - Used space: 0 bytes
   - Free space: ~500GB

---

## 🐳 **Next Steps: Docker Integration**

Once your partition is created, update your Docker setup:

### Windows Docker Command

```bash
docker run -d \
  --name filebrowser \
  -p 8080:80 \
  -v "E:\FileServerStorage:/srv" \
  -v "C:\fileserver\config\database.db:/database.db" \
  --restart unless-stopped \
  filebrowser/filebrowser:latest
```

**Replace E: with your actual drive letter**

### Create Folder Structure

```cmd
mkdir "E:\FileServerStorage\gaming"
mkdir "E:\FileServerStorage\gaming\mods"
mkdir "E:\FileServerStorage\gaming\roms"
mkdir "E:\FileServerStorage\gaming\saves"
mkdir "E:\FileServerStorage\documents"
mkdir "E:\FileServerStorage\media"
mkdir "E:\FileServerStorage\temp"
```

---

## 📞 **Need Help?**

If you encounter issues:

1. **Take a screenshot** of the error message
2. **Note which step** you were on
3. **Check the troubleshooting section** above
4. **Try the alternative method** if one doesn't work

Common solutions:
- Use Diskpart instead of Disk Management
- Click "NO" on dynamic disk warnings
- Ensure you have enough free space
- Choose a different drive letter

---

**Last Updated:** 2025-01-06  
**Status:** Ready to Use  
**Next:** Follow these steps to create your 500GB partition


