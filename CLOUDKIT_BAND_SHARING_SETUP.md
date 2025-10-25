# CloudKit Band Sharing Setup Guide

This guide will help you configure CloudKit to enable band sharing across different Apple IDs in BandPal.

## Overview

BandPal uses CloudKit's **Public Database** to enable band sharing. When a user creates a band, it's registered in the public database with an invite code. Other users can search for and join the band using this code.

## Prerequisites

- Apple Developer account
- BandPal configured with your Team ID
- iCloud capability enabled in your project

## Step 1: Access CloudKit Dashboard

1. Go to [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard/)
2. Sign in with your Apple Developer account
3. Select your app identifier (e.g., `iCloud.com.timooo.BandPal`)
4. Make sure you're viewing the **Production** environment

## Step 2: Create Record Types

You need to create three record types in the Public Database. For each record type:

### 2.1 Create `SharedBand` Record Type

1. Click on **"Schema"** in the sidebar
2. Click **"Record Types"**
3. Click the **"+"** button to add a new record type
4. Name it: `SharedBand`
5. Add the following fields:

| Field Name | Field Type | Options |
|------------|------------|---------|
| `inviteCode` | String | Searchable, Sortable |
| `bandName` | String | - |
| `ownerID` | String | - |
| `createdAt` | Date/Time | - |
| `bandID` | String | - |
| `lastModified` | Date/Time | - |

### 2.2 Create `SharedSetlist` Record Type

1. Click the **"+"** button again
2. Name it: `SharedSetlist`
3. Add the following fields:

| Field Name | Field Type | Options |
|------------|------------|---------|
| `bandCode` | String | Searchable, Sortable |
| `setlistID` | String | - |
| `title` | String | - |
| `date` | Date/Time | Sortable |
| `venue` | String | - |
| `targetDuration` | Int(64) | - |
| `songsData` | String | - |

### 2.3 Create `SharedRehearsal` Record Type

1. Click the **"+"** button again
2. Name it: `SharedRehearsal`
3. Add the following fields:

| Field Name | Field Type | Options |
|------------|------------|---------|
| `bandCode` | String | Searchable, Sortable |
| `rehearsalID` | String | - |
| `date` | Date/Time | Sortable |
| `notes` | String | - |

## Step 3: Configure Indexes

For better performance, create the following indexes:

### For `SharedBand`:
- **RECORDNAME** (this exists by default)
- **inviteCode** (Add Index: Type = QUERYABLE, Ascending)

### For `SharedSetlist`:
- **RECORDNAME** (default)
- **bandCode** (Add Index: Type = QUERYABLE, Ascending)
- **date** (Add Index: Type = SORTABLE, Descending)

### For `SharedRehearsal`:
- **RECORDNAME** (default)
- **bandCode** (Add Index: Type = QUERYABLE, Ascending)
- **date** (Add Index: Type = SORTABLE, Descending)

## Step 4: Set Security Roles

By default, the Public Database has these permissions:
- **World Readable**: Yes ✅ (Users can read any record)
- **World Writable**: Authenticated users only ✅ (Any signed-in iCloud user can write)

This is perfect for band sharing! No changes needed here.

## Step 5: Deploy to Production

1. After creating all record types and indexes in the **Development** environment
2. Click on **"Deploy to Production"** in the top right
3. Review the changes
4. Click **"Deploy"**
5. Wait for deployment to complete (usually takes a few minutes)

## Step 6: Test Band Sharing

### On Device 1 (Band Creator):
1. Open BandPal
2. Tap the **person.2 icon** in the top right of Setlists or Rehearsals view
3. Tap **"+" → "Create Band"**
4. Enter a band name and create it
5. The band will be automatically registered in CloudKit
6. Tap the **info icon** next to the band in the band list
7. Copy or share the **6-character invite code**

### On Device 2 (Band Member):
1. Open BandPal (signed in with a **different Apple ID**)
2. Tap the **person.2 icon**
3. Tap **"+" → "Join Band"**
4. Enter the 6-character invite code
5. Tap **"Join Band"**
6. The band, along with existing setlists and rehearsals, will sync to Device 2

### Verify Sync:
- Create a setlist on Device 1
- Wait a few seconds
- Pull to refresh on Device 2 (if needed)
- The setlist should appear on both devices

## Troubleshooting

### "Band not found" error
- Verify you're using the correct invite code
- Check that CloudKit schema is deployed to Production
- Ensure both devices have internet connection
- Wait a minute - CloudKit can have slight delays

### Setlists/Rehearsals not syncing
- Check CloudKit Dashboard logs for errors
- Verify indexes are created correctly
- Make sure `bandCode` fields are marked as Searchable

### "Not authorized" errors
- Verify iCloud is signed in on the device
- Check that CloudKit capability is enabled in Xcode
- Ensure entitlements files have the correct iCloud container ID

## Current Implementation Status

✅ **Completed:**
- BandSharingManager with full CloudKit integration
- Automatic sync when creating setlists
- Automatic sync when creating rehearsals
- Band registration and discovery via invite codes
- CloudKit subscriptions for real-time updates
- UI for creating and joining bands
- Invite code sharing in BandSettingsView

⚠️ **Requires Manual Setup:**
- CloudKit schema creation (this guide)
- CloudKit deployment to production

## Additional Notes

- The public database has usage limits (check your Apple Developer dashboard)
- For production apps with many users, consider rate limiting or caching
- CloudKit subscriptions require push notifications to be enabled
- The app uses silent push notifications (`content-available` flag)

## Support

If you encounter issues:
1. Check CloudKit Dashboard logs
2. Review Xcode console for CloudKit error messages
3. Verify all record types and fields match the specifications above
4. Test with two different Apple IDs on different devices

---

**Last Updated:** October 2025
**CloudKit Database:** Public
**Authentication:** iCloud Account Required
