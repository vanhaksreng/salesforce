import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/build_logo_header_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/crash_report.dart';
import 'package:salesforce/features/auth/presentation/pages/login/login_screen.dart';
import 'package:salesforce/features/auth/presentation/pages/server_option/server_option_cubit.dart';
import 'package:salesforce/features/auth/presentation/pages/server_option/server_option_state.dart';
import 'package:salesforce/features/auth/presentation/pages/starter_screen/scanner_screen.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class StarterScreen extends StatefulWidget {
  const StarterScreen({super.key});
  static const String routeName = "dashboardScreen";

  @override
  State<StarterScreen> createState() => _StarterScreenState();
}

class _StarterScreenState extends State<StarterScreen> with MessageMixin {
  final _cubit = ServerOptionCubit();

  @override
  void initState() {
    _cubit.getServerLists();
    super.initState();
  }

  void _navigateToNextScreen(String url) async {
    final l = LoadingOverlay.of(context);
    l.show();

    final index = _cubit.state.servers.indexWhere((e) {
      return url.startsWith(e.backendUrl);
    });

    if (index == -1) {
      l.hide();
      throw GeneralException("Server not found for URL: $url");
    }

    String routeName = LoginScreen.routeName;

    final server = _cubit.state.servers[index];

    //Register Injection
    updateAppServerInjection(server);

    final splitted = url.split('/');
    final orgId = splitted[4]; //ORG ID
    await _cubit.updateAppServer(orgId);
    await Future.delayed(Duration(seconds: 1));
    l.hide();

    if (!mounted) return;
    setCompanyInjection(_cubit.state.companyInfo);
    if (_cubit.state.companyInfo == null) {
      return;
    }
    Navigator.pushNamed(context, routeName, arguments: server);
  }

  void _pushToQrScanner() async {
    try {
      if (!await _cubit.isConnectedToNetwork()) {
        throw GeneralException(
          "No internet connection. Please check your network settings.",
        );
      }

      if (_cubit.state.servers.isEmpty) {
        await _cubit.getServerLists();
      }
      Future.delayed(Duration(milliseconds: 200));

      if (_cubit.state.servers.isEmpty) {
        throw GeneralException(
          "No servers available. Please add a server first.",
        );
      }

      if (kDebugMode && Platform.isIOS) {
        _navigateToNextScreen("https://sme-new.clearview-erp.com/qr/ODA1"); //Seng Nary Book
        // _navigateToNextScreen("https://sme-new.clearview-erp.com/qr/Nzk4"); //Hearo UAT
        // _navigateToNextScreen("https://smb.clearview-erp.com/qr/MjM2");
        // _navigateToNextScreen("https://192.168.40.20/qr/Mg==");
        return; //TODO
      }

      if (!mounted) return;

      Navigator.pushNamed(context, ScannerScreen.routeName).then((url) {
        try {
          if (url != null && url is String) {
            _navigateToNextScreen(url);
          }
        } catch (e) {
          CrashReport.sendCrashReport(e.toString());
        }
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception catch (e) {
      showErrorMessage(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<ServerOptionCubit, ServerOptionState>(
        bloc: _cubit,
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(ServerOptionState state) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF59A5F5), Color(0xFFF5F5F5), Color(0xFFF5F5F5)],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.scale),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 15.scale,
              children: [
                const TextWidget(
                  wordSpacing: 1,
                  fontSize: 24,
                  color: mainColor,
                  fontWeight: FontWeight.w500,
                  text: "Welcome to ",
                ),
                ShaderMask(
                  shaderCallback: (bounds) => linearGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    greeting("ClearView Trade B2B"),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: scaleFontSize(26),
                      fontFamily: "Neuropol",
                      color: white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const BuildLogoHeaderWidget(),
          Helpers.gapH(scaleFontSize(20)),
          Column(
            spacing: scaleFontSize(40),
            children: [
              const TextWidget(
                fontSize: 16,
                textAlign: TextAlign.center,
                text:
                    "Get started by scanning your organization's QR code for secure, instant access to your business account.",
              ),
              BtnWidget(
                isLoading: state.isLoading,
                gradient: linearGradient,
                onPressed: () => _pushToQrScanner(),
                icon: Row(
                  children: [
                    const Icon(Icons.arrow_forward, color: white),
                    SizedBox(width: 8.scale),
                    TextWidget(
                      text: greeting("Get Started"),
                      fontSize: 16,
                      color: white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
