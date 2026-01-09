import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/app/app_state_handler.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/auth/domain/entities/notification_model.dart';
import 'package:salesforce/features/notification/notification_cubit.dart';
import 'package:salesforce/features/notification/notification_state.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _cubit = NotificationCubit();

  @override
  void initState() {
    _cubit.getNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: "notification", isBackIcon: false),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        bloc: _cubit,
        builder: (context, state) {
          final records = state.notifications;
          return AppStateHandler(
            isLoading: state.isLoading,
            error: state.error,
            records: records,
            onData: () => buildBody(state),
          );
        },
      ),
    );
  }

  Widget buildBody(NotificationState state) {
    final notifications = state.notifications;
    if (notifications.isEmpty) {
      return const EmptyScreen();
    }
    return ListView.builder(
      itemCount: notifications.length,
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildBoxNotification(notification);
      },
    );
  }

  BoxWidget _buildBoxNotification(NotificationModel notification) {
    return BoxWidget(
      isBorder: false,
      isBoxShadow: false,
      isRounding: true,
      margin: EdgeInsets.symmetric(vertical: 4.scale),
      padding: EdgeInsets.all(scaleFontSize(8)),
      child: Row(
        spacing: 8.scale,
        children: [
          ImageNetWorkWidget(
            width: 60.scale,
            height: 60.scale,
            imageUrl: notification.imgUrl,
          ),
          _buildContent(notification),
        ],
      ),
    );
  }

  Expanded _buildContent(NotificationModel notification) {
    return Expanded(
      child: Column(
        spacing: 8.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(text: notification.title, fontWeight: FontWeight.w600),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8.scale,
                children: [
                  TextWidget(
                    text: notification.date,
                    color: textColor50,
                    fontWeight: FontWeight.w600,
                  ),
                  // Container(
                  //     width: 8.scale,
                  //     height: 8.scale,
                  //     decoration: const BoxDecoration(
                  //       color: red,
                  //       shape: BoxShape.circle,
                  //     ))
                ],
              ),
            ],
          ),
          TextWidget(text: notification.description),
        ],
      ),
    );
  }
}
