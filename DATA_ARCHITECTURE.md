# Pegki Baby Care - Data Architecture & UML Design

## Executive Summary
This document provides a comprehensive overview of the data architecture for the Pegki Baby Care application, including UML diagrams, data flow patterns, and technical implementation details.

## System Architecture Overview

```mermaid
graph TB
    subgraph "Client Layer"
        A[Flutter Mobile App]
        B[Flutter Web App]
        C[Flutter Desktop App]
    end
    
    subgraph "Firebase Services"
        D[Firebase Authentication]
        E[Cloud Firestore]
        F[Firebase Storage]
        G[Cloud Functions]
        H[Firebase Analytics]
        I[Firebase Crashlytics]
    end
    
    subgraph "External Services"
        J[Push Notifications]
        K[Email Services]
    end
    
    A --> D
    A --> E
    A --> F
    B --> D
    B --> E
    B --> F
    C --> D
    C --> E
    C --> F
    
    D --> G
    E --> G
    F --> G
    G --> J
    G --> K
    
    A --> H
    A --> I
    B --> H
    B --> I
    C --> H
    C --> I
```

## Database Schema UML Diagram

```mermaid
erDiagram
    User {
        string uid PK "Firebase Auth UID"
        string email UK "Email address"
        string displayName "Full name"
        string photoURL "Profile photo URL"
        object preferences "User preferences"
        timestamp createdAt "Account creation"
        timestamp updatedAt "Last updated"
    }
    
    Baby {
        string id PK "Auto-generated ID"
        string name "Baby's name"
        timestamp dateOfBirth "Birth date"
        enum gender "male, female, other"
        string photoURL "Baby photo URL"
        object birthDetails "Birth information"
        object medicalInfo "Medical information"
        boolean isActive "Currently tracking"
        timestamp createdAt "Record creation"
        timestamp updatedAt "Last updated"
        string createdBy FK "User who created"
    }
    
    FeedingRecord {
        string id PK "Auto-generated ID"
        string babyId FK "Reference to baby"
        enum type "breast, bottle, solid"
        timestamp startTime "Feeding start"
        timestamp endTime "Feeding end (optional)"
        number duration "Duration in minutes"
        enum breastSide "left, right, both"
        number amount "Amount in ml/oz"
        string bottleType "formula, breast_milk, etc"
        string foodType "Description of food"
        number foodAmount "Amount in grams/oz"
        string notes "Additional notes"
        timestamp createdAt "Record creation"
        string createdBy FK "User who logged"
    }
    
    DiaperRecord {
        string id PK "Auto-generated ID"
        string babyId FK "Reference to baby"
        timestamp changeTime "When changed"
        enum type "wet, dirty, mixed, dry"
        string consistency "liquid, soft, formed, hard"
        string color "yellow, brown, green, etc"
        boolean hasRash "Rash present"
        string rashSeverity "mild, moderate, severe"
        string rashTreatment "Treatment applied"
        string notes "Additional notes"
        timestamp createdAt "Record creation"
        string createdBy FK "User who logged"
    }
    
    SleepRecord {
        string id PK "Auto-generated ID"
        string babyId FK "Reference to baby"
        timestamp startTime "Sleep start"
        timestamp endTime "Sleep end (optional)"
        number duration "Duration in minutes"
        enum sleepType "nap, night"
        string location "crib, bed, stroller, etc"
        string quality "excellent, good, fair, poor"
        object environment "Sleep environment details"
        string notes "Additional notes"
        timestamp createdAt "Record creation"
        string createdBy FK "User who logged"
    }
    
    MedicineRecord {
        string id PK "Auto-generated ID"
        string babyId FK "Reference to baby"
        string medicineName "Medicine name"
        enum type "liquid, tablet, drops, etc"
        number dosage "Dosage amount"
        enum unit "ml, mg, drops, applications"
        timestamp givenAt "When administered"
        string prescribedBy "Doctor's name"
        string reason "Condition treated"
        string frequency "once, twice, etc"
        timestamp nextDoseTime "Next dose time"
        boolean isCompleted "Completed treatment"
        array sideEffects "Side effects noted"
        string notes "Additional notes"
        timestamp createdAt "Record creation"
        string createdBy FK "User who logged"
    }
    
    GrowthRecord {
        string id PK "Auto-generated ID"
        string babyId FK "Reference to baby"
        timestamp recordedAt "Measurement date"
        object measurements "Weight, height, head circumference"
        object percentiles "Growth percentiles"
        string notes "Additional notes"
        string recordedBy "Healthcare provider"
        string location "Where measured"
        timestamp createdAt "Record creation"
        string createdBy FK "User who logged"
    }
    
    Note {
        string id PK "Auto-generated ID"
        string babyId FK "Reference to baby"
        string title "Note title"
        string content "Note content"
        enum category "milestone, health, behavior, etc"
        array tags "Tags for filtering"
        array attachments "Media attachments"
        boolean isImportant "Important flag"
        timestamp reminderDate "Optional reminder"
        timestamp createdAt "Record creation"
        timestamp updatedAt "Last updated"
        string createdBy FK "User who logged"
    }
    
    User ||--o{ Baby : "owns"
    Baby ||--o{ FeedingRecord : "has"
    Baby ||--o{ DiaperRecord : "has"
    Baby ||--o{ SleepRecord : "has"
    Baby ||--o{ MedicineRecord : "has"
    Baby ||--o{ GrowthRecord : "has"
    Baby ||--o{ Note : "has"
```

## Data Flow Diagrams

### 1. User Authentication Flow

```mermaid
sequenceDiagram
    participant U as User
    participant A as Flutter App
    participant FA as Firebase Auth
    participant FS as Firestore
    
    U->>A: Open App
    A->>FA: Check Auth State
    alt User Not Authenticated
        FA->>A: Not Authenticated
        A->>U: Show Login Screen
        U->>A: Enter Credentials
        A->>FA: Authenticate User
        FA->>A: Return User Token
    else User Authenticated
        FA->>A: Return User Token
    end
    A->>FS: Initialize User Document
    FS->>A: Return User Data
    A->>U: Show Dashboard
```

### 2. Data Creation Flow

```mermaid
sequenceDiagram
    participant U as User
    participant A as Flutter App
    participant P as Provider
    participant R as Repository
    participant FS as Firestore
    
    U->>A: Add New Record
    A->>P: Call Provider Method
    P->>R: Call Repository Method
    R->>FS: Create Document
    FS->>R: Return Document ID
    R->>P: Return Success
    P->>A: Update UI State
    A->>U: Show Success Feedback
    
    Note over FS: Real-time listeners update other devices
```

### 3. Real-time Data Sync

```mermaid
sequenceDiagram
    participant D1 as Device 1
    participant FS as Firestore
    participant D2 as Device 2
    
    D1->>FS: Create/Update Record
    FS-->>D2: Real-time Update
    D2->>D2: Update Local State
    D2->>D2: Refresh UI
    
    Note over FS: Offline changes sync when reconnected
```

## Collection Structure Hierarchy

```
/users/{userId}
├── /babies/{babyId}
│   ├── /feedings/{feedingId}
│   ├── /diapers/{diaperId}
│   ├── /sleep/{sleepId}
│   ├── /medicines/{medicineId}
│   ├── /growth/{growthId}
│   └── /notes/{noteId}
└── (user document fields)
```

## Data Access Patterns

### Read Operations

1. **Dashboard Data Loading**
   ```typescript
   // Load today's summary for all activities
   const today = startOfDay(new Date());
   const tomorrow = addDays(today, 1);
   
   // Parallel queries for better performance
   Promise.all([
     getFeedingsInRange(babyId, today, tomorrow),
     getDiapersInRange(babyId, today, tomorrow),
     getSleepInRange(babyId, today, tomorrow),
     getMedicinesDueToday(babyId, today, tomorrow)
   ]);
   ```

2. **Historical Data Analysis**
   ```typescript
   // Load data for date range analysis
   const weekData = await Promise.all([
     getFeedingsInRange(babyId, startDate, endDate),
     getDiapersInRange(babyId, startDate, endDate),
     getSleepInRange(babyId, startDate, endDate)
   ]);
   ```

3. **Real-time Monitoring**
   ```typescript
   // Active sleep session tracking
   const activeSleepQuery = query(
     collection(db, `users/${userId}/babies/${babyId}/sleep`),
     where('endTime', '==', null),
     orderBy('startTime', 'desc'),
     limit(1)
   );
   ```

### Write Operations

1. **Batch Operations**
   ```typescript
   // Update multiple related records atomically
   const batch = writeBatch(db);
   batch.set(feedingRef, feedingData);
   batch.update(babyRef, { lastFed: feedingData.startTime });
   await batch.commit();
   ```

2. **Optimistic Updates**
   ```typescript
   // Update UI immediately, rollback on error
   provider.addOptimisticUpdate(newRecord);
   try {
     await repository.create(newRecord);
   } catch (error) {
     provider.rollbackOptimisticUpdate(newRecord.id);
     throw error;
   }
   ```

## Security Model

### Data Isolation
- Each user can only access their own data
- Baby data is isolated under user collections
- All operations require authentication

### Permission Levels
```typescript
interface SecurityRules {
  users: {
    read: "own_data_only",
    write: "own_data_only"
  },
  babies: {
    read: "parent_only",
    write: "parent_only",
    create: "authenticated_users"
  },
  records: {
    read: "baby_parent_only",
    write: "baby_parent_only",
    create: "baby_parent_only"
  }
}
```

## Performance Optimization

### Indexing Strategy
1. **Single Field Indexes**: Automatic for all fields
2. **Composite Indexes**: Optimized for common queries
3. **Collection Group Queries**: Enabled for cross-baby analytics

### Caching Strategy
1. **Local Storage**: Critical data cached locally
2. **Memory Cache**: Frequently accessed data
3. **Image Caching**: Baby photos and attachments

### Query Optimization
1. **Pagination**: Cursor-based pagination for large datasets
2. **Selective Loading**: Only load required fields
3. **Batch Loading**: Group related queries

## Data Validation

### Client-side Validation
```typescript
interface ValidationRules {
  required: string[];
  types: Record<string, string>;
  constraints: Record<string, any>;
  custom: Record<string, Function>;
}
```

### Server-side Validation
- Firestore security rules validate data structure
- Cloud Functions perform business logic validation
- Data integrity checks prevent corruption

## Migration & Versioning

### Schema Evolution
1. **Backward Compatibility**: New fields are optional
2. **Data Migration**: Cloud Functions handle migrations
3. **Version Control**: Schema versions tracked

### Migration Process
```typescript
// Example migration function
export const migrateBabyData = functions.firestore
  .document('users/{userId}/babies/{babyId}')
  .onWrite(async (change, context) => {
    const newData = change.after.data();
    if (!newData.schemaVersion || newData.schemaVersion < CURRENT_VERSION) {
      // Perform migration
      await migrateToCurrentSchema(change.after.ref, newData);
    }
  });
```

## Analytics & Monitoring

### Key Metrics
1. **User Engagement**: Daily/Monthly active users
2. **Feature Usage**: Track which features are used most
3. **Performance**: Query execution times
4. **Errors**: Track and alert on errors

### Data Export
1. **User Data Export**: GDPR compliance
2. **Analytics Export**: Business intelligence
3. **Backup Export**: Disaster recovery

## Future Considerations

### Scalability
- Sharding strategy for large user bases
- Read replicas for improved performance
- CDN for media content

### Advanced Features
- Machine learning insights
- Predictive analytics
- Multi-baby household support
- Healthcare provider integration

### Compliance
- HIPAA compliance for health data
- GDPR compliance for EU users
- Data retention policies
- Privacy controls

This data architecture provides a robust foundation for the Pegki Baby Care application while maintaining flexibility for future enhancements and ensuring data security and privacy.