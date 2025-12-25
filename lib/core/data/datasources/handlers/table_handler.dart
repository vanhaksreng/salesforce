import 'package:realm/realm.dart';

abstract class TableHandler<T extends RealmObject> {
  T fromMap(Map<String, dynamic> map);
  String extractKey(T record);
  Type get type;
  String get tableName;

  void cleanAll(Realm realm) {
    final objects = realm.all<T>().toList();
    realm.deleteMany(objects);
  }

  int countAll(Realm realm) {
    return realm.all<T>().length;
  }

  // Future<bool> deleteObject<M extends RealmObject>(M object) async {
  //   try {
  //     final pk = object.realm?.schema.primaryKey;
  //     if (pk == null) return false;

  //     final pkValue = object.toJson()[pk];
  //     if (pkValue == null) return false;

  //     final liveObject = _realm.find<M>(pkValue);
  //     if (liveObject != null && liveObject.isValid) {
  //       _realm.write(() => _realm.delete(liveObject));
  //     }
  //     return true;
  //   } catch (e) {
  //     print('Delete error: $e');
  //     return false;
  //   }
  // }
}
