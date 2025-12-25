import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/infrastructure/network/network_info.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/injection_container.dart';

class ApiClient {
  final http.Client client;
  final NetworkInfo networkInfo;

  ApiClient({required this.client, required this.networkInfo});

  Future<Uri> _getBaseUrl({required String endpoint, String? customUrl}) async {
    if (customUrl != null) {
      return Uri.parse('$customUrl/api/tradeb2b/$endpoint');
    }

    final connection = await getConnection();

    if (connection == null) {
      throw GeneralException("Connection request failed");
    }

    return Uri.parse('${connection.url}/api/tradeb2b/$endpoint');
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    String? customUrl,
  }) async {
    await _checkNetworkConnection();

    final defaultHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      final r = await client.post(
        await _getBaseUrl(customUrl: customUrl, endpoint: endpoint),
        headers: {...defaultHeaders, ...?headers},
        body: body,
      );

      if (r.statusCode == 500) {
        throw GeneralException('Cannot connect to server: ${r.statusCode}');
      }

      if (r.statusCode != 200) {
        throw GeneralException('Requested failed with : ${r.statusCode}');
      }

      final responseData = json.decode(r.body);

      if (responseData['status'] != 'success') {
        throw GeneralException(responseData['message'] ?? 'Unknown error');
      }

      return responseData;
    } on NetworkException catch (_) {
      throw GeneralException("No internet connection");
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _checkNetworkConnection() async {
    if (!await networkInfo.isConnected) {
      throw NetworkException();
    }
  }

  Future<Map<String, dynamic>> postCheckSession(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    String? customUrl,
  }) async {
    await _checkNetworkConnection();

    final defaultHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      final r = await client.post(
        await _getBaseUrl(customUrl: customUrl, endpoint: endpoint),
        headers: {...defaultHeaders, ...?headers},
        body: body,
      );

      if (r.statusCode != 200) {
        throw GeneralException('Request failed with status: ${r.statusCode}');
      }

      final responseData = json.decode(r.body);
      if (responseData['status'] != 'success') {
        throw GeneralException(responseData['message'] ?? 'Unknown error');
      }

      return responseData;
    } on GeneralException {
      rethrow;
    } on Exception {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> postUploadFiles(
    String endpoint, {
    List<XFile>? files,
    Object? body,
    String? customUrl,
  }) async {
    try {
      final Map<String, dynamic> params = json.decode(body.toString());
      http.MultipartRequest request = http.MultipartRequest(
        "POST",
        await _getBaseUrl(customUrl: customUrl, endpoint: endpoint),
      );
      params.forEach((k, v) {
        request.fields[k] = v.toString();
      });

      if (files != null && files.isNotEmpty) {
        for (int i = 0; i < files.length; i++) {
          request.files.add(
            await http.MultipartFile.fromPath('files[]', files[i].path),
          );
        }
      }

      var r = await request.send();
      if (r.statusCode != 200) {
        throw GeneralException('Request failed with status: ${r.statusCode}');
      }

      final responseData = json.decode(await r.stream.bytesToString());

      if (responseData['status'] != 'success') {
        throw GeneralException(responseData['message'] ?? 'Unknown error');
      }

      return responseData;
    } on GeneralException {
      rethrow;
    } on Exception {
      rethrow;
    }
  }
}
