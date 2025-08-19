import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/auth/presentation/pages/loggedin_history/loggedin_history_cubit.dart';
import 'package:salesforce/features/auth/presentation/pages/loggedin_history/loggedin_history_state.dart';
import 'package:salesforce/features/auth/presentation/pages/login/login_screen.dart';
import 'package:salesforce/features/main_tap_screen.dart';
import 'package:salesforce/injection_container.dart';

class LoggedinHistoryScreen extends StatefulWidget {
  const LoggedinHistoryScreen({super.key});

  static const String routeName = "authLoggedInHistory";

  @override
  State<LoggedinHistoryScreen> createState() => _LoggedinHistoryScreenState();
}

class _LoggedinHistoryScreenState extends State<LoggedinHistoryScreen> {
  final _cubit = LoggedinHistoryCubit();

  @override
  void initState() {
    super.initState();
    _cubit.getCompanyInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loginHandler() async {
    final result = await _cubit.offlineLogin();

    if (!result) {
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => MainTapScreen()));
  }

  void _loginOtherAccount() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFFF8FAFC)],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header section with profile
              Expanded(flex: 2, child: _buildProfileSection()),

              Expanded(flex: 3, child: _buildActionSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Hero(
          tag: 'user_avatar',
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B6B).withValues(alpha: 0.8),
                  const Color(0xFFEE5A24).withValues(alpha: 0.9),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEE5A24).withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: BlocBuilder<LoggedinHistoryCubit, LoggedinHistoryState>(
              bloc: _cubit,
              builder: (context, state) {
                if (state.company == null) {
                  return Container(
                    margin: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)]),
                    ),
                    child: const Icon(Icons.person_outline, size: 60, color: Colors.white),
                  );
                }

                return Container(
                  margin: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)]),
                  ),
                  child: ImageNetWorkWidget(
                    round: 100,
                    imageUrl: state.company?.logo128 ?? '',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ),

        SizedBox(height: 32.scale),

        // User info
        TextWidget(
          text: getAuth()?.userName ?? "User Name",
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),

        SizedBox(height: 8.scale),

        TextWidget(
          text: getAuth()?.email ?? "user@example.com",
          fontSize: 16,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ],
    );
  }

  Widget _buildActionSection() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Expanded(child: _buildWarningCard()),
          SizedBox(height: 30.scale),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60.scale,
            // height: 60.scale,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFFFEF3C7), Color(0xFFFBBF24)]),
            ),
            child: const Icon(Icons.warning_rounded, size: 32, color: Color(0xFFD97706)),
          ),

          SizedBox(height: 20.scale),

          // Warning title
          const TextWidget(
            text: "Switch Account Warning",
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),

          SizedBox(height: 16.scale),

          // Warning description
          const TextWidget(
            text: "Switching accounts will remove all locally stored data. This action cannot be undone.",
            fontSize: 16,
            color: Color(0xFF64748B),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary button
        GestureDetector(
          onTap: _loginHandler,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Continue to Login',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Secondary button
        GestureDetector(
          onTap: _loginOtherAccount,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            ),
            child: const Center(
              child: Text(
                'Login with other account',
                style: TextStyle(color: Color(0xFF667EEA), fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
