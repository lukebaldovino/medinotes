import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../core/database/database_tables.dart';
import '../models/patient.dart';

abstract class PatientRepository {
  Future<Patient?> getPatient();
  Future<Patient> savePatient(Patient patient);
  Future<bool> hasProfile();
}

class SqlitePatientRepository implements PatientRepository {
  final DatabaseHelper _dbHelper;

  SqlitePatientRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<Patient?> getPatient() async {
    final db = await _dbHelper.database;
    final results = await db.query(
      DatabaseTables.tablePatients,
      limit: 1,
      orderBy: '${DatabaseTables.colPatientId} ASC',
    );

    if (results.isNotEmpty) {
      return Patient.fromMap(results.first);
    }
    return null;
  }

  @override
  Future<bool> hasProfile() async {
    final patient = await getPatient();
    return patient != null;
  }

  @override
  Future<Patient> savePatient(Patient patient) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    final existing = await getPatient();
    if (existing == null) {
      // Create new profile
      final newPatient = patient.copyWith(
        createdAt: now,
        updatedAt: now,
      );
      final id = await db.insert(
        DatabaseTables.tablePatients,
        newPatient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return newPatient.copyWith(id: id);
    } else {
      // Update existing profile
      final updatedPatient = patient.copyWith(
        id: existing.id,
        createdAt: existing.createdAt,
        updatedAt: now,
      );
      await db.update(
        DatabaseTables.tablePatients,
        updatedPatient.toMap(),
        where: '${DatabaseTables.colPatientId} = ?',
        whereArgs: [existing.id],
      );
      return updatedPatient;
    }
  }
}
