import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:salesforce/features/auth/domain/entities/user.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class CrashReport {
  static const String botToken =
      "8115256701:AAEpkZZw01dHFVaCx1sCLleRIHVO-n8SXMs";
  static const String chatId = "-1002388788409";

  static String? _globalContext;

  static void setCrashContext(String context) {
    _globalContext = context;
  }

  static String? get crashContext => _globalContext;

  static Future<void> sendCrashReport(
    String error, {
    String? stackTrace,
    String? context,
  }) async {
    try {
      final deviceInfo = await _getDeviceInfo();
      final appInfo = await _getAppInfo();

      final User? user = getAuth();
      final CompanyInformation? company = getCompany();
      final AppServer? connection = await getConnection();

      String userInfo = "";
      if (user != null) {
        userInfo = "Email: ${user.email} Username: ${user.userName}";
      }

      final String message = "🔥 *${appInfo.appName} App*\n\n"
          "Device: $deviceInfo\n"
          "User: $userInfo\n"
          "org-name :${company?.name}\n"
          "connection :${connection?.name}\n"
          "buildNumber: ${appInfo.buildNumber}\n"
          "version: ${appInfo.version}\n"
          "*Context:* ${context ?? _globalContext ?? "Unknown"}\n"
          "installerStore: ${appInfo.installerStore}\n"
          "========================\n"
          "*Error:* $error\n"
          "========================\n"
          "*Stack Trace:* \n ```$stackTrace```";
      await _sendToTelegram(message);
    } catch (e) {
      debugPrint('Failed to send crash report');
    }
  }

  static Future<void> testCrashReport() async {
    setCrashContext("Testing crash reporting system");

    try {
      throw Exception("This is a test crash");
    } catch (e, stackTrace) {
      await sendCrashReport(
        e.toString(),
        stackTrace: stackTrace.toString(),
        context: "Manual test from debug mode",
      );
    }
  }

  static Future<void> _sendToTelegram(String message) async {
    try {
      await http.post(
        Uri.parse("https://api.telegram.org/bot$botToken/sendMessage"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "chat_id": chatId,
          "text": message,
          "parse_mode": "Markdown",
        }),
      );
    } catch (e) {
      debugPrint("Failed to send crash report to Telegram: $e");
    }
  }

  static Future<String> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return '${iosInfo.model} iOS ${iosInfo.systemVersion}';
    } else {
      final androidInfo = await deviceInfo.androidInfo;
      return '${androidInfo.model} Android ${androidInfo.version.release}';
    }
  }

  static Future<PackageInfo> _getAppInfo() async {
    return await PackageInfo.fromPlatform();
  }
}
