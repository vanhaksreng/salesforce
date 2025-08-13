import 'package:flutter/material.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';

class AboutScreen extends StatefulWidget {
  static const String routeName = "aboutScreen";

  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    super.initState();

    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting("about")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: scaleFontSize(100)),
            Padding(
              padding: EdgeInsets.all(scaleFontSize(appSpace)),
              child: Text(
                _packageInfo.version,
                style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: scaleFontSize(16)),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(scaleFontSize(appSpace)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("© 2021", style: TextStyle(fontSize: scaleFontSize(16))),
                  Text(
                    " Blue Technology Co.,ltd.",
                    style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: scaleFontSize(16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
