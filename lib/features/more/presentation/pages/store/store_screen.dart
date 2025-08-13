// import 'package:flutter/material.dart';
// import 'package:salesforce/core/constants/app_styles.dart';
// import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
// import 'package:salesforce/core/presentation/widgets/search_widget.dart';
// import 'package:salesforce/core/utils/size_config.dart';
// import 'package:salesforce/localization/trans.dart';

// class StoreScreen extends StatefulWidget {
//   const StoreScreen({super.key});
//   static const routeName = "storeScreen";

//   @override
//   State<StoreScreen> createState() => _StoreScreenState();
// }

// class _StoreScreenState extends State<StoreScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBarWidget(
//         title: greeting("store"),
//         bottom: Padding(
//           padding: EdgeInsets.symmetric(
//               horizontal: scaleFontSize(appSpace), vertical: 8.scale),
//           child: Row(
//             children: [
//               Expanded(
//                 child: SearchWidget(
//                   onSubmitted: (value) async {},
//                 ),
//               ),
//             ],
//           ),
//         ),
//         heightBottom: 40,
//       ),
//     );
//   }
// }
