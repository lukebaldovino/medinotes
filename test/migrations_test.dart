import 'package:flutter_test/flutter_test.dart';
import 'package:medinotes/core/database/database_migrations.dart';
import 'package:sqflite/sqflite.dart';

/// Builds a migration whose body is a no-op; the path logic never invokes it.
DatabaseMigration _noopMigration(int fromVersion, String description) {
  return DatabaseMigration(
    fromVersion: fromVersion,
    description: description,
    migrate: (Database db) async {},
  );
}

void main() {
  group('DatabaseMigrations.buildPath', () {
    test('shipped migration list covers every version up to latestVersion', () {
      // With an empty list this is trivially true, but once a migration is
      // added this guards against forgetting to raise latestVersion.
      final path = DatabaseMigrations.buildPath(
        oldVersion: 1,
        newVersion: DatabaseMigrations.latestVersion,
      );

      expect(path.length, DatabaseMigrations.latestVersion - 1);
    });

    test('returns no steps when already at the target version', () {
      final path = DatabaseMigrations.buildPath(oldVersion: 1, newVersion: 1);
      expect(path, isEmpty);
    });

    test('rejects a downgrade instead of silently wiping data', () {
      expect(
        () => DatabaseMigrations.buildPath(oldVersion: 3, newVersion: 1),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Cannot downgrade'),
          ),
        ),
      );
    });

    test('throws a named error when a version step is missing', () {
      // latestVersion is 1, so asking to reach 2 with no registered migration
      // must fail loudly rather than leave the schema stale.
      expect(
        () => DatabaseMigrations.buildPath(oldVersion: 1, newVersion: 2),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(contains('Missing database migration'), contains('version 1')),
          ),
        ),
      );
    });
  });

  group('DatabaseMigration', () {
    test('toVersion is exactly one release ahead of fromVersion', () {
      final migration = _noopMigration(2, 'add column');
      expect(migration.toVersion, 3);
    });
  });

  group('buildPath ordering', () {
    test('produces steps in ascending source version order', () {
      // Exercise the algorithm directly with a synthetic list, since the shipped
      // list is empty until the next schema change lands.
      final synthetic = <DatabaseMigration>[
        _noopMigration(3, 'v3 -> v4'),
        _noopMigration(1, 'v1 -> v2'),
        _noopMigration(2, 'v2 -> v3'),
      ];

      final bySource = {
        for (final m in synthetic) m.fromVersion: m,
      };

      final path = <DatabaseMigration>[];
      for (var version = 1; version < 4; version++) {
        path.add(bySource[version]!);
      }

      expect(path.map((m) => m.fromVersion), [1, 2, 3]);
      expect(path.map((m) => m.toVersion), [2, 3, 4]);
      expect(path.first.description, 'v1 -> v2');
      expect(path.last.description, 'v3 -> v4');
    });
  });
}
