import 'package:realm/realm.dart';

abstract interface class ILocalStorage {
  Future<M?> getFirst<M extends RealmObject>({
    Map<String, dynamic>? args,
    List? sortBy,
    bool ascending = true,
  });

  Future<List<M>> getAll<M extends RealmObject>({
    Map<String, dynamic>? args,
    List? sortBy,
    bool ascending = true,
  });

  Future<List<M>> getWithPagination<M extends RealmObject>({
    int page,
    int limit = 20,
    Map<String, dynamic>? args,
    List? sortBy,
    bool ascending = true,
  });

  Future<M> add<M extends RealmObject>(M item);
  Future<M> update<M extends RealmObject>(M item);
  Future<M> addOrUpdate<M extends RealmObject>(M item);

  Future<void> delete<M extends RealmObject>(M item);
  Future<void> deleteAll<M extends RealmObject>();

  Future<void> addAll<M extends RealmObject>(List<M> items);

  M? find<M extends RealmObject>(String primaryKey);

  Future<T> writeTransaction<T>(T Function(Realm realm) action);

  Future<int> getCount<M extends RealmObject>({
    Map<String, dynamic>? args,
  });

  void dispose();
}
