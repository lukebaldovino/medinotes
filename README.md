# MediNotes — Mobile Medical Records & Doctor Discovery (MVP)

A patient-centered mobile application designed to help patients organize and manage their personal medical records and discover healthcare providers — **100% offline-first**.

---

## 1. Project Overview

MediNotes provides patients with a portable, private, and offline-first vault for their health information. Users can store their medical profile, track prescriptions and diagnostic results, securely attach PDFs and photos to medical records, find local doctors by specialty, and record consultation history.

### Core Architectural Principles
- **Offline First**: All data is stored locally in SQLite; zero internet connection is required.
- **Physical File Separation**: Document binaries (PDFs, JPGs, PNGs) are stored in the application's sandboxed local documents directory; SQLite stores only structured metadata and relative file paths.
- **Relative Path Storage**: Storing relative paths (e.g. `medical_records_files/record_123.pdf`) protects against device sandbox path UUID changes across OS updates and reboots.
- **Separation of Concerns**: UI widgets communicate exclusively through **Providers**, which call **Repositories**, which coordinate with the **SQLite Database** (`DatabaseHelper`) and **Local File Storage** (`FileStorageService`).

---

## 2. Technology Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart SDK `^3.14.0`)
- **UI Framework & Theming**: Material 3 Design
- **State Management**: [`provider: ^6.1.2`](https://pub.dev/packages/provider)
- **Local Database**: [`sqflite: ^2.4.1`](https://pub.dev/packages/sqflite) with [`path: ^1.9.1`](https://pub.dev/packages/path)
- **Local File Storage**: [`path_provider: ^2.1.5`](https://pub.dev/packages/path_provider)
- **Document Selection**: [`file_picker: ^8.1.7`](https://pub.dev/packages/file_picker)
- **Image Selection**: [`image_picker: ^1.1.2`](https://pub.dev/packages/image_picker)
- **Document Viewing**: [`open_filex: ^4.6.0`](https://pub.dev/packages/open_filex)
- **Date Formatting**: [`intl: ^0.20.2`](https://pub.dev/packages/intl)

---

## 3. Application Architecture & Folder Structure

```
lib/
├── main.dart                                    # App entry point, MultiProvider setup, theme
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                      # Design palette & medical tokens
│   │   └── app_constants.dart                   # Blood types, categories, specialties
│   ├── database/
│   │   ├── database_helper.dart                 # SQLite singleton, DDL, migrations, seeds
│   │   └── database_tables.dart                 # Table & column name constants
│   ├── storage/
│   │   └── file_storage_service.dart            # Managed sandboxed file operations
│   └── widgets/
│       ├── custom_text_field.dart               # Form input field with validation
│       ├── empty_state_view.dart                # Responsive empty state placeholder
│       ├── confirmation_dialog.dart             # Delete confirmation modal
│       └── category_badge.dart                  # Categorization chip/badge
├── models/
│   ├── patient.dart                             # Patient profile domain model
│   ├── record_category.dart                     # Category model (Prescriptions, Labs, etc.)
│   ├── medical_record.dart                      # Medical record domain model
│   ├── doctor.dart                              # Doctor profile domain model
│   └── visit.dart                               # Consultation visit domain model
├── repositories/
│   ├── patient_repository.dart                  # Patient SQLite CRUD
│   ├── medical_record_repository.dart           # Records CRUD, search, filter
│   ├── doctor_repository.dart                   # Doctor queries & favorites
│   └── visit_repository.dart                    # Visit history queries with joins
├── providers/
│   ├── patient_provider.dart                    # Patient state & calculated age/initials
│   ├── record_provider.dart                     # Records timeline, category filters, search
│   ├── doctor_provider.dart                     # Doctor directory & specialty filters
│   └── visit_provider.dart                      # Consultations history state
└── features/
    ├── navigation/
    │   └── main_navigation_screen.dart          # 4-tab bottom navigation shell
    ├── dashboard/
    │   ├── screens/dashboard_screen.dart        # Metrics, greeting, quick actions, recent records
    │   └── widgets/                             # StatCard, QuickActionButton
    ├── profile/
    │   ├── screens/                             # PatientProfileScreen, EditProfileScreen
    │   └── widgets/allergy_card.dart            # High-visibility allergy alert card
    ├── records/
    │   ├── screens/                             # RecordsListScreen, AddEditRecordScreen, RecordDetailsScreen
    │   └── widgets/                             # RecordListTile, AttachmentPreviewCard
    ├── doctors/
    │   ├── screens/                             # DoctorDirectoryScreen, DoctorDetailsScreen
    │   └── widgets/doctor_list_card.dart        # Doctor directory card
    └── visits/
        ├── screens/                             # VisitsScreen, AddEditVisitScreen
        └── widgets/visit_list_tile.dart         # Consultation history card
```

---

## 4. SQLite Database Schema

Foreign key constraints are enforced on connection via `PRAGMA foreign_keys = ON;`.

### 1. `patients` Table
Stores the single local user profile.
```sql
CREATE TABLE patients (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  full_name TEXT NOT NULL,
  birth_date TEXT NOT NULL,
  sex TEXT NOT NULL,
  blood_type TEXT,
  contact_number TEXT,
  emergency_contact TEXT,
  allergies TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

### 2. `record_categories` Table
Pre-seeded with: *Prescriptions*, *Lab Results*, *Imaging & Scans*, *Vaccinations*, *Clinical Notes*, *General*.
```sql
CREATE TABLE record_categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  icon TEXT NOT NULL
);
```

### 3. `medical_records` Table
Stores manual records, classifications, and relative file paths.
```sql
CREATE TABLE medical_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  category_id INTEGER NOT NULL,
  description TEXT,
  record_date TEXT NOT NULL,
  doctor_name TEXT,
  facility_name TEXT,
  file_path TEXT,
  file_type TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (category_id) REFERENCES record_categories (id) ON DELETE RESTRICT
);

CREATE INDEX idx_medical_records_date ON medical_records (record_date DESC);
CREATE INDEX idx_medical_records_category ON medical_records (category_id);
CREATE INDEX idx_medical_records_title ON medical_records (title);
```

### 4. `doctors` Table
Pre-seeded with sample healthcare providers across diverse specialties.
```sql
CREATE TABLE doctors (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  full_name TEXT NOT NULL,
  specialty TEXT NOT NULL,
  clinic_name TEXT NOT NULL,
  address TEXT NOT NULL,
  contact_number TEXT NOT NULL,
  description TEXT,
  image_path TEXT,
  is_favorite INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_doctors_specialty ON doctors (specialty);
CREATE INDEX idx_doctors_name ON doctors (full_name);
```

### 5. `visits` Table
Tracks patient consultations and clinic visits, with optional doctor association.
```sql
CREATE TABLE visits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  doctor_id INTEGER,
  visit_date TEXT NOT NULL,
  reason TEXT NOT NULL,
  diagnosis TEXT,
  notes TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (doctor_id) REFERENCES doctors (id) ON DELETE SET NULL
);

CREATE INDEX idx_visits_date ON visits (visit_date DESC);
```

---

## 5. Getting Started & Development

### Prerequisites
- Flutter SDK `^3.14.0` (with Android toolchain)
- Android Studio or VS Code with Flutter extension
- An Android Emulator (API 30+) or physical device

### Installation & Run
1. Fetch dependencies:
   ```bash
   flutter pub get
   ```
2. Run code analysis (verifies zero lint warnings/errors):
   ```bash
   flutter analyze
   ```
3. Run the automated test suite:
   ```bash
   flutter test
   ```
4. Launch the application:
   ```bash
   flutter run
   ```

---

## 6. Testing & Visible Verification

All features can be tested directly on the device or emulator:
1. **Patient Profile**: Create profile in the Profile tab; verify name, blood type, and allergy alerts appear on Dashboard; restart app to confirm data persists.
2. **Medical Records**: Add records with different dates; verify chronological ordering (`record_date DESC`), search by title, and category filter chips.
3. **Document Attachments**: Attach a PDF or camera/gallery photo to a record; verify it copies to `medical_records_files/`; tap the document in Record Details to open with system viewer; delete record to confirm file cleanup.
4. **Doctor Discovery**: Navigate to Find Doctors tab; filter by specialty (e.g. Cardiology); search by doctor or clinic; toggle favorite stars; view doctor bio and clinic contact details.
5. **Consultation History**: Log visits via Dashboard quick action or from Doctor Profile; review the chronological visit history with diagnoses and notes.
