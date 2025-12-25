import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/tab_bar_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/domain/entities/more_model.dart';
import 'package:salesforce/features/more/presentation/pages/downloads/master_data/master_data_screen.dart';
import 'package:salesforce/features/more/presentation/pages/downloads/more_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/downloads/transaction_data/transaction_data_screen.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class DownloadScreen extends StatefulWidget {
  static const String routeName = "Download";
  final Args arg;

  const DownloadScreen({required this.arg, super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> with SingleTickerProviderStateMixin {
  final screenCubit = MoreCubit();
  late TabController tabController;
  final ValueNotifier<List<AppSyncLog>> tables = ValueNotifier([]);
  final ValueNotifier<int> activeTab = ValueNotifier(0);

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  updateTabValue(int value) {
    if (activeTab.value != value) {
      tables.value = [];
      screenCubit.setSelectAll(false);
    }

    activeTab.value = value;
  }

  void _handleTableSelection(AppSyncLog logs, bool isSelected) {
    List<AppSyncLog> updatedTables = List.from(tables.value);

    if (isSelected) {
      updatedTables.add(logs);
    } else {
      updatedTables.remove(logs);
    }

    tables.value = updatedTables;
  }

  void _handleDownloadMasterData() async {
    if (activeTab.value == 1) {
      return;
    }
    final l = LoadingOverlay.of(context);
    l.show(1);

    if (screenCubit.state.isSelectAll) {
      await screenCubit.fetchMasterDataTables();
      tables.value = screenCubit.state.records ?? [];
    }

    if (tables.value.isEmpty) {
      l.hide();
      Helpers.showMessage(msg: greeting("please_select_table"), status: MessageStatus.warning);
      return;
    }

    if (!mounted) return;

    try {
      await screenCubit.downloadMasterDatas(tables.value, (progress, count, tableName, errorMsg) {
        l.updateProgress(progress, text: tableName);
      });

      l.hide();
      tables.value = [];
    } catch (e) {
      l.hide();
    }
  }

  void _handleSelectAll() {
    screenCubit.setToggleSelectAll();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: BlocBuilder<MoreCubit, MoreState>(
        bloc: screenCubit,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: white,
            appBar: _buildAppbar(state),
            body: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MasterDataScreen(
                  onChanged: _handleTableSelection,
                  refresh: state.refresh,
                  isSelectAll: state.isSelectAll,
                ),
                const TransactionDataScreen(),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSize _buildAppbar(MoreState state) {
    return PreferredSize(
      preferredSize: Size.fromHeight(scaleFontSize(100)),
      child: ValueListenableBuilder(
        valueListenable: activeTab,
        builder: (context, activeValue, child) {
          return AppBarWidget(
            title: widget.arg.parentTitle,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: scaleFontSize(appSpace)),
                child: BtnIconCircleWidget(
                  onPressed: _handleDownloadMasterData,
                  icons: const Icon(Icons.cloud_download_rounded, color: white),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: scaleFontSize(appSpace)),
                child: BtnIconCircleWidget(
                  flipX: false,
                  onPressed: _handleSelectAll,
                  icons: const Icon(Icons.checklist, color: white),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(AppBar().preferredSize.height),
              child: TabBarWidget(
                onTap: (value) => updateTabValue(value),
                controller: tabController,
                tabs: [Text(greeting("mater_data")), Text(greeting("tran_data"))],
              ),
            ),
          );
        },
      ),
    );
  }
}
