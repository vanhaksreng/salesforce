// import 'package:flutter/material.dart';

// class AnimatedHeaderBox extends StatelessWidget {
//   final bool active;
//   final Widget child;

//   const AnimatedHeaderBox({
//     super.key,
//     required this.active,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 400),
//       switchInCurve: Curves.easeOut,
//       switchOutCurve: Curves.easeIn,
//       transitionBuilder: (Widget child, Animation<double> animation) {
//         return FadeTransition(
//           opacity: animation,
//           child: SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(0, 0.2),
//               end: Offset.zero,
//             ).animate(animation),
//             child: child,
//           ),
//         );
//       },
//       child: Container(
//         key: ValueKey<bool>(active),
//         child: child,
//       ),
//     );
//   }
// }
