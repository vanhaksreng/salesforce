import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:salesforce/infrastructure/storage/i_local_storage.dart';
import 'dart:math' show min;

class RealmStorage implements ILocalStorage {
  final Realm _realm;

  RealmStorage(this._realm);

  @override
  void dispose() {
    _realm.close();
  }

  String _buildSortClause(List? sortBy, bool ascending) {
    if (sortBy == null || sortBy.isEmpty) return '';

    final sortClauses = sortBy
        .map((sort) {
          if (sort is! Map<String, String>) return '';
          final field = sort['field'];
          final order = sort['order']?.toUpperCase() ?? (ascending ? 'ASC' : 'DESC');
          return '$field $order';
        })
        .where((clause) => clause.isNotEmpty)
        .join(', ');

    return sortClauses.isEmpty ? '' : 'SORT($sortClauses)';
  }

  @override
  Future<M> add<M extends RealmObject>(M item) async {
    try {
      late M result;
      _realm.write(() {
        result = _realm.add<M>(item, update: true);
      });
      return result;
    } catch (e) {
      debugPrint('Add error: $e');
      rethrow;
    }
  }

  @override
  Future<void> addAll<M extends RealmObject>(List<M> items) async {
    try {
      _realm.write(() {
        _realm.addAll<M>(items, update: true);
      });
    } catch (e) {
      debugPrint('AddAll error: $e');
      rethrow;
    }
  }

  @override
  Future<M> update<M extends RealmObject>(M item) async {
    try {
      _realm.write(() {
        _realm.add(item, update: true);
      });
      return item;
    } catch (e) {
      debugPrint('Update error: $e');
      rethrow;
    }
  }

  Future<List<M>> _get<M extends RealmObject>({Map<String, dynamic>? args, List? sortBy, bool ascending = true}) async {
    var queryString = args != null ? await filters(args: args) : "TRUEPREDICATE";
    final sortClause = _buildSortClause(sortBy, ascending);

    if (sortClause.isNotEmpty) {
      queryString = "$queryString $sortClause";
    }

    return _realm.query<M>(queryString).toList();
  }

  @override
  Future<List<M>> getAll<M extends RealmObject>({
    Map<String, dynamic>? args,
    List? sortBy,
    bool ascending = true,
  }) async {
    return await _get(args: args, sortBy: sortBy, ascending: ascending);
  }

  @override
  Future<M?> getFirst<M extends RealmObject>({Map<String, dynamic>? args, List? sortBy, bool ascending = true}) async {
    final List<M> results = await _get(args: args, sortBy: sortBy, ascending: ascending);

    if (results.isEmpty) {
      return null;
    }

    return results.first;
  }

  @override
  Future<bool> delete<M extends RealmObject>(M item) async {
    try {
      _realm.write(() => _realm.delete(item));
      return true;
    } catch (_) {
      rethrow;
    }
  }

  @override
  M? find<M extends RealmObject>(String primaryKey) {
    return _realm.find<M>(primaryKey);
  }

  String _formatNumberForStringComparison(String numberString) {
    final number = double.tryParse(numberString);
    if (number == null) return numberString;

    // Format to match your database format: "1.00000000000000000"
    // This ensures proper string comparison ordering
    return number.toStringAsFixed(17);
  }

  String _formatValueForComparison(String val) {
    final numValue = double.tryParse(val);
    if (numValue != null) {
      return _formatNumberForStringComparison(val);
    }
    return val;
  }

  Future<String> filters({required Map<String, dynamic> args}) async {
    try {
      final conditions = args.entries.where((e) => e.value != null).map((e) {
        final key = e.key;
        final value = e.value;

        if (value is String) {
          // Handle IN clause
          if (value.startsWith('IN {') && value.endsWith('}')) {
            return "$key $value";
          }

          // Handle .. syntax
          if (value.contains('..')) {
            final range = value.split('..');
            if (range.length == 2) {
              final start = range[0].trim();
              final end = range[1].trim();
              // return '($key >= "$start" AND $key <= "$end")';
              // return '$key BETWEEN {"$start", "$end"}';

              final startNum = double.tryParse(start);
              final endNum = double.tryParse(end);

              if (startNum != null && endNum != null) {
                // Format numbers to match database format for string comparison
                final formattedStart = _formatNumberForStringComparison(start);
                final formattedEnd = _formatNumberForStringComparison(end);
                return '($key >= "$formattedStart" AND $key <= "$formattedEnd")';
              } else {
                return '($key >= "$start" AND $key <= "$end")';
              }
            }
          }

          // Handle LIKE clause
          if (value.startsWith('LIKE ')) {
            final searchTerm = value.replaceFirst('LIKE ', '').trim();

            // Handle LIKE with wildcards
            if (searchTerm.contains('%')) {
              final term = searchTerm.replaceAll('%', '').trim();

              // LIKE '%text%' -> CONTAINS[c]
              if (searchTerm.startsWith('%') && searchTerm.endsWith('%')) {
                return '$key CONTAINS[c] "$term"';
              }

              // LIKE 'text%' -> BEGINSWITH[c]
              if (!searchTerm.startsWith('%') && searchTerm.endsWith('%')) {
                return '$key BEGINSWITH[c] "$term"';
              }

              // LIKE '%text' -> ENDSWITH[c]
              if (searchTerm.startsWith('%') && !searchTerm.endsWith('%')) {
                return '$key ENDSWITH[c] "$term"';
              }
            }

            return '$key ==[c] "$searchTerm"';
          }

          if (value.startsWith('!=')) {
            final compareValue = value.replaceFirst('!=', '').trim();
            final formattedValue = _formatValueForComparison(compareValue);
            return '$key != "$formattedValue"';
          }

          if (value.startsWith('<>')) {
            final compareValue = value.replaceFirst('<>', '').trim();
            final formattedValue = _formatValueForComparison(compareValue);
            return '$key != "$formattedValue"';
          }

          if (value.startsWith('>=')) {
            final compareValue = value.replaceFirst('>=', '').trim();
            final formattedValue = _formatValueForComparison(compareValue);
            return '$key >= "$formattedValue"';
          }

          if (value.startsWith('<=')) {
            final compareValue = value.replaceFirst('<=', '').trim();
            final formattedValue = _formatValueForComparison(compareValue);
            return '$key <= "$formattedValue"';
          }

          if (value.startsWith('>')) {
            final compareValue = value.replaceFirst('>', '').trim();
            final formattedValue = _formatValueForComparison(compareValue);
            return '$key > "$formattedValue"';
          }

          if (value.startsWith('<')) {
            final compareValue = value.replaceFirst('<', '').trim();
            final formattedValue = _formatValueForComparison(compareValue);
            return '$key < "$formattedValue"';
          }

          // Handle BETWEEN or between syntax
          final pattern = RegExp(r'(BETWEEN|between)\s+', caseSensitive: false);
          if (pattern.hasMatch(value)) {
            final end = value.replaceFirst(pattern, '').trim();
            final start = value.split(pattern)[0].trim();

            return '($key >= "$start" AND $key <= "$end")';
            // return '$key BETWEEN {"$start", "$end"}';
          }
        }

        return '$key == "$value"';
      }).toList();

      return conditions.isEmpty ? "TRUEPREDICATE" : conditions.join(" AND ");
    } catch (e) {
      debugPrint('Filter error: $e');
      return "TRUEPREDICATE";
    }
  }

  @override
  Future<List<M>> getWithPagination<M extends RealmObject>({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? args,
    List? sortBy,
    bool ascending = true,
  }) async {
    try {
      // Validate pagination parameters
      if (page < 1 || limit < 1) {
        debugPrint('Invalid pagination parameters: page=$page, limit=$limit');
        return [];
      }

      var queryString = args != null ? await filters(args: args) : "TRUEPREDICATE";
      final sortClause = _buildSortClause(sortBy, ascending);

      if (sortClause.isNotEmpty) {
        queryString = "$queryString $sortClause";
      }

      final results = _realm.query<M>(queryString);

      final offset = (page - 1) * limit;
      if (offset >= results.length) {
        return [];
      }

      return results.freeze().skip(offset).take(min(limit, results.length - offset)).toList();
    } catch (e) {
      debugPrint('Pagination error: $e');
      return [];
    }
  }

  @override
  Future<T> writeTransaction<T>(T Function(Realm realm) action) async {
    try {
      late T result;
      _realm.write(() {
        result = action(_realm);
      });
      return result;
    } catch (e) {
      debugPrint('Transaction error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deleteAll<M extends RealmObject>() async {
    try {
      return _realm.write(() {
        _realm.deleteMany(_realm.all<M>());

        return true;
      });
    } catch (e) {
      debugPrint('Clear error: $e');
      rethrow;
    }
  }

  @override
  Future<M> addOrUpdate<M extends RealmObject>(M item) async {
    try {
      late M result;
      _realm.write(() {
        result = _realm.add<M>(item, update: true);
      });

      return result;
    } catch (e) {
      debugPrint('AddOrUpdate error: $e');
      rethrow;
    }
  }

  @override
  Future<int> getCount<M extends RealmObject>({Map<String, dynamic>? args}) async {
    try {
      if (args != null) {
        final queryString = await filters(args: args);
        return _realm.query<M>(queryString).length;
      }
      return _realm.all<M>().length;
    } catch (e) {
      debugPrint('Count error: $e');
      return 0;
    }
  }
}
