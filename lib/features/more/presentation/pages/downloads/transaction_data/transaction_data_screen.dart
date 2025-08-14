import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/mixins/permission_mixin.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/downloads/transaction_data/transaction_data_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/downloads/transaction_data/transaction_data_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/circle_icon_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class TransactionDataScreen extends StatefulWidget {
  const TransactionDataScreen({super.key});

  @override
  State<TransactionDataScreen> createState() => _TransactionDataScreenState();
}

class _TransactionDataScreenState extends State<TransactionDataScreen> with PermissionMixin {
  final _cubit = TransactionDataCubit();

  @override
  void initState() {
    _cubit.loadInitialData();

    super.initState();
  }

  void _handleDownload(AppSyncLog record) async {
    final l = LoadingOverlay.of(context);
    try {
      l.show(1);
      await _cubit.downloadDatas([record]);
      l.hide();
    } catch (e) {
      l.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: BlocBuilder<TransactionDataCubit, TransactionDataState>(
        bloc: _cubit,
        builder: (BuildContext context, TransactionDataState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          final records = state.records ?? [];

          return buildBody(records);
        },
      ),
    );
  }

  Widget buildBody(List<AppSyncLog> records) {
    return ListView.separated(
      itemBuilder: (context, index) {
        return _buildRow(records[index], index);
      },
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace), vertical: appSpace),
      separatorBuilder: (context, index) => Helpers.buildDivider(),
      itemCount: records.length,
    );
  }

  Widget _buildRow(AppSyncLog record, int index) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.scale),
      title: TextWidget(text: record.displayName ?? "", fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: "${greeting("number_of_records")}: ${record.total}",
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
          TextWidget(
            text: "${greeting("last_download")}: ${record.lastSynchedDatetime}",
            color: Colors.grey.shade600,
            // fontStyle: FontStyle.italic,
            fontSize: 12,
          ),
        ],
      ),
      trailing: CircleIconWidget(
        onPress: () => _handleDownload(record),
        bgColor: background,
        colorIcon: primary,
        sizeIcon: 20.scale,
        icon: Icons.cloud_download_outlined,
      ),
    );
  }
}
