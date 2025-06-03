# Pegki Baby Care - Project Structure

## Overview
This Flutter application follows a feature-first architecture with clean separation of concerns, making it scalable and maintainable.

## Directory Structure

```
lib/
├── core/                     # Core functionality shared across features
│   ├── constants/           # App-wide constants
│   ├── themes/             # Material 3 theme configuration
│   ├── utils/              # Utility functions and helpers
│   └── extensions/         # Dart extensions
│
├── features/               # Feature modules (feature-first approach)
│   ├── auth/              # Authentication feature
│   ├── baby_profile/      # Baby profile management
│   ├── feeding/           # Feeding tracking
│   ├── sleep/             # Sleep tracking
│   ├── diaper/            # Diaper change tracking
│   ├── health/            # Health records and appointments
│   ├── growth/            # Growth tracking
│   └── activities/        # Activity tracking
│
├── shared/                # Shared components
│   ├── widgets/          # Reusable widgets
│   └── utils/            # Shared utilities
│
├── data/                 # Data layer
│   ├── models/          # Data models
│   ├── repositories/    # Repository implementations
│   └── datasources/     # Data sources (Firebase, APIs, etc.)
│
├── config/              # App configuration
│   ├── routes/         # Navigation and routing
│   └── themes/         # Additional theme configurations
│
└── main.dart           # App entry point
```

## Feature Structure
Each feature follows a consistent structure:

```
feature_name/
├── presentation/       # UI layer
│   ├── screens/       # Feature screens
│   ├── widgets/       # Feature-specific widgets
│   └── providers/     # State management (Provider)
│
├── domain/            # Business logic layer
│   ├── entities/      # Business entities
│   ├── usecases/      # Use cases
│   └── repositories/  # Repository interfaces
│
└── data/              # Data layer
    ├── models/        # Data models
    ├── repositories/  # Repository implementations
    └── datasources/   # Data sources
```

## Key Technologies

- **Flutter SDK**: ^3.8.0
- **State Management**: Provider
- **Navigation**: GoRouter
- **Backend**: Firebase (Auth, Firestore, Storage)
- **UI/UX**: Material 3 Design System
- **Forms**: Flutter Form Builder
- **Localization**: Intl

## Getting Started

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Configure Firebase**:
   - Add your Firebase configuration files
   - Update Firebase initialization in `main.dart`

3. **Run the app**:
   ```bash
   flutter run
   ```

## Development Guidelines

1. **Code Style**: Follow Flutter's official style guide
2. **State Management**: Use Provider for state management
3. **Navigation**: Use GoRouter for declarative navigation
4. **Forms**: Use Flutter Form Builder for complex forms
5. **Validation**: Use the validators in `core/utils/validators.dart`
6. **Theming**: Follow Material 3 design guidelines

## Next Steps

1. Set up Firebase project and add configuration files
2. Implement authentication providers
3. Create remaining feature screens
4. Add localization support
5. Implement push notifications
6. Add analytics tracking
7. Set up CI/CD pipeline