// import 'dart:io';

// import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
// import 'package:salesforce/features/auth/domain/entities/user.dart';

// import 'heartbeat_service.dart';

// class HeartbeatServiceImpl implements IHeartbeatService {
//   final BaseAppRepository _appRepo;

//   HeartbeatServiceImpl(BaseAppRepository appRepo) : _appRepo = appRepo;

//   @override
//   Future<void> execute({required User auth}) async {
//     final Map<String, dynamic> param = {
//       "app_id": "com.clearviewerp.salesforce",
//       "token": auth.token,
//       "username": auth.email,
//       "source": Platform.isIOS ? "ios" : "android",
//       'status': 'online',
//       'rtype': 'heartbeat',
//     };

//     try {
//       await _appRepo.heartbeatStatus(params: param);
//     } catch (error) {
//       //
//     }
//   }
// }
