Instructions for AI Coder: Pegki child care App Development
Project Goal: Develop the "Pegki child care" mobile application as detailed in the project brief (pegki.md / Project Brief: Pegki child care - Baby Care Companion). This app aims to be an intuitive and supportive tool for new parents to track their baby's essential health and daily routines.

Core Technologies:

Frontend: Flutter (using Google Material 3 design principles)

Backend & Services: Google Firebase (Firestore, Firebase Authentication, Cloud Functions, FCM, Firebase Storage, Firebase CLI for management)

Analytics & Monitoring: Google Analytics for Firebase, Firebase Crashlytics

Phase 1: Understanding and Architecture

Thoroughly Review Project Brief:

Carefully read and internalize all sections of the "Project Brief: Pegki child care - Baby Care Companion" (pegki.md). Pay close attention to:

Project Vision, Target Audience, Core Problem Solved, and USP (Section 1).

Detailed Technical Foundation, including the specified Firebase services and their intended uses (Section 2).

MVP Feature List (Section 4.1) – this will be your primary focus for initial development.

Post-MVP Enhancements (Section 4.2) and Future Considerations (Section 4.3) for architectural foresight.

Design & UX Principles (Section 5), especially adherence to Material 3 and the emphasis on a calm, intuitive, and efficient UI.

Core User Flows (Section 3).

System Architecture Design:

Based on the brief, architect the overall system. This should include:

Flutter Application Structure: Propose a clean, scalable Flutter project structure (e.g., feature-first, layer-first, or a hybrid approach). Define how state management will be handled (e.g., Provider, Riverpod, BLoC – choose one and justify based on project needs and team familiarity, aiming for simplicity and testability).

Firebase Firestore Data Model: Design the Firestore collections and document structures. Consider data relationships, querying needs, and security rules. Document this model clearly (e.g., using diagrams or structured text). Ensure it supports all MVP features and allows for future scalability (Post-MVP features).

Firebase Security Rules: Outline initial Firestore security rules to ensure data privacy and integrity (e.g., users can only read/write their own data).

API Design (if any Cloud Functions are anticipated for MVP): Define the purpose, inputs, and outputs for any Cloud Functions. For MVP, most logic might be client-side, but consider if any backend processing is essential early on (e.g., complex notifications not handled by client-side FCM scheduling).

User Flow Diagrams & UI/UX Considerations:

For each core user flow outlined in Section 3 of the brief (Onboarding, Logging Feeding, Logging Diaper, Logging Sleep, Dashboard Viewing), create detailed visual user flow diagrams (e.g., UML activity diagrams, flowcharts, or wireflow diagrams).

Translate these flows into initial wireframes or low-fidelity mockups for key screens, ensuring they align with Material 3 principles and the app's UX goals (intuitive, fast, calm).

Identify all necessary UI components and plan their implementation using Flutter Material 3 widgets.

Phase 2: Development Planning & Milestones

Task Breakdown & Milestones:

Break down the MVP feature list (Section 4.1) into smaller, manageable development tasks.

Group these tasks into logical development milestones. For each milestone, define:

Key features to be completed.

Estimated effort/time.

Clear deliverables/acceptance criteria.

Suggested Initial Milestones:

M1: Core Setup & Authentication: Firebase project setup, Flutter project initialization, Firebase Authentication (Email/Password, Google Sign-In), basic baby profile creation UI (without Firestore save yet).

M2: Baby Profile & Firestore Integration: Implement Firestore data model for baby profiles, save/retrieve baby profile data.

M3: Feeding Tracker Module: UI and Firestore logic for all feeding types (Breast, Bottle, Solids).

M4: Diaper & Sleep Tracker Modules: UI and Firestore logic for diaper and sleep tracking.

M5: Medicine & Notes Modules: UI and Firestore logic for medicine tracking and daily notes.

M6: Dashboard & Offline Capability: Implement the basic dashboard, integrate Firestore offline persistence.

M7: Testing, Refinement & MVP Release Candidate: Thorough testing, bug fixing, UI polish.

Progress Tracking & Communication:

Establish a method for tracking your progress against these milestones (e.g., a simple task board, comments in code, regular updates).

Clearly communicate your current progress, any roadblocks encountered, and your next immediate steps at regular intervals.

Phase 3: Implementation & Best Practices

Code Quality & Standards:

Adhere to Flutter best practices and effective Dart coding conventions.

Write clean, well-documented, maintainable, and testable code.

Implement robust error handling and user feedback mechanisms.

Firebase Implementation:

Utilize the Firebase CLI for project management and deployments.

Implement Firestore queries efficiently.

Ensure proper setup of Firebase Authentication and security rules.

UI/UX Implementation:

Strictly follow Google Material 3 design guidelines.

Prioritize performance and responsiveness.

Ensure the UI is intuitive and requires minimal effort from the user, especially for frequent logging tasks.

Testing:

Plan for unit tests for critical logic (e.g., state management, data transformation).

Conduct widget tests for UI components.

Perform manual testing for user flows and overall usability.

Utilize Firebase emulators for local testing of Firestore, Auth, and Functions.

Version Control:

Use Git for version control, with clear commit messages and a sensible branching strategy (if applicable for your workflow).

Ongoing:

Iterative Refinement: Be prepared to iterate on designs and features based on internal review or (eventual) user feedback.

Problem Solving: When encountering challenges, think critically, research solutions, and clearly articulate any issues if you need assistance.

Focus on MVP: While keeping future enhancements in mind for architecture, concentrate on delivering a high-quality MVP as defined in the brief.

Please confirm your understanding of these instructions and the project brief. Outline your proposed initial architecture for Firestore and your planned first few development tasks/milestones.