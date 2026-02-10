import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/presentation/pages/about/about/about_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/about/about/about_state.dart';
import 'package:salesforce/features/tasks/domain/entities/app_version.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class AboutScreen extends StatefulWidget {
  static const String routeName = "aboutScreen";
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final _cubit = AboutCubit();

  PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();
    initVersion();
  }

  Future<void> initVersion() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  Future<bool> isUpdateAvailable(AppVersion? apiInfo) async {
    return Helpers.isUpdateAvailable(
      apiInfo?.appVersion ?? "0",
      packageInfo?.version ?? "0",
    );
  }

  Future<void> goUpdateApp(String url) async {
    try {
      launchUrl(Uri.parse(url));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBarWidget(title: greeting("about")),
      body: BlocBuilder<AboutCubit, AboutState>(
        bloc: _cubit,
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
      persistentFooterButtons: [
        Column(
          spacing: 8.scale,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWidget(text: "© 2021"),
                TextWidget(
                  text: " Blue Technology Co.,ltd.",
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ],
            ),
            TextWidget(
              text: "all rights reserved".toUpperCase(),
              color: textColor50,
              fontWeight: FontWeight.normal,
              fontSize: 10,
            ),
          ],
        ),
      ],
    );
  }

  Padding _buildBody(AboutState state) {
    return Padding(
      padding: EdgeInsets.all(scaleFontSize(16)),
      child: Column(
        spacing: scaleFontSize(30),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BoxWidget(
            padding: EdgeInsets.all(scaleFontSize(16)),
            child: Image.asset(
              'assets/images/logo.png',
              width: scaleFontSize(120),
              height: scaleFontSize(120),
            ),
          ),

          Column(
            spacing: scaleFontSize(8),
            children: [
              TextWidget(
                text: "Trade B2B",
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              TextWidget(
                text: "Version ${packageInfo?.version}",
                fontSize: scaleFontSize(15),
                fontWeight: FontWeight.w600,
                color: textColor50,
              ),
            ],
          ),

          const SizedBox(height: 24),

          Column(
            spacing: scaleFontSize(12),
            children: [
              changeButton(state),
              TextWidget(
                text: getDescription(state),
                fontSize: scaleFontSize(13),
                fontWeight: FontWeight.normal,
                color: textColor50,
                fontStyle: FontStyle.italic,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget changeButton(AboutState state) {
    bool isUpdate = Helpers.isUpdateAvailable(
      state.appVersion?.appVersion ?? "0",
      packageInfo?.version ?? "0",
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(16)),
      child: BtnWidget(
        borderColor: primary,
        isLoading: state.isLoading,
        onPressed: () async => isUpdate
            ? goUpdateApp(state.appVersion?.appUrl ?? "")
            : await _cubit.checkAppVersion(),
        icon: Icon(isUpdate ? Icons.system_update : Icons.replay_outlined),
        title: isUpdate ? greeting("Update Now") : greeting("Check for Update"),
        textColor: white,
        fntSize: 14,
        bgColor: !isUpdate ? mainColor50 : mainColor,
      ),
    );
  }

  String getDescription(AboutState state) {
    if (Helpers.isUpdateAvailable(
      state.appVersion?.appVersion ?? "0",
      packageInfo?.version ?? "0",
    )) {
      return state.appVersion?.description ?? "";
    }
    return greeting("Last version already installed.");
  }
}
