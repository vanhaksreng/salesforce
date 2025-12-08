import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:realm/realm.dart';
import 'package:salesforce/core/constants/app_setting.dart';
import 'package:salesforce/core/data/datasources/api/base_api_data_source_impl.dart';
import 'package:salesforce/core/data/datasources/api/base_api_data_source.dart';
import 'package:salesforce/core/data/datasources/realm/base_realm_data_source.dart';
import 'package:salesforce/core/data/datasources/realm/base_realm_data_source_impl.dart';
import 'package:salesforce/core/data/repositories/base_app_repository_impl.dart';
import 'package:salesforce/core/domain/entities/init_app_stage.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/infrastructure/network/network_info.dart';
import 'package:salesforce/infrastructure/network/network_info_impl.dart';
import 'package:salesforce/infrastructure/storage/i_local_storage.dart';
import 'package:salesforce/infrastructure/storage/realm_storage.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/features/auth/domain/entities/user.dart';
import 'package:salesforce/features/more/di/more_injection.dart';
import 'package:salesforce/features/report/di/report_injection.dart';
import 'package:salesforce/features/stock/di/stock_injection.dart';
import 'package:salesforce/features/tasks/di/task_injection.dart';
import 'package:salesforce/realm/configs/realm_config.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'features/auth/di/auth_injection.dart';
import 'package:http/http.dart' as http;

final getIt = GetIt.instance;

Future<void> getItInit() async {
  // Core dependencies here
  await _initializeStorage();
  await _initializeApp();
  await _initializeNetworking();
  await _initializeDataSources();

  // Feature dependencies
  await _initializeRepositories();
  await initAuthInjection();
  await initTasksInjection();
  await initStockInjection();
  await initMoreInjection();
  await initReportInjection();

  setInitAppStage(const InitAppStage(isSyncSetting: false));
}

Future<void> _initializeStorage() async {
  final config = await RealmConfig.getConfig();
  final realm = Realm(config);

  getIt.registerSingleton<ILocalStorage>(RealmStorage(realm));
}

Future<void> _initializeApp() async {
  final storage = getIt<ILocalStorage>();

  final appSetting = storage.find<AppSetting>(kConnectionKey);
  if (appSetting == null) {
    return;
  }

  final server = storage.find<AppServer>(appSetting.value);
  if (server == null) {
    Logger.log('Warning: Server not found : ${appSetting.value}');
    return;
  }

  updateAppServerInjection(server);

  LoginSession? auth = await storage.getFirst<LoginSession>();
  setAuthInjection(auth);

  final appSetup = await storage.getFirst<ApplicationSetup>();
  if (appSetup == null) {
    Logger.log('Warning: appSetup not found');
    return;
  }

  if(auth != null) {
    await setCompanyInjection(await storage.getFirst<CompanyInformation>());
  }

  getIt.registerSingleton<ApplicationSetup>(appSetup);
}

Future<void> _initializeNetworking() async {
  getIt.registerLazySingleton(() => Connectivity());
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: getIt<Connectivity>()),
  );
  getIt.registerLazySingleton(() => http.Client());
}

Future<void> _initializeDataSources() async {
  if (getIt.isRegistered<BaseApiDataSource>()) {
    getIt.unregister<BaseApiDataSource>();
  }

  if (getIt.isRegistered<BaseRealmDataSource>()) {
    getIt.unregister<BaseRealmDataSource>();
  }

  getIt.registerLazySingleton<BaseApiDataSource>(
    () => BaseApiDataSourceImpl(network: getIt<NetworkInfo>()),
  );

  getIt.registerLazySingleton<BaseRealmDataSource>(
    () => BaseRealmDataSourceImpl(ils: getIt<ILocalStorage>()),
  );
}

Future<void> _initializeRepositories() async {
  getIt.registerLazySingleton<BaseAppRepository>(
    () => BaseAppRepositoryImpl(
      remote: getIt<BaseApiDataSource>(),
      local: getIt<BaseRealmDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
}

Future<void> updateAppServerInjection(AppServer server) async {
  if (getIt.isRegistered<AppServer>()) {
    getIt.unregister<AppServer>();
  }

  getIt.registerSingleton<AppServer>(server);
}

Future<void> setAuthInjection(LoginSession? auth) async {
  if (auth == null) return;

  if (getIt.isRegistered<User>()) {
    getIt.unregister<User>();
  }

  final storage = getIt<ILocalStorage>();
  final userSetup = await storage.getFirst<UserSetup>();

  final user = User(
    id: auth.id,
    email: auth.email ?? "",
    phoneNo: auth.phoneNo ?? "",
    userName: auth.username ?? "",
    imgPath: auth.avatar128 ?? "", //TODO image link
    token: auth.accessToken ?? "",
    expired: auth.isLogin == "Yes" ? "No" : "Yes",
    salepersonCode: userSetup?.salespersonCode ?? "",
  );

  getIt.registerSingleton<User>(user);
}

Future<void> setCompanyInjection(CompanyInformation? company) async {
  if (company == null) return;

  if (getIt.isRegistered<CompanyInformation>()) {
    getIt.unregister<CompanyInformation>();
  }

  final com = CompanyInformation(
    company.id,
    name2: company.name2,
    name: company.name,
    phoneNo: company.phoneNo,
    address: company.address,
    address2: company.address2,
    logo128: company.logo128,
    email: company.email,
  );

  getIt.registerSingleton<CompanyInformation>(com);
}

// CompanyInformation? getCompany() {
//   if (getIt.isRegistered<CompanyInformation>()) {
//     return getIt<CompanyInformation>();
//   }

//   return null;
// }

Future<CompanyInformation?> getCompany() async {
  if (getIt.isRegistered<CompanyInformation>()) {
    return getIt<CompanyInformation>();
  }

  return null;
}

User? getAuth() {
  if (getIt.isRegistered<User>()) {
    return getIt<User>();
  }

  return null;
}

Future<AppServer?> getConnection() async {
  return getIt.isRegistered<AppServer>() ? getIt<AppServer>() : null;
}

Future<void> setApplicationSetupInjectionIfNeed() async {
  if (getIt.isRegistered<ApplicationSetup>()) {
    return;
  }

  final storage = getIt<ILocalStorage>();
  final appSetup = await storage.getFirst<ApplicationSetup>();
  if (appSetup == null) {
    Logger.log('Warning: appSetup not found');
    return;
  }

  getIt.registerSingleton<ApplicationSetup>(appSetup);
}

Future<void> setInitAppStage(InitAppStage setting) async {
  if (getIt.isRegistered<InitAppStage>()) {
    getIt.unregister<InitAppStage>();
  }

  getIt.registerSingleton<InitAppStage>(setting);
}

InitAppStage getInitAppStage() {
  if (!getIt.isRegistered<InitAppStage>()) {
    setInitAppStage(const InitAppStage(isSyncSetting: true));
  }

  return getIt<InitAppStage>();
}
