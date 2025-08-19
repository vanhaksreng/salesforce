import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/build_logo_header_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/auth/presentation/pages/login/login_screen.dart';
import 'package:salesforce/features/auth/presentation/pages/server_option/server_option_cubit.dart';
import 'package:salesforce/features/auth/presentation/pages/starter_screen/scanner_screen.dart';
import 'package:salesforce/injection_container.dart';
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

  _navigateToNextScreen(String url) async {
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

      if (_cubit.state.servers.isEmpty) {
        throw GeneralException(
          "No servers available. Please add a server first.",
        );
      }

      // if (kDebugMode && Platform.isIOS) {
      // _navigateToNextScreen("https://smb.clearview-erp.com/qr/MjM2");
      // _navigateToNextScreen("https://192.168.40.20/qr/Mg==");
      // return;
      // }

      if (!mounted) return;

      Navigator.pushNamed(context, ScannerScreen.routeName).then((url) {
        if (url != null && url is String) {
          if (!context.mounted) return;
          _navigateToNextScreen(url);
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
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
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
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  text: "Welcome to ",
                ),
                ShaderMask(
                  shaderCallback: (bounds) => linearGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  blendMode: BlendMode.srcIn,
                  child: const TextWidget(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    text: "ClearView Trade B2B",
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
                gradient: linearGradient,
                onPressed: () => _pushToQrScanner(),
                icon: Row(
                  children: [
                    const Icon(Icons.arrow_forward, color: white),
                    SizedBox(width: 8.scale),
                    const TextWidget(
                      text: "Get Started",
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
