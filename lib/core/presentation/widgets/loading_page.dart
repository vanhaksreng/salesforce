// import 'package:flutter/material.dart';
// import 'package:salesforce/core/utils/size_config.dart';
// import 'package:salesforce/localization/trans.dart';
// import 'package:salesforce/presentation/widgets/box_widget.dart';
// import 'package:salesforce/theme/app_colors.dart';

// class LoadingPage extends StatelessWidget {
//   const LoadingPage({
//     super.key,
//     this.paddingBottom = 8,
//     required this.loading,
//     this.isScrolled = false,
//   });

//   final double paddingBottom;

//   final bool loading;
//   final bool isScrolled;

//   @override
//   Widget build(BuildContext context) {
//     // final trans = Locals.of(context);

//     if (isScrolled && !loading) {
//       return Center(
//         key: super.key,
//         heightFactor: 2,
//         child: Text(isScrolled ? greeting("end_of_records") : ""),
//       );
//     }

//     if (!loading) {
//       return const Text("");
//     }

//     return Center(
//       child: BoxWidget(
//         isBoxShadow: false,
//         rounding: 0,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(
//                 height: 20, width: 20, child: CircularProgressIndicator()),
//             Text(
//               "${greeting('loading_more')}..",
//               style: TextStyle(
//                 fontSize: scaleFontSize(14),
//                 color: primary,
//               ),
//             ),
//             SizedBox(height: paddingBottom),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // class LoadingMoreWidget extends StatelessWidget {
// //   const LoadingMoreWidget({super.key, this.paddingBottom = 8});

// //   final double paddingBottom;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           LottileWidget(
// //             inputFileLottie: loadingLottie,
// //             isController: false,
// //             width: getScreenWidth(60),
// //             height: getScreenHeight(60),
// //           ),
// //           Text(
// //             'Loading more..',
// //             style: TextStyle(
// //               fontSize: scaleFontSize(16),
// //               color: primaryColor,
// //             ),
// //           ),
// //           SizedBox(height: paddingBottom),
// //         ],
// //       ),
// //     );
// //   }
// // }
