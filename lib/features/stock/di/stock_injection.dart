import 'package:salesforce/infrastructure/network/network_info.dart';
import 'package:salesforce/infrastructure/storage/i_local_storage.dart';
import 'package:salesforce/features/stock/data/datasources/api/api_stock_data_source.dart';
import 'package:salesforce/features/stock/data/datasources/api/api_stock_data_source_impl.dart';
import 'package:salesforce/features/stock/data/datasources/realm/realm_stock_data_source.dart';
import 'package:salesforce/features/stock/data/datasources/realm/realm_stock_data_source_impl.dart';
import 'package:salesforce/features/stock/data/repositories/stock_repository_impl.dart';
import 'package:salesforce/features/stock/domain/repositories/stock_repository.dart';
import 'package:salesforce/injection_container.dart';

Future<void> initStockInjection() async {
  final networkInfo = getIt<NetworkInfo>();
  // Datasources
  getIt.registerLazySingleton<ApiStockDataSource>(() => ApiStockDataSourceImpl(network: networkInfo));

  getIt.registerLazySingleton<RealmStockDataSource>(() => RealmStockDataSourceImpl(ils: getIt<ILocalStorage>()));
  // Repository
  getIt.registerLazySingleton<StockRepository>(
    () => StockRepositoryImpl(
      remote: getIt<ApiStockDataSource>(),
      local: getIt<RealmStockDataSource>(),
      networkInfo: networkInfo,
    ),
  );
}
