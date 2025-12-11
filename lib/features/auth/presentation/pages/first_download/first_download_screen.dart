import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/auth/presentation/pages/first_download/first_download_cubit.dart';
import 'package:salesforce/features/auth/presentation/pages/first_download/first_download_state.dart';
import 'package:salesforce/features/auth/presentation/pages/login/login_screen.dart';
import 'package:salesforce/features/main_tap_screen.dart';
import 'package:salesforce/core/presentation/widgets/build_logo_header_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/theme/app_colors.dart';

class FirstDownloadScreen extends StatefulWidget {
  const FirstDownloadScreen({super.key});

  static const String routeName = "download";

  @override
  State<FirstDownloadScreen> createState() => _FirstDownloadScreenState();
}

class _FirstDownloadScreenState extends State<FirstDownloadScreen> {
  final _cubit = FirstDownloadCubit();

  @override
  void initState() {
    super.initState();
    _handleDownload();
  }

  Future<void> _handleDownload() async {
    try {
      
      await Future.delayed(Duration(seconds: 1));

      await _cubit.getAppSyncLog();

      if (_cubit.state.tableLogs.isEmpty) {
        await setAuthInjection(null);
        _navigateToLogin();
        return;
      }

      await _cubit.cleanAllData();
      await _cubit.downloadMasterData();
      await _cubit.downLoadAppSetting();

      await _cubit.getSchedules();

      await setApplicationSetupInjectionIfNeed();

      if (!mounted) return;

      if (_cubit.state.errors.isEmpty) {
        _navigateToHome();
      }
    } catch (e) {
      Logger.log(e);
      setAuthInjection(null);
      Navigator.pop(context);
    }
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainTapScreen()),
      (route) => false,
    );
  }

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF59A5F5), Color(0xFFF5F5F5), Color(0xFFF5F5F5)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: BlocBuilder<FirstDownloadCubit, FirstDownloadState>(
          bloc: _cubit,
          builder: (context, state) {
            return ListView(
              padding: EdgeInsets.symmetric(horizontal: scaleFontSize(15)),
              children: [
                const BuildLogoHeaderWidget(),
                SizedBox(height: scaleFontSize(32)),
                const TextWidget(
                  text: "Please wait, Downloading ...",
                  fontSize: 18,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: scaleFontSize(32)),
                TextWidget(
                  text: state.textLoading ?? '',
                  maxLines: 1,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: scaleFontSize(15)),
                LinearProgressIndicator(
                  value: state.progressValue / 100,
                  valueColor: const AlwaysStoppedAnimation<Color>(primary),
                  backgroundColor: white,
                  minHeight: scaleFontSize(15),
                  borderRadius: BorderRadius.circular(scaleFontSize(8)),
                ),
                Helpers.gapH(6),
                if (state.errors.isNotEmpty) ...[
                  BoxWidget(
                    color: Colors.amber,
                    rounding: 3,
                    padding: EdgeInsets.all(8.scale),
                    isBoxShadow: false,
                    child: Column(
                      spacing: 8.scale,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListView.builder(
                          itemCount: state.errors.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return TextWidget(text: state.errors[index]);
                          },
                        ),
                      ],
                    ),
                  ),
                  if (state.progressValue >= 100)
                    TextButton(
                      onPressed: _navigateToHome,
                      child: const TextWidget(text: "Continue", color: primary),
                    ),
                  SizedBox(height: 15.scale),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
