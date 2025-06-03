Project Brief: Pegki child care - Baby Care Companion

Version: 1.1
Date: May 31, 2025
Prepared For: New Parent App Development Team
Prepared By: Gemini AI

1. Project Overview

App Name: Pegki child care

Vision: To be the most intuitive, supportive, and indispensable mobile companion for new parents, simplifying the tracking of their baby's essential health, growth, and daily routines, thereby fostering confidence and reducing stress during the crucial early stages of parenthood.

Target Audience:

First-time parents.

Parents of newborns and infants (0-24 months).

Caregivers (with shared access) such as partners, grandparents, or nannies.

Parents seeking a reliable way to monitor patterns, share information with pediatricians, and feel more organized.

Core Problem Solved: New parents are often overwhelmed with information, sleep-deprived, and anxious about their baby's well-being. Pegki child care aims to alleviate this by providing a simple, centralized, and quick way to log and review essential baby data, facilitating better care, communication, and peace of mind.

Unique Selling Proposition (USP): Built with Flutter for a beautiful, cross-platform experience adhering to Google Material 3 design principles, and powered by Google Firebase for rapid development, real-time data sync, and robust scalability. The app will prioritize an exceptionally clean, fast, and calming user interface, making data entry effortless even for tired parents.

2. Technical Foundation

Frontend Framework: Flutter

Chosen for its ability to create high-quality, natively compiled applications for mobile (iOS and Android) from a single codebase.

Enables rich, customizable UI and smooth animations, contributing to a delightful user experience.

Design System: Google Material 3 principles will be followed for UI/UX design to ensure a modern, cohesive, and accessible interface.

Backend & Core Services: Google Firebase

Firestore: Primary NoSQL database for storing all user and baby data (feeding logs, sleep patterns, diaper changes, medicine, growth, milestones, notes). Its real-time capabilities are ideal for data synchronization between caregivers.

Firebase Authentication: For secure user sign-up/sign-in (Email/Password, Google Sign-In).

Firebase Cloud Functions: For any server-side logic that might be needed (e.g., sending custom notifications, data aggregation if complex).

Firebase Cloud Messaging (FCM): For delivering reminders and notifications (e.g., next medicine dose, upcoming appointments).

Firebase Storage: For storing user-uploaded images (e.g., baby profile photo, milestone photos - Post-MVP).

Development & Deployment: The Firebase CLI will be utilized for managing Firebase projects, emulating services locally, and deploying Functions, Firestore rules, and Hosting (if applicable).

Other Google Services (to consider for rapid development & insights):

Google Analytics for Firebase: To understand user behavior, track feature usage, and identify areas for improvement.

Firebase Crashlytics: For real-time crash reporting and stability monitoring.

Firebase Remote Config: To remotely update app configurations or enable/disable features without requiring an app update.

Google Fonts: For a wide selection of high-quality, easy-to-integrate fonts.

3. Core User Flows (Illustrative)

Onboarding & Baby Profile Setup:

User opens app -> Signs up/Logs in (Firebase Auth).

Prompted to create a baby profile: Name, DOB, Gender (optional: photo, weight/height at birth).

Data saved to Firestore.

Lands on the main Dashboard.

Logging a Feeding:

User taps "Log Feed" on Dashboard or via quick-add button.

Selects type: Breast (Left/Right timer, manual entry), Bottle (Amount, Milk Type), Solids (Food, Amount, Reaction).

Confirms time (defaults to current, editable).

Saves entry -> Data written to Firestore -> Dashboard updates.

Logging a Diaper Change:

User taps "Log Diaper" on Dashboard or quick-add.

Selects type: Wet, Dirty, Mixed (optional: color/consistency notes).

Confirms time.

Saves entry -> Data written to Firestore -> Dashboard updates.

Logging Sleep:

User taps "Log Sleep" on Dashboard or quick-add.

Inputs Start Time & End Time (or Duration).

(Optional) Selects sleep type (Nap/Night).

Saves entry -> Data written to Firestore -> Dashboard updates.

Viewing Dashboard / Recent Activity:

User opens app (after setup) -> Lands on Dashboard.

Dashboard displays summaries of recent activities (last feed, last diaper, last sleep, next medicine if scheduled).

Quick access to log new entries.

Navigation to view detailed history for each category.

Sharing with a Co-Parent/Caregiver (Post-MVP Flow):

Primary user navigates to "Settings" -> "Share Access."

Invites another user via email.

Invited user receives link/code, signs up/logs in, and gains access to the shared baby profile.

Data changes by one user are reflected in real-time for the other (Firestore magic).

4. Key Features

4.1. MVP (Minimum Viable Product) - Launch Set

User Authentication (Firebase Authentication):

Email & Password sign-up/login.

Google Sign-In option.

Password reset functionality.

Baby Profile Management (Firestore):

Create and manage one baby profile (Name, DOB, Gender).

Option to add a profile picture (initially simple, Firebase Storage later for flexibility).

Edit profile details.

Feeding Tracker (Firestore):

Breastfeeding: Timer for left/right breast, manual duration entry, last side offered.

Bottle Feeding: Log amount (ml/oz), milk type (Breast Milk, Formula - simple text input for formula type).

Solid Foods: Log food item (text), amount (text), simple reaction note.

Timestamped entries, viewable in a chronological list.

Diaper Change Tracker (Firestore):

Log type: Wet, Dirty, Mixed.

Optional short note (e.g., color, consistency).

Timestamped entries, viewable in a chronological list.

Sleep Tracker (Firestore):

Log start and end times, or duration.

Timestamped entries, viewable in a chronological list.

Medicine Tracker (Firestore):

Log medicine name, dosage (text), time administered.

Optional short note.

Timestamped entries, viewable in a chronological list.

Basic Dashboard / Overview:

Displays a summary of the most recent key activities (e.g., last feed time/type, last diaper change, last sleep).

Quick-add buttons for core tracking activities.

Simple Notes / Daily Diary (Firestore):

Free-form text entry for daily observations, moods, questions for the doctor.

Timestamped entries, viewable chronologically.

Offline Data Entry (Leveraging Firestore's offline persistence):

Users can log data even when offline.

Data syncs automatically when the connection is restored.

4.2. Post-MVP Enhancements (Key Next Steps)

Growth Tracker (Firestore):

Log weight, height, head circumference.

Display data in a simple list and basic line charts to visualize trends.

Milestones Tracker (Firestore):

Predefined list of common developmental milestones.

Log date achieved, add notes.

(Later) Option to add a photo for each milestone (Firebase Storage).

Reminders & Notifications (Firebase Cloud Messaging - FCM):

Set reminders for medication doses.

Customizable reminders (e.g., "Time for next feed," "Tummy time").

Symptoms Tracker (Firestore):

Log common baby symptoms (e.g., fever, rash, colic) with notes and timestamps.

Data Synchronization for Multiple Caregivers (Real-time Firestore):

Securely invite and manage access for a co-parent or caregiver to view and contribute to the baby's log.

Real-time updates across all connected devices.

Enhanced Dashboard & Basic Analytics:

More comprehensive daily/weekly summaries on the dashboard.

Simple visual cues for patterns (e.g., average sleep duration).

Export Data (Simple CSV/Text):

Ability to export basic logs for sharing with pediatricians.

4.3. Future Considerations (Longer-Term Roadmap)

Advanced reporting and charts (e.g., percentile growth charts).

Full photo integration throughout the diary and logs.

Appointment tracker with reminders.

Customizable tracking categories.

Community features (with strict privacy controls).

Wearable integration (e.g., quick logging from a smartwatch).

5. Design & UX Principles

Intuitive & Simple: The app must be incredibly easy to learn and use, especially for sleep-deprived parents. Minimize clicks for common actions.

Fast & Efficient: Data entry should be quick and seamless. Performance is key.

Calm & Reassuring: UI design should be clean, uncluttered, and use a soothing color palette, following Material 3 guidelines.

Visually Appealing (Flutter Advantage): Leverage Flutter and Material 3 to create a modern, polished, and aesthetically pleasing interface. Consider subtle, delightful animations (e.g., using Rive) that enhance the experience without being distracting.

Accessible: Design with accessibility in mind (good contrast, legible fonts, support for screen readers if possible).

Secure & Private: User data is highly sensitive. Ensure robust security practices and clear communication about data privacy.

Offline First Mentality: Core logging functions should work flawlessly offline.