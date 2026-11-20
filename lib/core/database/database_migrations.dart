import 'package:sqflite/sqflite.dart';

/// A single forward-only schema change that upgrades the database from
/// [fromVersion] to `fromVersion + 1`.
///
/// Migrations run inside a transaction opened by the caller, so [migrate] must
/// not commit or roll back. Every migration owned by the app must be listed in
/// [DatabaseMigrations.all]; the upgrade path fails loudly when a step is
/// missing rather than leaving the schema at an unknown version.
class DatabaseMigration {
  /// Schema version this migration upgrades *from*. It produces
  /// `fromVersion + 1`.
  final int fromVersion;

  /// Short human-readable description used in logs and error messages.
  final String description;

  /// Applies the schema change to [db].
  final Future<void> Function(Database db) migrate;

  const DatabaseMigration({
    required this.fromVersion,
    required this.description,
    required this.migrate,
  });

  /// The schema version this migration produces.
  int get toVersion => fromVersion + 1;
}

/// The ordered set of migrations that bring a user's database up to
/// [latestVersion].
///
/// Bumping the database version requires adding a matching [DatabaseMigration]
/// here; [DatabaseMigrations.buildPath] throws when one is absent.
class DatabaseMigrations {
  DatabaseMigrations._();

  /// Schema version produced by applying every migration in [all].
  ///
  /// Version 1 is the initial schema created by `onCreate`, so there is no
  /// migration that produces it.
  static const int latestVersion = 1;

  /// All migrations known to the app, ordered by [DatabaseMigration.fromVersion].
  ///
  /// Empty today because version 1 is the only released schema. Add entries
  /// here as the schema evolves; each must upgrade exactly one version.
  static const List<DatabaseMigration> all = <DatabaseMigration>[];

  /// Returns the migrations needed to move from [oldVersion] to [newVersion],
  /// in the order they must be applied.
  ///
  /// Throws [StateError] when a required step is missing, when two migrations
  /// claim the same source version, or when the path cannot reach
  /// [newVersion]. Failing loudly here is deliberate: silently skipping a step
  /// would leave the schema out of sync with the code that reads it.
  static List<DatabaseMigration> buildPath({
    required int oldVersion,
    required int newVersion,
  }) {
    if (newVersion < oldVersion) {
      throw StateError(
        'Cannot downgrade database from version $oldVersion to $newVersion. '
        'Destructive downgrades are not supported.',
      );
    }

    if (newVersion == oldVersion) return const <DatabaseMigration>[];

    final bySourceVersion = <int, DatabaseMigration>{};
    for (final migration in all) {
      final existing = bySourceVersion[migration.fromVersion];
      if (existing != null) {
        throw StateError(
          'Duplicate migrations from version ${migration.fromVersion}: '
          '"${existing.description}" and "${migration.description}".',
        );
      }
      bySourceVersion[migration.fromVersion] = migration;
    }

    final path = <DatabaseMigration>[];
    for (var version = oldVersion; version < newVersion; version++) {
      final migration = bySourceVersion[version];
      if (migration == null) {
        throw StateError(
          'Missing database migration from version $version to ${version + 1}. '
          'Add a DatabaseMigration to DatabaseMigrations.all, or the installed '
          'schema will not match this build.',
        );
      }
      path.add(migration);
    }

    return path;
  }
}
