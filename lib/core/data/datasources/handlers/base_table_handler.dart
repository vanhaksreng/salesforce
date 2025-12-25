import 'package:realm/realm.dart';
import 'package:salesforce/core/data/datasources/handlers/table_handler.dart';

abstract class BaseTableHandler<T extends RealmObject> implements TableHandler<T> {
  @override
  Type get type => T;

  @override
  String extractKey(T record);

  @override
  T fromMap(Map<String, dynamic> map);

  @override
  void cleanAll(Realm realm) {
    final objects = realm.all<T>().toList();
    realm.deleteMany(objects);
  }

  @override
  int countAll(Realm realm) {
    return realm.all<T>().length;
  }
}
