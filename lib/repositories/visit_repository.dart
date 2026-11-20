import 'package:sqflite/sqflite.dart';

import '../core/database/database_helper.dart';
import '../core/database/database_tables.dart';
import '../models/visit.dart';

abstract class VisitRepository {
  Future<List<Visit>> getVisits({int? doctorId});
  Future<Visit?> getVisitById(int id);
  Future<int> insertVisit(Visit visit);
  Future<int> updateVisit(Visit visit);
  Future<int> deleteVisit(int id);
  Future<Visit?> getLatestVisit();
  Future<int> getTotalVisitsCount();
}

class SqliteVisitRepository implements VisitRepository {
  final DatabaseHelper _dbHelper;

  SqliteVisitRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Visit>> getVisits({int? doctorId}) async {
    final db = await _dbHelper.database;

    final whereClause = doctorId != null ? 'WHERE v.${DatabaseTables.colVisitDoctorId} = ?' : '';
    final whereArgs = doctorId != null ? [doctorId] : null;

    final query = '''
      SELECT 
        v.*,
        d.${DatabaseTables.colDoctorFullName} AS doctor_name,
        d.${DatabaseTables.colDoctorSpecialty} AS doctor_specialty,
        d.${DatabaseTables.colDoctorClinicName} AS clinic_name
      FROM ${DatabaseTables.tableVisits} v
      LEFT JOIN ${DatabaseTables.tableDoctors} d 
        ON v.${DatabaseTables.colVisitDoctorId} = d.${DatabaseTables.colDoctorId}
      $whereClause
      ORDER BY v.${DatabaseTables.colVisitDate} DESC, v.${DatabaseTables.colVisitId} DESC
    ''';

    final results = await db.rawQuery(query, whereArgs);
    return results.map((e) => Visit.fromMap(e)).toList();
  }

  @override
  Future<Visit?> getVisitById(int id) async {
    final db = await _dbHelper.database;
    final query = '''
      SELECT 
        v.*,
        d.${DatabaseTables.colDoctorFullName} AS doctor_name,
        d.${DatabaseTables.colDoctorSpecialty} AS doctor_specialty,
        d.${DatabaseTables.colDoctorClinicName} AS clinic_name
      FROM ${DatabaseTables.tableVisits} v
      LEFT JOIN ${DatabaseTables.tableDoctors} d 
        ON v.${DatabaseTables.colVisitDoctorId} = d.${DatabaseTables.colDoctorId}
      WHERE v.${DatabaseTables.colVisitId} = ?
      LIMIT 1
    ''';

    final results = await db.rawQuery(query, [id]);
    if (results.isNotEmpty) {
      return Visit.fromMap(results.first);
    }
    return null;
  }

  @override
  Future<int> insertVisit(Visit visit) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final toInsert = visit.copyWith(createdAt: now);
    return await db.insert(
      DatabaseTables.tableVisits,
      toInsert.toMap(),
    );
  }

  @override
  Future<int> updateVisit(Visit visit) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseTables.tableVisits,
      visit.toMap(),
      where: '${DatabaseTables.colVisitId} = ?',
      whereArgs: [visit.id],
    );
  }

  @override
  Future<int> deleteVisit(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseTables.tableVisits,
      where: '${DatabaseTables.colVisitId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Visit?> getLatestVisit() async {
    final list = await getVisits();
    if (list.isNotEmpty) return list.first;
    return null;
  }

  @override
  Future<int> getTotalVisitsCount() async {
    final db = await _dbHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseTables.tableVisits}'),
    );
    return count ?? 0;
  }
}
