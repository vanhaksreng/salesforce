import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/custom_alert_dialog_widget.dart';
import 'package:salesforce/core/presentation/widgets/list_tile_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/title_section_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/auth/presentation/pages/loggedin_history/loggedin_history_screen.dart';
import 'package:salesforce/features/auth/presentation/pages/login/login_screen.dart';
import 'package:salesforce/features/more/domain/entities/more_model.dart';
import 'package:salesforce/features/more/more_main_page_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/upload/upload_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/upload/upload_screen.dart';
import 'package:salesforce/features/more/presentation/pages/upload/upload_state.dart';
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

  Future<bool> checkUploadData(BuildContext context) async {
    final UploadCubit upload = UploadCubit();
    await upload.loadInitialData(DateTime.now());
    UploadState state = upload.state;
    bool nothingToUpload =
        state.salesHeaders.isEmpty &&
        state.cashReceiptJournals.isEmpty &&
        state.customerItemLedgerEntries.isEmpty &&
        state.competitorItemLedgerEntries.isEmpty &&
        state.merchandiseSchedules.isEmpty &&
        state.redemptions.isEmpty;

    if (!context.mounted) return false;

    if (!nothingToUpload) {
      Helpers.showDialogAction(
        context,
        labelAction: "Upload Data",
        confirmText: "Go to upload",
        cancelText: "No, Cancel",
        confirm: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, UploadScreen.routeName);
        },
        subtitle:
            "Looks like you still have data to upload. Please upload it before logging out.",
      );
      return false;
    }
    return true;
  }

  void _processLogout(BuildContext context) async {
    Navigator.pop(context);

    final l = LoadingOverlay.of(context);
    l.show();
    final result = await context.read<MoreMainPageCubit>().logout();

    l.hide();
    if (!context.mounted) return;

    if (result) {
      final canContinue = await checkUploadData(context);

      if (!canContinue || !context.mounted) return;
      // if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(),
          // const LoggedinHistoryScreen()
        ),
        (route) => false,
      );
    }
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
