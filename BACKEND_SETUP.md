# Pegki Baby Care - Backend Setup Guide

## Overview
This guide will help you set up and configure the Firebase backend for the Pegki Baby Care application, including Firestore database, security rules, indexes, and authentication.

## Prerequisites
- Firebase CLI installed: `npm install -g firebase-tools`
- Active Firebase project: `pegki-e0872`
- Flutter project properly configured with FlutterFire CLI

## Current Firebase Project Configuration
- **Project ID**: `pegki-e0872`
- **Database**: Cloud Firestore
- **Authentication**: Firebase Authentication
- **Storage**: Firebase Cloud Storage
- **Analytics**: Firebase Analytics
- **Crashlytics**: Firebase Crashlytics

## Step 1: Firebase CLI Setup

### 1.1 Login to Firebase
```bash
firebase login
```

### 1.2 Initialize Firebase in your project directory
```bash
cd /path/to/peki_baby_care
firebase init
```

Select the following services:
- ✅ Firestore: Configure security rules and indexes files
- ✅ Functions: Configure a Cloud Functions directory and its files
- ✅ Hosting: Configure files for Firebase Hosting and (optionally) GitHub Action deploys
- ✅ Storage: Configure a security rules file for Cloud Storage

## Step 2: Firestore Configuration

### 2.1 Database Rules Deployment
The project includes comprehensive security rules in `firestore.rules`. Deploy them:

```bash
firebase deploy --only firestore:rules
```

### 2.2 Database Indexes
Create the required composite indexes by deploying the indexes configuration:

```bash
firebase deploy --only firestore:indexes
```

### 2.3 Key Security Features
- **User Data Isolation**: Each user can only access their own data
- **Hierarchical Structure**: Data is organized as subcollections under users
- **Field Validation**: Comprehensive validation for data types and required fields
- **Timestamp Validation**: Prevents future dates and invalid timestamps
- **Input Sanitization**: Validates enum values and data constraints

## Step 3: Authentication Configuration

### 3.1 Enable Authentication Methods
In the Firebase Console (https://console.firebase.google.com/project/pegki-e0872):

1. Go to **Authentication** > **Sign-in method**
2. Enable the following providers:
   - ✅ **Email/Password**
   - ✅ **Google** (recommended for better UX)
   - ✅ **Apple** (for iOS App Store compliance)

### 3.2 Authentication Settings
Configure the following settings:

**Email/Password Settings:**
- ✅ Enable email/password sign-in
- ✅ Enable email link sign-in (passwordless)
- ✅ Enable email verification

**Advanced Settings:**
- Set password policy requirements
- Configure email templates
- Set up authorized domains

## Step 4: Cloud Storage Configuration

### 4.1 Storage Bucket Rules
Create storage rules for baby photos and attachments:

```javascript
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile photos
    match /users/{userId}/profile/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Baby photos
    match /users/{userId}/babies/{babyId}/photos/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Note attachments
    match /users/{userId}/babies/{babyId}/notes/{noteId}/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Deny all other access
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

### 4.2 Deploy Storage Rules
```bash
firebase deploy --only storage
```

## Step 5: Database Indexes Configuration

Create the `firestore.indexes.json` file with the following composite indexes:

```json
{
  "indexes": [
    {
      "collectionGroup": "feedings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "babyId", "order": "ASCENDING" },
        { "fieldPath": "startTime", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "diapers",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "babyId", "order": "ASCENDING" },
        { "fieldPath": "changeTime", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "sleep",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "babyId", "order": "ASCENDING" },
        { "fieldPath": "startTime", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "medicines",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "babyId", "order": "ASCENDING" },
        { "fieldPath": "isCompleted", "order": "ASCENDING" },
        { "fieldPath": "nextDoseTime", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "growth",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "babyId", "order": "ASCENDING" },
        { "fieldPath": "recordedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "notes",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "babyId", "order": "ASCENDING" },
        { "fieldPath": "category", "order": "ASCENDING" },
        { "fieldPath": "isImportant", "order": "DESCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "notes",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "babyId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```

## Step 6: Cloud Functions (Optional but Recommended)

### 6.1 Initialize Cloud Functions
```bash
firebase init functions
```

### 6.2 Useful Cloud Functions

**Growth Percentile Calculator:**
```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.calculateGrowthPercentiles = functions.firestore
  .document('users/{userId}/babies/{babyId}/growth/{growthId}')
  .onCreate(async (snap, context) => {
    const growth = snap.data();
    const { userId, babyId } = context.params;
    
    // Calculate percentiles based on WHO growth standards
    // Implementation would use WHO growth charts
    const percentiles = await calculatePercentiles(growth);
    
    return snap.ref.update({ percentiles });
  });
```

**Medicine Reminder Notifications:**
```javascript
exports.sendMedicineReminders = functions.pubsub
  .schedule('every 30 minutes')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const futureTime = admin.firestore.Timestamp.fromMillis(
      now.toMillis() + (30 * 60 * 1000) // 30 minutes from now
    );
    
    // Query for upcoming medicine doses
    const snapshot = await admin.firestore()
      .collectionGroup('medicines')
      .where('isCompleted', '==', false)
      .where('nextDoseTime', '>=', now)
      .where('nextDoseTime', '<=', futureTime)
      .get();
    
    // Send notifications for each upcoming dose
    // Implementation would use Firebase Cloud Messaging
  });
```

### 6.3 Deploy Cloud Functions
```bash
firebase deploy --only functions
```

## Step 7: Data Migration Strategy

### 7.1 Migration from Old Structure
If you have existing data in the old flat structure, create a migration function:

```javascript
exports.migrateToNewStructure = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const userId = context.auth.uid;
  const batch = admin.firestore().batch();
  
  // Migrate babies
  const babiesSnapshot = await admin.firestore()
    .collection('babies')
    .where('parentIds', 'array-contains', userId)
    .get();
  
  babiesSnapshot.forEach(doc => {
    const newRef = admin.firestore()
      .collection('users').doc(userId)
      .collection('babies').doc(doc.id);
    batch.set(newRef, doc.data());
  });
  
  // Continue for other collections...
  
  await batch.commit();
  return { success: true };
});
```

## Step 8: Environment Configuration

### 8.1 Firebase Configuration
Ensure your `firebase.json` is properly configured:

```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "storage": {
    "rules": "storage.rules"
  },
  "functions": {
    "source": "functions"
  },
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ]
  }
}
```

### 8.2 Flutter Configuration
Verify your Flutter app is properly configured:

1. ✅ `firebase_options.dart` exists and is up to date
2. ✅ `main.dart` initializes Firebase correctly
3. ✅ All Firebase packages are included in `pubspec.yaml`

## Step 9: Testing & Validation

### 9.1 Security Rules Testing
Test your security rules using the Firebase Emulator:

```bash
firebase emulators:start --only firestore
```

### 9.2 Data Validation
Create test documents to validate:
- User data isolation
- Required field validation
- Timestamp constraints
- Enum value validation

## Step 10: Production Deployment

### 10.1 Deploy All Services
```bash
firebase deploy
```

### 10.2 Monitor Performance
Set up monitoring in Firebase Console:
- Database usage metrics
- Security rule evaluation time
- Authentication success rates
- Function execution metrics

## Step 11: Backup Strategy

### 11.1 Automated Backups
Enable automatic Firestore backups:

```bash
gcloud firestore operations list
gcloud alpha firestore export gs://pegki-e0872-backups/$(date +%Y%m%d_%H%M%S)
```

### 11.2 Data Export for Users
Implement user data export functionality for GDPR compliance:

```javascript
exports.exportUserData = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const userId = context.auth.uid;
  // Export all user data to Cloud Storage
  // Return download URL
});
```

## Troubleshooting

### Common Issues

1. **Permission Denied Errors**
   - Check security rules
   - Verify user authentication
   - Ensure proper document structure

2. **Index Creation Failures**
   - Verify index configuration
   - Check for conflicting indexes
   - Allow time for index creation

3. **Storage Upload Failures**
   - Check storage rules
   - Verify file size limits
   - Ensure proper file paths

### Support Resources

- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Flutter Firebase Setup](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/project/pegki-e0872)

## Conclusion

This backend setup provides a robust, secure, and scalable foundation for the Pegki Baby Care application. The hierarchical data structure ensures proper data isolation while maintaining flexibility for future features.

Remember to:
- Test all security rules thoroughly
- Monitor performance metrics
- Keep backups of your data
- Update security rules as features evolve
- Follow Firebase best practices for optimal performance