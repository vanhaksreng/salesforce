import 'package:salesforce/realm/scheme/schemas.dart';

class LoginArg {
  final String email;
  final String password;
  final AppServer server;
  final String notificationKey;
  final String source;
  final String userAgent;
  final String platform;
  final String devVersion;

  const LoginArg({
    required this.email,
    required this.password,
    required this.server,
    required this.notificationKey,
    this.source = "onesignal",
    this.userAgent = "",
    this.platform = "",
    this.devVersion = "",
  });

  Map<String, dynamic> toJson() {
    return {
      'username': email,
      'password': password,
      'notification_token': notificationKey,
      'source': source,
      "user_agent": userAgent,
      "devVersion": devVersion,
    };
  }
}
