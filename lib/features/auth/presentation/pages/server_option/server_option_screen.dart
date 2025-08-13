// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:salesforce/core/constants/app_assets.dart';
// import 'package:salesforce/core/constants/app_styles.dart';
// import 'package:salesforce/core/utils/helpers.dart';
// import 'package:salesforce/core/utils/size_config.dart';
// import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
// import 'package:salesforce/core/presentation/widgets/text_widget.dart';
// import 'package:salesforce/features/auth/presentation/pages/dedicate/dedicate_screen.dart';
// import 'package:salesforce/features/auth/presentation/pages/login/login_screen.dart';
// import 'package:salesforce/features/auth/presentation/pages/server_option/server_option_cubit.dart';
// import 'package:salesforce/features/auth/presentation/pages/server_option/server_option_state.dart';
// import 'package:salesforce/injection_container.dart';
// import 'package:salesforce/localization/trans.dart';
// import 'package:salesforce/core/presentation/widgets/box_widget.dart';
// import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
// import 'package:salesforce/core/presentation/widgets/build_logo_header_widget.dart';
// import 'package:salesforce/realm/scheme/schemas.dart';
// import 'package:salesforce/theme/app_colors.dart';

// class ServerOptionScreen extends StatefulWidget {
//   const ServerOptionScreen({Key? key, this.serverId}) : super(key: key);

//   static const String routeName = "authServerOption";

//   final String? serverId;

//   @override
//   State<ServerOptionScreen> createState() => _ServerOptionScreenState();
// }

// class _ServerOptionScreenState extends State<ServerOptionScreen> {
//   final _cubit = ServerOptionCubit();
//   final ValueNotifier<String> serverId = ValueNotifier("");
//   late int selectedIndex = 0;

//   @override
//   void initState() {
//     _cubit.getServerLists();
//     super.initState();
//   }

//   void _navigateToNextScreen(AppServer server) {
//     String routeName = LoginScreen.routeName;
//     if (server.id == "dedicated") {
//       routeName = DedicateScreen.routeName;
//     }

//     //Register Injection
//     updateAppServerInjection(server);

//     Navigator.pushNamed(context, routeName, arguments: server);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Color(0xFF59A5F5),
//             Color(0xFFF5F5F5),
//             Color(0xFFF5F5F5),
//           ],
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//         ),
//         body: BlocBuilder<ServerOptionCubit, ServerOptionState>(
//           bloc: _cubit,
//           builder: (BuildContext context, ServerOptionState state) {
//             if (state.isLoading) {
//               return const LoadingPageWidget();
//             }

//             return _buildBody(state);
//           },
//         ),
//         persistentFooterButtons: [
//           BlocBuilder<ServerOptionCubit, ServerOptionState>(
//               bloc: _cubit,
//               builder: (context, state) {
//                 final servers = state.servers;
//                 return ValueListenableBuilder(
//                     valueListenable: serverId,
//                     builder: (context, value, c) {
//                       return Visibility(
//                         visible: value.isNotEmpty,
//                         child: BtnWidget(
//                           gradient: linearGradient,
//                           size: BtnSize.medium,
//                           horizontal: appSpace,
//                           onPressed: () {
//                             if (widget.serverId != null) {
//                               selectedIndex = servers.indexWhere((e) {
//                                 return e.id == value;
//                               });
//                             }
//                             _navigateToNextScreen(servers[selectedIndex]);
//                           },
//                           title: greeting("continue"),
//                         ),
//                       );
//                     });
//               }),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody(ServerOptionState state) {
//     final servers = state.servers;

//     if (servers.isEmpty) {
//       // TODO : here
//     }

//     return ListView(
//       padding: EdgeInsets.symmetric(
//         horizontal: scaleFontSize(appSpace),
//       ),
//       children: [
//         const BuildLogoHeaderWidget(),
//         TextWidget(
//           text: greeting("please_select_server_below"),
//         ),
//         Helpers.gapH(appSpace),
//         ListView.builder(
//           physics: const NeverScrollableScrollPhysics(),
//           shrinkWrap: true,
//           itemCount: servers.length,
//           itemBuilder: (BuildContext context, int index) {
//             return Padding(
//               padding: EdgeInsets.symmetric(
//                 vertical: scaleFontSize(2),
//               ),
//               child: _buildBoxWidget(server: servers[index], index: index),
//             );
//           },
//         ),
//         Helpers.gapH(appSpace),
//       ],
//     );
//   }

//   Widget _buildBoxWidget({required AppServer server, required int index}) {
//     return ValueListenableBuilder(
//       valueListenable: serverId,
//       builder: (context, activeServerid, child) {
//         return Stack(
//           key: ValueKey(server.id),
//           children: [
//             BoxWidget(
//               key: ValueKey(server.id),
//               onPress: () {
//                 serverId.value = server.id;
//                 selectedIndex = index;
//               },
//               isBorder: activeServerid == server.id,
//               borderColor: grey,
//               isBoxShadow: false,
//               height: scaleFontSize(60),
//               padding: EdgeInsets.all(scaleFontSize(appSpace)),
//               margin: EdgeInsets.symmetric(vertical: scaleFontSize(3)),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 spacing: scaleFontSize(appSpace8),
//                 children: [
//                   Row(
//                     spacing: scaleFontSize(appSpace),
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       SizedBox(
//                         height: scaleFontSize(30),
//                         child: SvgPicture.asset(
//                           kAppDataStore,
//                           height: scaleFontSize(30),
//                         ),
//                       ),
//                       TextWidget(text: server.name),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Visibility(
//               visible: activeServerid == server.id,
//               child: Positioned(
//                 top: scaleFontSize(3),
//                 right: 0,
//                 child: Image.asset(kAppTick, width: scaleFontSize(30)),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
