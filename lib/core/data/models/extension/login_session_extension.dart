import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';

extension LoginSessionExtension on LoginSession {
  static LoginSession fromMap(Map<String, dynamic> json) {
    return LoginSession(
      Helpers.toStrings(json["id"]),
      accessToken: json["token"],
      email: json["email"],
      timeZone: json["time_zone"],
      lastLoginDateTime: json["last_login_date_time"],
      isLogin: json["is_login"],
      username: json["username"],
    );
  }
}
