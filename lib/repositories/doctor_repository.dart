import '../core/constants/app_constants.dart';
import '../core/database/database_helper.dart';
import '../core/database/database_tables.dart';
import '../models/doctor.dart';

abstract class DoctorRepository {
  Future<List<Doctor>> getDoctors({String? searchQuery, String? specialty});
  Future<Doctor?> getDoctorById(int id);
  Future<List<String>> getSpecialties();
  Future<void> toggleFavorite(int doctorId, bool isFavorite);
}

class SqliteDoctorRepository implements DoctorRepository {
  final DatabaseHelper _dbHelper;

  SqliteDoctorRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Doctor>> getDoctors({String? searchQuery, String? specialty}) async {
    final db = await _dbHelper.database;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (specialty != null && specialty.trim().isNotEmpty && specialty != 'All') {
      whereClauses.add('${DatabaseTables.colDoctorSpecialty} = ?');
      whereArgs.add(specialty.trim());
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final sanitized = searchQuery.trim().replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
      whereClauses.add("(${DatabaseTables.colDoctorFullName} LIKE ? ESCAPE '\\' OR ${DatabaseTables.colDoctorClinicName} LIKE ? ESCAPE '\\')");
      whereArgs.add('%$sanitized%');
      whereArgs.add('%$sanitized%');
    }

    final whereString = whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';

    final query = '''
      SELECT * FROM ${DatabaseTables.tableDoctors}
      $whereString
      ORDER BY ${DatabaseTables.colDoctorIsFavorite} DESC, ${DatabaseTables.colDoctorFullName} ASC
    ''';

    final results = await db.rawQuery(query, whereArgs);
    return results.map((e) => Doctor.fromMap(e)).toList();
  }

  @override
  Future<Doctor?> getDoctorById(int id) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      DatabaseTables.tableDoctors,
      where: '${DatabaseTables.colDoctorId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return Doctor.fromMap(results.first);
    }
    return null;
  }

  @override
  Future<List<String>> getSpecialties() async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT DISTINCT ${DatabaseTables.colDoctorSpecialty} 
      FROM ${DatabaseTables.tableDoctors}
      ORDER BY ${DatabaseTables.colDoctorSpecialty} ASC
    ''');

    final set = <String>{'All'};
    for (final row in results) {
      final s = row[DatabaseTables.colDoctorSpecialty] as String?;
      if (s != null && s.isNotEmpty) set.add(s);
    }

    // Merge default known specialties
    for (final s in AppConstants.doctorSpecialties) {
      set.add(s);
    }

    return set.toList();
  }

  @override
  Future<void> toggleFavorite(int doctorId, bool isFavorite) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseTables.tableDoctors,
      {DatabaseTables.colDoctorIsFavorite: isFavorite ? 1 : 0},
      where: '${DatabaseTables.colDoctorId} = ?',
      whereArgs: [doctorId],
    );
  }
}
