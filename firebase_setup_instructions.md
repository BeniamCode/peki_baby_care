# 🔥 Firebase Setup Instructions for Pegki Baby Care

## Prerequisites
✅ You already have FlutterFire CLI installed  
✅ Firebase project `pegki-e0872` is already configured  
✅ Configuration files are in place

## Quick Start
Since Firebase is already configured, you can start the app immediately:

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Firebase Configuration Status
- **Project ID**: `pegki-e0872`
- **Android**: ✅ Configured (`google-services.json` present)
- **iOS**: ✅ Configured (`GoogleService-Info.plist` present)
- **Web**: ✅ Configured in `firebase_options.dart`

## Firestore Database Structure

The app uses the following Firestore collections:

### 👶 Babies Collection
```
babies/
├── {babyId}/
    ├── name: string
    ├── dateOfBirth: timestamp
    ├── gender: string (optional)
    ├── profilePhotoUrl: string (optional)
    ├── parentId: string
    └── createdAt: timestamp
```

### 🍼 Feedings Collection
```
feedings/
├── {feedingId}/
    ├── babyId: string
    ├── type: string ('breast', 'bottle', 'solid')
    ├── timestamp: timestamp
    ├── duration: number (for breastfeeding)
    ├── side: string ('left', 'right' for breastfeeding)
    ├── amount: number (for bottle)
    ├── milkType: string ('breast', 'formula')
    ├── food: string (for solids)
    └── notes: string (optional)
```

### 😴 Sleep Collection
```
sleeps/
├── {sleepId}/
    ├── babyId: string
    ├── startTime: timestamp
    ├── endTime: timestamp (optional for active sessions)
    ├── type: string ('nap', 'night')
    └── notes: string (optional)
```

### 👶 Diapers Collection
```
diapers/
├── {diaperId}/
    ├── babyId: string
    ├── type: string ('wet', 'dirty', 'mixed')
    ├── timestamp: timestamp
    ├── hasRash: boolean
    ├── consistency: string (optional)
    ├── color: string (optional)
    └── notes: string (optional)
```

### 💊 Medicines Collection
```
medicines/
├── {medicineId}/
    ├── babyId: string
    ├── name: string
    ├── dosage: string
    ├── administeredAt: timestamp
    ├── nextDoseTime: timestamp (optional)
    └── notes: string (optional)
```

### 📝 Notes Collection
```
notes/
├── {noteId}/
    ├── babyId: string
    ├── title: string
    ├── content: string
    ├── category: string ('medical', 'milestone', 'general')
    ├── tags: array of strings
    ├── isImportant: boolean
    ├── timestamp: timestamp
    └── updatedAt: timestamp
```

## Firestore Security Rules

Add these rules to your Firestore database:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /babies/{babyId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.parentId;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.parentId;
    }
    
    match /feedings/{feedingId} {
      allow read, write: if request.auth != null && 
        exists(/databases/$(database)/documents/babies/$(resource.data.babyId)) &&
        get(/databases/$(database)/documents/babies/$(resource.data.babyId)).data.parentId == request.auth.uid;
    }
    
    match /sleeps/{sleepId} {
      allow read, write: if request.auth != null && 
        exists(/databases/$(database)/documents/babies/$(resource.data.babyId)) &&
        get(/databases/$(database)/documents/babies/$(resource.data.babyId)).data.parentId == request.auth.uid;
    }
    
    match /diapers/{diaperId} {
      allow read, write: if request.auth != null && 
        exists(/databases/$(database)/documents/babies/$(resource.data.babyId)) &&
        get(/databases/$(database)/documents/babies/$(resource.data.babyId)).data.parentId == request.auth.uid;
    }
    
    match /medicines/{medicineId} {
      allow read, write: if request.auth != null && 
        exists(/databases/$(database)/documents/babies/$(resource.data.babyId)) &&
        get(/databases/$(database)/documents/babies/$(resource.data.babyId)).data.parentId == request.auth.uid;
    }
    
    match /notes/{noteId} {
      allow read, write: if request.auth != null && 
        exists(/databases/$(database)/documents/babies/$(resource.data.babyId)) &&
        get(/databases/$(database)/documents/babies/$(resource.data.babyId)).data.parentId == request.auth.uid;
    }
  }
}
```

## Authentication Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your `pegki-e0872` project
3. Navigate to **Authentication** > **Sign-in method**
4. Enable:
   - **Email/Password**
   - **Google** (optional but recommended)

## Firebase Indexes

For optimal performance, create these composite indexes in Firestore:

1. **Feedings**: `babyId` (Ascending) + `timestamp` (Descending)
2. **Sleep**: `babyId` (Ascending) + `startTime` (Descending)
3. **Diapers**: `babyId` (Ascending) + `timestamp` (Descending)
4. **Medicines**: `babyId` (Ascending) + `administeredAt` (Descending)
5. **Notes**: `babyId` (Ascending) + `timestamp` (Descending)

## Running the App

The app is now ready to run! The Firebase configuration is complete and all features should work properly:

- ✅ **Authentication**: Email/password and Google Sign-In
- ✅ **Baby Profiles**: Create and manage multiple babies
- ✅ **Feeding Tracker**: Breastfeeding, bottle, and solid foods
- ✅ **Sleep Tracker**: Track sleep sessions with duration
- ✅ **Diaper Tracker**: Quick logging with rash monitoring
- ✅ **Medicine Tracker**: Dose tracking with scheduling
- ✅ **Notes/Diary**: Categorized entries with search
- ✅ **Dashboard**: Real-time activity overview

## Troubleshooting

### If you get authentication errors:
1. Check that Authentication is enabled in Firebase Console
2. Verify the SHA-1 certificate is added for Android
3. Ensure bundle ID matches for iOS

### If Firestore queries fail:
1. Check security rules are properly configured
2. Verify composite indexes are created
3. Ensure baby documents exist before accessing child collections

### If the app doesn't build:
1. Run `flutter clean && flutter pub get`
2. Check that all dependencies are compatible
3. Verify Xcode/Android Studio are up to date

## Next Steps

1. **Run the app**: `flutter run`
2. **Create an account** using the registration screen
3. **Add your first baby** profile
4. **Start tracking** feeding, sleep, and diaper changes
5. **Explore** all the features in the beautiful Material 3 interface!

---

**Happy tracking! 👶✨**