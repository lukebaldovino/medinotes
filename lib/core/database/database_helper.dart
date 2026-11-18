import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';
import 'database_tables.dart';

class DatabaseHelper {
  static const String _databaseName = 'medinotes.db';
  static const int _databaseVersion = 1;

  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Crucial: SQLite has foreign keys turned off by default
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Patients Table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.tablePatients} (
        ${DatabaseTables.colPatientId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseTables.colPatientFullName} TEXT NOT NULL,
        ${DatabaseTables.colPatientBirthDate} TEXT NOT NULL,
        ${DatabaseTables.colPatientSex} TEXT NOT NULL,
        ${DatabaseTables.colPatientBloodType} TEXT,
        ${DatabaseTables.colPatientContactNumber} TEXT,
        ${DatabaseTables.colPatientEmergencyContact} TEXT,
        ${DatabaseTables.colPatientAllergies} TEXT,
        ${DatabaseTables.colPatientCreatedAt} TEXT NOT NULL,
        ${DatabaseTables.colPatientUpdatedAt} TEXT NOT NULL
      );
    ''');

    // 2. Record Categories Table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.tableRecordCategories} (
        ${DatabaseTables.colCategoryId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseTables.colCategoryName} TEXT NOT NULL UNIQUE,
        ${DatabaseTables.colCategoryIcon} TEXT NOT NULL
      );
    ''');

    // 3. Medical Records Table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.tableMedicalRecords} (
        ${DatabaseTables.colRecordId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseTables.colRecordTitle} TEXT NOT NULL,
        ${DatabaseTables.colRecordCategoryId} INTEGER NOT NULL,
        ${DatabaseTables.colRecordDescription} TEXT,
        ${DatabaseTables.colRecordDate} TEXT NOT NULL,
        ${DatabaseTables.colRecordDoctorName} TEXT,
        ${DatabaseTables.colRecordFacilityName} TEXT,
        ${DatabaseTables.colRecordFilePath} TEXT,
        ${DatabaseTables.colRecordFileType} TEXT,
        ${DatabaseTables.colRecordCreatedAt} TEXT NOT NULL,
        ${DatabaseTables.colRecordUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DatabaseTables.colRecordCategoryId}) 
          REFERENCES ${DatabaseTables.tableRecordCategories} (${DatabaseTables.colCategoryId}) 
          ON DELETE RESTRICT
      );
    ''');

    // 4. Doctors Table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.tableDoctors} (
        ${DatabaseTables.colDoctorId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseTables.colDoctorFullName} TEXT NOT NULL,
        ${DatabaseTables.colDoctorSpecialty} TEXT NOT NULL,
        ${DatabaseTables.colDoctorClinicName} TEXT NOT NULL,
        ${DatabaseTables.colDoctorAddress} TEXT NOT NULL,
        ${DatabaseTables.colDoctorContactNumber} TEXT NOT NULL,
        ${DatabaseTables.colDoctorDescription} TEXT,
        ${DatabaseTables.colDoctorImagePath} TEXT,
        ${DatabaseTables.colDoctorIsFavorite} INTEGER NOT NULL DEFAULT 0
      );
    ''');

    // 5. Visits Table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.tableVisits} (
        ${DatabaseTables.colVisitId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseTables.colVisitDoctorId} INTEGER,
        ${DatabaseTables.colVisitDate} TEXT NOT NULL,
        ${DatabaseTables.colVisitReason} TEXT NOT NULL,
        ${DatabaseTables.colVisitDiagnosis} TEXT,
        ${DatabaseTables.colVisitNotes} TEXT,
        ${DatabaseTables.colVisitCreatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DatabaseTables.colVisitDoctorId}) 
          REFERENCES ${DatabaseTables.tableDoctors} (${DatabaseTables.colDoctorId}) 
          ON DELETE SET NULL
      );
    ''');

    // Performance Indexes
    await db.execute('''
      CREATE INDEX idx_medical_records_date 
      ON ${DatabaseTables.tableMedicalRecords} (${DatabaseTables.colRecordDate} DESC);
    ''');
    await db.execute('''
      CREATE INDEX idx_medical_records_category 
      ON ${DatabaseTables.tableMedicalRecords} (${DatabaseTables.colRecordCategoryId});
    ''');
    await db.execute('''
      CREATE INDEX idx_medical_records_title 
      ON ${DatabaseTables.tableMedicalRecords} (${DatabaseTables.colRecordTitle});
    ''');
    await db.execute('''
      CREATE INDEX idx_doctors_specialty 
      ON ${DatabaseTables.tableDoctors} (${DatabaseTables.colDoctorSpecialty});
    ''');
    await db.execute('''
      CREATE INDEX idx_doctors_name 
      ON ${DatabaseTables.tableDoctors} (${DatabaseTables.colDoctorFullName});
    ''');
    await db.execute('''
      CREATE INDEX idx_visits_date 
      ON ${DatabaseTables.tableVisits} (${DatabaseTables.colVisitDate} DESC);
    ''');

    // Seed Initial Data
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    // 1. Seed Categories
    final batch = db.batch();
    for (final cat in AppConstants.defaultCategories) {
      batch.insert(
        DatabaseTables.tableRecordCategories,
        {
          DatabaseTables.colCategoryId: cat['id'],
          DatabaseTables.colCategoryName: cat['name'],
          DatabaseTables.colCategoryIcon: cat['icon'],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    // 2. Seed Sample Doctors
    final sampleDoctors = [
      {
        DatabaseTables.colDoctorFullName: 'Dr. Maria Santos, MD',
        DatabaseTables.colDoctorSpecialty: 'General Medicine',
        DatabaseTables.colDoctorClinicName: 'St. Luke Family Care Clinic',
        DatabaseTables.colDoctorAddress: 'Suite 302, Medical Arts Bldg, Metro Hospital',
        DatabaseTables.colDoctorContactNumber: '+63 917 123 4567',
        DatabaseTables.colDoctorDescription:
            'Family physician with over 12 years of experience providing comprehensive primary care and preventive health checkups.',
        DatabaseTables.colDoctorIsFavorite: 1,
      },
      {
        DatabaseTables.colDoctorFullName: 'Dr. Arthur Pendelton, MD, FACC',
        DatabaseTables.colDoctorSpecialty: 'Cardiology',
        DatabaseTables.colDoctorClinicName: 'Heart & Vascular Care Center',
        DatabaseTables.colDoctorAddress: 'Room 512, Heart Institute, 45 Healthcare Ave',
        DatabaseTables.colDoctorContactNumber: '+63 918 234 5678',
        DatabaseTables.colDoctorDescription:
            'Interventional cardiologist specializing in hypertension, coronary artery disease, and lipid management.',
        DatabaseTables.colDoctorIsFavorite: 1,
      },
      {
        DatabaseTables.colDoctorFullName: 'Dr. Elena Reyes, MD, FPPS',
        DatabaseTables.colDoctorSpecialty: 'Pediatrics',
        DatabaseTables.colDoctorClinicName: 'Children Wellness & Vaccine Hub',
        DatabaseTables.colDoctorAddress: '2nd Floor, Pediatric Wing, City Children Hospital',
        DatabaseTables.colDoctorContactNumber: '+63 920 345 6789',
        DatabaseTables.colDoctorDescription:
            'Dedicated pediatrician focusing on newborn care, child development milestones, and comprehensive vaccination schedules.',
        DatabaseTables.colDoctorIsFavorite: 0,
      },
      {
        DatabaseTables.colDoctorFullName: 'Dr. Carlos Mendoza, MD, FPDS',
        DatabaseTables.colDoctorSpecialty: 'Dermatology',
        DatabaseTables.colDoctorClinicName: 'DermaSkin & Allergy Specialists',
        DatabaseTables.colDoctorAddress: 'Unit 4B, Plaza Wellness Center, Bonifacio Blvd',
        DatabaseTables.colDoctorContactNumber: '+63 922 456 7890',
        DatabaseTables.colDoctorDescription:
            'Board-certified dermatologist specializing in eczema, contact dermatitis, psoriasis, and cosmetic dermatology.',
        DatabaseTables.colDoctorIsFavorite: 0,
      },
      {
        DatabaseTables.colDoctorFullName: 'Dr. Beatrice Lim, MD, FPOA',
        DatabaseTables.colDoctorSpecialty: 'Orthopedics',
        DatabaseTables.colDoctorClinicName: 'Bone & Joint Sports Medicine Center',
        DatabaseTables.colDoctorAddress: 'Suite 108, Orthopedic Pavilion, West Wing',
        DatabaseTables.colDoctorContactNumber: '+63 925 567 8901',
        DatabaseTables.colDoctorDescription:
            'Orthopedic surgeon specializing in sports injuries, knee and hip arthroplasty, and musculoskeletal rehabilitation.',
        DatabaseTables.colDoctorIsFavorite: 0,
      },
      {
        DatabaseTables.colDoctorFullName: 'Dr. Victor Navarro, MD, FPNA',
        DatabaseTables.colDoctorSpecialty: 'Neurology',
        DatabaseTables.colDoctorClinicName: 'NeuroCare Center',
        DatabaseTables.colDoctorAddress: 'Room 601, Neuroscience Institute, Central Hospital',
        DatabaseTables.colDoctorContactNumber: '+63 927 678 9012',
        DatabaseTables.colDoctorDescription:
            'Neurologist with subspecialty expertise in migraine management, neuropathy, and stroke recovery.',
        DatabaseTables.colDoctorIsFavorite: 0,
      },
      {
        DatabaseTables.colDoctorFullName: 'Dr. Jasmine Cruz, MD',
        DatabaseTables.colDoctorSpecialty: 'Ophthalmology',
        DatabaseTables.colDoctorClinicName: 'ClearVision Eye Center',
        DatabaseTables.colDoctorAddress: 'Unit 201, Vision Plaza, Medical Parkway',
        DatabaseTables.colDoctorContactNumber: '+63 928 789 0123',
        DatabaseTables.colDoctorDescription:
            'Comprehensive ophthalmologist providing eye exams, glaucoma screening, and refractive surgery consultations.',
        DatabaseTables.colDoctorIsFavorite: 0,
      },
      {
        DatabaseTables.colDoctorFullName: 'Dr. Gabriel Tan, MD',
        DatabaseTables.colDoctorSpecialty: 'ENT',
        DatabaseTables.colDoctorClinicName: 'Ear, Nose & Throat Specialists',
        DatabaseTables.colDoctorAddress: 'Suite 310, Ambulatory Center, East Health Center',
        DatabaseTables.colDoctorContactNumber: '+63 929 890 1234',
        DatabaseTables.colDoctorDescription:
            'Otolaryngologist managing sinus disorders, chronic allergic rhinitis, hearing loss, and throat conditions.',
        DatabaseTables.colDoctorIsFavorite: 0,
      },
    ];

    for (final doc in sampleDoctors) {
      batch.insert(
        DatabaseTables.tableDoctors,
        doc,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration framework ready for future upgrades
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
