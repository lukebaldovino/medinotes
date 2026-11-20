import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../core/database/database_tables.dart';
import '../core/storage/file_storage_service.dart';
import '../models/medical_record.dart';
import '../models/record_category.dart';

abstract class MedicalRecordRepository {
  Future<List<RecordCategory>> getCategories();
  Future<List<MedicalRecord>> getRecords({String? searchQuery, int? categoryId});
  Future<MedicalRecord?> getRecordById(int id);
  Future<int> insertRecord(MedicalRecord record);
  Future<int> updateRecord(MedicalRecord record);
  Future<int> deleteRecord(int id);
  Future<int> getTotalRecordsCount();
  Future<List<MedicalRecord>> getRecentRecords({int limit = 3});
}

class SqliteMedicalRecordRepository implements MedicalRecordRepository {
  final DatabaseHelper _dbHelper;
  final FileStorageService _storageService;

  SqliteMedicalRecordRepository({
    DatabaseHelper? dbHelper,
    FileStorageService? storageService,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _storageService = storageService ?? FileStorageService.instance;

  @override
  Future<List<RecordCategory>> getCategories() async {
    final db = await _dbHelper.database;
    final results = await db.query(
      DatabaseTables.tableRecordCategories,
      orderBy: '${DatabaseTables.colCategoryId} ASC',
    );
    return results.map((e) => RecordCategory.fromMap(e)).toList();
  }

  @override
  Future<List<MedicalRecord>> getRecords({String? searchQuery, int? categoryId}) async {
    final db = await _dbHelper.database;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (categoryId != null) {
      whereClauses.add('r.${DatabaseTables.colRecordCategoryId} = ?');
      whereArgs.add(categoryId);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final sanitized = searchQuery.trim().replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
      whereClauses.add("r.${DatabaseTables.colRecordTitle} LIKE ? ESCAPE '\\'");
      whereArgs.add('%$sanitized%');
    }

    final whereString = whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';

    final query = '''
      SELECT 
        r.*, 
        c.${DatabaseTables.colCategoryName} AS category_name, 
        c.${DatabaseTables.colCategoryIcon} AS category_icon
      FROM ${DatabaseTables.tableMedicalRecords} r
      JOIN ${DatabaseTables.tableRecordCategories} c 
        ON r.${DatabaseTables.colRecordCategoryId} = c.${DatabaseTables.colCategoryId}
      $whereString
      ORDER BY r.${DatabaseTables.colRecordDate} DESC, r.${DatabaseTables.colRecordId} DESC
    ''';

    final results = await db.rawQuery(query, whereArgs);
    return results.map((e) => MedicalRecord.fromMap(e)).toList();
  }

  @override
  Future<MedicalRecord?> getRecordById(int id) async {
    final db = await _dbHelper.database;
    final query = '''
      SELECT 
        r.*, 
        c.${DatabaseTables.colCategoryName} AS category_name, 
        c.${DatabaseTables.colCategoryIcon} AS category_icon
      FROM ${DatabaseTables.tableMedicalRecords} r
      JOIN ${DatabaseTables.tableRecordCategories} c 
        ON r.${DatabaseTables.colRecordCategoryId} = c.${DatabaseTables.colCategoryId}
      WHERE r.${DatabaseTables.colRecordId} = ?
      LIMIT 1
    ''';

    final results = await db.rawQuery(query, [id]);
    if (results.isNotEmpty) {
      return MedicalRecord.fromMap(results.first);
    }
    return null;
  }

  @override
  Future<int> insertRecord(MedicalRecord record) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final toInsert = record.copyWith(
      createdAt: now,
      updatedAt: now,
    );

    return await db.insert(
      DatabaseTables.tableMedicalRecords,
      toInsert.toMap(),
    );
  }

  @override
  Future<int> updateRecord(MedicalRecord record) async {
    final db = await _dbHelper.database;

    final previous = record.id == null ? null : await getRecordById(record.id!);

    final now = DateTime.now().toIso8601String();
    final toUpdate = record.copyWith(updatedAt: now);

    final rowsAffected = await db.update(
      DatabaseTables.tableMedicalRecords,
      toUpdate.toMap(),
      where: '${DatabaseTables.colRecordId} = ?',
      whereArgs: [record.id],
    );

    // Delete the superseded attachment only after the row is committed, so a
    // failed update cannot leave the database pointing at a removed file.
    final previousPath = previous?.filePath;
    if (rowsAffected > 0 && previousPath != null && previousPath != toUpdate.filePath) {
      await _storageService.deleteFile(previousPath);
    }

    return rowsAffected;
  }

  @override
  Future<int> deleteRecord(int id) async {
    final db = await _dbHelper.database;

    // Clean up physical file attachment if exists
    final record = await getRecordById(id);
    if (record?.filePath != null) {
      await _storageService.deleteFile(record!.filePath);
    }

    return await db.delete(
      DatabaseTables.tableMedicalRecords,
      where: '${DatabaseTables.colRecordId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> getTotalRecordsCount() async {
    final db = await _dbHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseTables.tableMedicalRecords}'),
    );
    return count ?? 0;
  }

  @override
  Future<List<MedicalRecord>> getRecentRecords({int limit = 3}) async {
    final db = await _dbHelper.database;
    final query = '''
      SELECT 
        r.*, 
        c.${DatabaseTables.colCategoryName} AS category_name, 
        c.${DatabaseTables.colCategoryIcon} AS category_icon
      FROM ${DatabaseTables.tableMedicalRecords} r
      JOIN ${DatabaseTables.tableRecordCategories} c 
        ON r.${DatabaseTables.colRecordCategoryId} = c.${DatabaseTables.colCategoryId}
      ORDER BY r.${DatabaseTables.colRecordDate} DESC, r.${DatabaseTables.colRecordId} DESC
      LIMIT ?
    ''';

    final results = await db.rawQuery(query, [limit]);
    return results.map((e) => MedicalRecord.fromMap(e)).toList();
  }
}
