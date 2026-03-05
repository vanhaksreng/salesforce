import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/features/auth/domain/entities/login_arg.dart';
import 'package:salesforce/features/auth/domain/repositories/auth_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class SessionLoginWidget extends StatefulWidget {
  const SessionLoginWidget({super.key});

  @override
  State<SessionLoginWidget> createState() => _SessionLoginDialogState();
}

class _SessionLoginDialogState extends State<SessionLoginWidget> {
  static const _primary = Color(0xFF4A1A8D);
  static const _accent = Color(0xFF2979FF);
  static const _errorRed = Color(0xFFE53935);

  final _passwordController = TextEditingController();
  final _focusNode = FocusNode();
  final _repos = getIt<AuthRepository>();
  final server = getIt<AppServer>();

  bool _obscure = true;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<LoginArg> _getLoginParam() async {
    final DeviceInfoPlugin device = DeviceInfoPlugin();
    String deviceId = "";
    String platform = "";
    String devVersion = "";

    final user = getAuth();

    if (Platform.isAndroid) {
      final AndroidDeviceInfo android = await device.androidInfo;
      deviceId = android.id;
      platform = "android";
      devVersion = android.version.release;
    } else {
      final IosDeviceInfo ios = await device.iosInfo;
      deviceId = ios.identifierForVendor ?? "";
      platform = "ios";
      devVersion = ios.systemVersion;
    }

    return LoginArg(
      userAgent: deviceId,
      email: user?.email ?? "",
      password: _passwordController.text.trim(),
      server: server,
      platform: platform,
      devVersion: devVersion,
      notificationKey: OneSignal.User.pushSubscription.id ?? "",
      isReAuth: true,
    );
  }

  void _submit() async {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Password is required';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      await _repos.login(arg: await _getLoginParam());
      if (!mounted) return;
      Navigator.of(context).pop(password);
    } on GeneralException catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.message;
        _passwordController.clear();
      });

      _focusNode.requestFocus();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Incorrect password. Please try again.';
        _passwordController.clear();
      });

      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.18),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSessionBanner(),
          const SizedBox(height: 20),

          _buildPasswordField(),

          if (_hasError) ...[const SizedBox(height: 8), _buildErrorMessage()],

          const SizedBox(height: 28),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            color: _primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Re-authenticate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Token expired',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF8E8E9A),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFCC02).withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: const [
          Icon(Icons.access_time_rounded, size: 16, color: Color(0xFFF57F17)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your session has expired. Enter your password to continue.',
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF5D4037),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A4A5A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          focusNode: _focusNode,
          obscureText: _obscure,
          autofocus: true,
          onSubmitted: (_) => _submit(),
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 1.5,
            color: Color(0xFF1A1A2E),
          ),
          decoration: InputDecoration(
            hintText: '',
            hintStyle: TextStyle(letterSpacing: 2, color: Colors.grey.shade400),
            prefixIcon: const Icon(
              Icons.lock_rounded,
              size: 14,
              color: Color(0xFFAAAAAA),
            ),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              child: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: _obscure ? const Color(0xFFAAAAAA) : _accent,
              ),
            ),
            filled: true,
            fillColor: _hasError
                ? _errorRed.withValues(alpha: 0.04)
                : const Color(0xFFF7F7FA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _accent.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _errorRed, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Row(
      children: [
        const Icon(Icons.info_outline_rounded, size: 14, color: _errorRed),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            _errorMessage,
            style: const TextStyle(fontSize: 12.5, color: _errorRed),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: TextButton(
            onPressed: _isLoading
                ? null
                : () => Navigator.of(context).pop(null),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E8E9A),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Login button
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              disabledBackgroundColor: _primary.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
