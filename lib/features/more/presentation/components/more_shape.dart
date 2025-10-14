import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/list_tile_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/title_section_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/auth/presentation/pages/loggedin_history/loggedin_history_screen.dart';
import 'package:salesforce/features/more/domain/entities/more_model.dart';
import 'package:salesforce/features/more/more_main_page_cubit.dart';
import 'package:salesforce/theme/app_colors.dart';

class BuildMore extends StatelessWidget {
  const BuildMore({
    super.key,
    required this.listActionMore,
    required this.lable,
  });

  final List<MoreModel> listActionMore;
  final String lable;

  void _navigatorToScreen(BuildContext context, int index) {
    String routeName = listActionMore[index].routeName;

    if (routeName == "logout") {
      _confrimLogout(context);
      return;
    }

    Navigator.pushNamed(
      context,
      routeName,
      arguments: listActionMore[index].arg,
    );
  }

  void _confrimLogout(BuildContext context) {
    Helpers.showDialogAction(
      context,
      confirmText: "Yes, Log Out",
      cancelText: "No, Stay Logged In",
      confirm: () => _processLogout(context),
    );
  }

  void _processLogout(BuildContext context) async {
    final l = LoadingOverlay.of(context);
    l.show();
    await context.read<MoreMainPageCubit>().logout();

    l.hide();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoggedinHistoryScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TitleSectionWidget(
      label: lable,
      pt: scaleFontSize(appSpace8),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: listActionMore.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (listActionMore[index].isShow == false) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 2.scale),
            child: ListTitleWidget(
              onTap: () => _navigatorToScreen(context, index),
              label: listActionMore[index].title,
              leading: Icon(
                listActionMore[index].icon,
                size: 24.scale,
                color: mainColor,
              ),
              subTitle: listActionMore[index].subTitle,
            ),
          );
        },
      ),
    );
  }
}
