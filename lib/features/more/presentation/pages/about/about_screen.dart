// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:salesforce/core/presentation/widgets/box_widget.dart';
// import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
// import 'package:salesforce/core/presentation/widgets/text_widget.dart';
// import 'package:salesforce/core/utils/helpers.dart';
// import 'package:url_launcher/url_launcher.dart';

// import 'package:salesforce/core/utils/size_config.dart';
// import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
// import 'package:salesforce/localization/trans.dart';
// import 'package:salesforce/theme/app_colors.dart';
// import 'package:salesforce/core/constants/app_styles.dart';

// class AboutScreen extends StatefulWidget {
//   static const String routeName = "aboutScreen";
//   const AboutScreen({super.key});

//   @override
//   State<AboutScreen> createState() => _AboutScreenState();
// }

// class _AboutScreenState extends State<AboutScreen> {
//   PackageInfo _packageInfo = PackageInfo(
//     appName: 'Unknown',
//     packageName: 'Unknown',
//     version: '0.0.0',
//     buildNumber: '0',
//     buildSignature: '',
//     installerStore: '',
//   );

//   bool _checking = false;
//   String? _updateMessage;

//   @override
//   void initState() {
//     super.initState();
//     _initPackageInfo();
//   }

//   void _checkAppVersion() {
//     //TODO : impliment next time
//     if (mounted) {
//       Helpers.showDialogAction(
//         context,
//         labelAction: "New version available",
//         subtitle: _cubit.state.appVersion?.description ?? "",
//         confirm: () async {
//           if (!mounted) return;
//           Navigator.pop(context, true);
//           final url = Uri.parse("${_cubit.state.appVersion!.appUrl}");
//           if (await canLaunchUrl(url)) {
//             await launchUrl(url, mode: LaunchMode.externalApplication);
//           } else {
//             Helpers.showMessage(msg: 'No application found to open this link.');
//           }
//         },
//       );
//     }
//   }

//   Future<void> _initPackageInfo() async {
//     final info = await PackageInfo.fromPlatform();
//     setState(() => _packageInfo = info);
//   }

//   Future<void> _checkForUpdate() async {
//     setState(() {
//       _checking = true;
//       _updateMessage = null;
//     });

//     try {
//       final url = Uri.parse(
//         "https://play.google.com/store/apps/details?id=${_packageInfo.packageName}",
//       );

//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final match = RegExp(
//           r'Current Version.+?>([\d.]+)<',
//         ).firstMatch(response.body);

//         if (match != null) {
//           final storeVersion = match.group(1)!;

//           if (_isNewer(storeVersion, _packageInfo.version)) {
//             _updateMessage = "New version available ($storeVersion)";
//             _openStore();
//           } else {
//             _updateMessage = "Your app is up to date";
//           }
//         } else {
//           _updateMessage = "Unable to check version";
//         }
//       }
//     } catch (_) {
//       _updateMessage = "Update check failed";
//     }

//     setState(() => _checking = false);
//   }

//   bool _isNewer(String store, String local) {
//     final s = store.split('.').map(int.parse).toList();
//     final l = local.split('.').map(int.parse).toList();

//     for (int i = 0; i < s.length; i++) {
//       if (s[i] > (l.length > i ? l[i] : 0)) return true;
//       if (s[i] < (l.length > i ? l[i] : 0)) return false;
//     }
//     return false;
//   }

//   Future<void> _openStore() async {
//     final url = Uri.parse(
//       "https://play.google.com/store/apps/details?id=${_packageInfo.packageName}",
//     );
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: white,
//       appBar: AppBarWidget(title: greeting("about")),
//       body: Padding(
//         padding: EdgeInsets.all(scaleFontSize(16)),
//         child: Column(
//           spacing: scaleFontSize(30),
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             BoxWidget(
//               padding: EdgeInsets.all(scaleFontSize(16)),
//               child: Image.asset(
//                 'assets/images/logo.png',
//                 width: scaleFontSize(120),
//                 height: scaleFontSize(120),
//               ),
//             ),

//             Column(
//               spacing: scaleFontSize(8),
//               children: [
//                 TextWidget(
//                   text: "Trade B2B",
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 TextWidget(
//                   text: "Version ${_packageInfo.version}",
//                   fontSize: scaleFontSize(15),
//                   fontWeight: FontWeight.w600,
//                   color: textColor50,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24),

//             Column(
//               spacing: scaleFontSize(12),
//               children: [
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: scaleFontSize(16)),
//                   child: BtnWidget(
//                     borderColor: primary,
//                     onPressed: () {},
//                     icon: Icon(Icons.replay_outlined),
//                     title: greeting("Check for Update"),
//                     textColor: white,
//                     fntSize: 14,
//                     bgColor: mainColor,
//                   ),
//                 ),
//                 TextWidget(
//                   text: "Last version already installed.",
//                   fontSize: scaleFontSize(13),
//                   fontWeight: FontWeight.normal,
//                   color: textColor50,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       persistentFooterButtons: [
//         Column(
//           spacing: 8.scale,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 TextWidget(text: "© 2021"),
//                 TextWidget(
//                   text: " Blue Technology Co.,ltd.",
//                   color: primary,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ],
//             ),
//             TextWidget(
//               text: "all rights reserved".toUpperCase(),
//               color: textColor50,
//               fontWeight: FontWeight.normal,
//               fontSize: 10,
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
