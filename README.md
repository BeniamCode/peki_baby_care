# Peki Baby Care 👶

A comprehensive Flutter application for tracking and managing baby care activities. Peki Baby Care helps parents monitor their baby's feeding, sleep, diaper changes, health, and important milestones in one convenient app.

## ✨ Features

### 🏠 Dashboard
- Baby profile management with photo upload
- Quick activity summary
- Recent activity timeline
- Multi-baby support

### 🍼 Feeding Tracker
- Bottle and breast feeding logging
- Feeding duration tracking
- Daily feeding summary
- Feeding pattern analysis

### 😴 Sleep Tracker
- Sleep session recording
- Active sleep monitoring
- Sleep pattern visualization
- Daily sleep statistics

### 🚼 Diaper Tracker
- Quick diaper change logging
- Type categorization (wet, dirty, mixed, dry)
- Daily diaper count summary
- Pattern tracking

### 🏥 Health Management
- Medicine schedule tracking
- Dose reminders
- Medicine history
- Health notes

### 📝 Notes & Diary
- Create categorized notes (Medical, Milestone, General)
- Tag system for easy organization
- Search functionality
- Mark important notes
- Rich text entries

## 📱 Screenshots

<div align="center">
  <img src="screenshots/dashboard.png" width="200" alt="Dashboard">
  <img src="screenshots/feeding.png" width="200" alt="Feeding">
  <img src="screenshots/sleep.png" width="200" alt="Sleep">
  <img src="screenshots/notes.png" width="200" alt="Notes">
</div>

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase account
- iOS/Android development environment

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/peki_baby_care.git
   cd peki_baby_care
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication (Email/Password)
   - Enable Cloud Firestore
   - Enable Storage (for photo uploads)
   
4. **Add Firebase configuration files**
   - For Android: Download `google-services.json` and place it in `android/app/`
   - For iOS: Download `GoogleService-Info.plist` and add it to `ios/Runner/`

5. **Initialize Firebase (if not already done)**
   ```bash
   flutterfire configure
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## 🔥 Firebase Configuration

### Firestore Structure

```
users/
  └── {userId}/
      ├── email
      ├── name
      └── createdAt

babies/
  └── {babyId}/
      ├── userId
      ├── name
      ├── dateOfBirth
      ├── gender
      ├── weight
      ├── height
      ├── bloodType
      ├── photoUrl
      └── createdAt

feeding/
  └── {feedingId}/
      ├── babyId
      ├── type
      ├── amount
      ├── duration
      ├── startTime
      ├── endTime
      └── notes

sleep/
  └── {sleepId}/
      ├── babyId
      ├── startTime
      ├── endTime
      ├── duration
      └── quality

diaper/
  └── {diaperId}/
      ├── babyId
      ├── type
      ├── time
      └── notes

medicine/
  └── {medicineId}/
      ├── babyId
      ├── name
      ├── dosage
      ├── frequency
      ├── startDate
      ├── endDate
      └── notes

notes/
  └── {noteId}/
      ├── babyId
      ├── title
      ├── content
      ├── category
      ├── tags
      ├── isImportant
      └── createdAt
```

### Security Rules

Add these security rules to your Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can only access their babies
    match /babies/{document=**} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Activity data access based on baby ownership
    match /{collection}/{document=**} {
      allow read, write: if request.auth != null && 
        exists(/databases/$(database)/documents/babies/$(resource.data.babyId)) &&
        get(/databases/$(database)/documents/babies/$(resource.data.babyId)).data.userId == request.auth.uid;
    }
  }
}
```

## 🏗️ Project Structure

```
lib/
├── config/
│   └── routes/
│       └── app_router.dart
├── core/
│   ├── constants/
│   ├── themes/
│   ├── utils/
│   └── extensions/
├── data/
│   ├── models/
│   ├── repositories/
│   └── datasources/
├── features/
│   ├── auth/
│   ├── baby_profile/
│   ├── dashboard/
│   ├── feeding/
│   ├── sleep/
│   ├── diaper/
│   ├── health/
│   └── notes/
├── shared/
│   └── widgets/
└── main.dart
```

## 🛠️ Built With

- **Flutter** - UI framework
- **Firebase** - Backend services
  - Authentication
  - Cloud Firestore
  - Cloud Storage
- **Provider** - State management
- **GoRouter** - Navigation
- **FL Chart** - Data visualization
- **Image Picker** - Photo selection
- **Intl** - Date formatting

## 🎨 Design Features

- Material 3 Design System
- Light/Dark theme support
- Responsive layouts
- Smooth animations
- Intuitive navigation

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 👥 Authors

- **Your Name** - *Initial work* - [YourGitHub](https://github.com/yourusername)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors and testers

---

Made with ❤️ for parents everywhere