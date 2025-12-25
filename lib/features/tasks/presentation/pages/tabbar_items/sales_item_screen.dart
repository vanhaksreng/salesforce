import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/badge_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/tab_bar_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/add_card_preview/add_cart_preview_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/item_promotion/item_promotion_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/items/items_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/process/process_cubit.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class SalesItemScreen extends StatefulWidget {
  static const String routeName = "ProcessSaleOrderScreen";

  const SalesItemScreen({super.key, required this.args});
  final SaleItemArgs args;

  @override
  State<SalesItemScreen> createState() => _SalesItemScreenState();
}

class _SalesItemScreenState extends State<SalesItemScreen>
    with SingleTickerProviderStateMixin, MessageMixin {
  final _cubit = ProcessCubit();
  ValueNotifier<int> activeTap = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _loadCountCart();
  }

  void _loadCountCart() {
    _cubit.getSaleLines(
      scheduleId: widget.args.schedule.id,
      documentType: widget.args.documentType,
    );
  }

  @override
  void dispose() {
    activeTap.dispose();
    super.dispose();
  }

  final List<Tab> tabBarName = [
    Tab(text: greeting("items")),
    Tab(text: greeting("promotion")),
  ];

  void _handleDownload() async {
    if (!await _cubit.isConnectedToNetwork()) {
      showWarningMessage(errorInternetMessage);
      return;
    }

    if (!mounted) return;

    final l = LoadingOverlay.of(context);
    l.show(1);
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      List<String> tables = [
        "item",
        "item_sales_line_prices",
        "item_unit_of_measure",
      ];

      if (activeTap.value == 1) {
        tables = ["item_promotion_header", "item_promotion_line"];
      }

      final filter = tables.map((table) => '"$table"').toList();

      final appSyncLogs = await _cubit.getAppSyncLogs({
        'tableName': 'IN {${filter.join(",")}}',
      });

      if (tables.isEmpty) {
        throw GeneralException("Cannot find any table related");
      }

      const String text = "System will donwload only related data.";
      await Future.delayed(const Duration(milliseconds: 300));

      await _cubit.downloadDatas(
        appSyncLogs,
        onProgress: (progress, count, tableName, errorMsg) {
          l.updateProgress(progress, text: text);
        },
      );
      l.hide();

      _cubit.refreshing();
    } on GeneralException catch (e) {
      l.hide();
      showWarningMessage(e.message);
    } on Exception catch (e) {
      l.hide();
      showErrorMessage(e.toString());
    }
  }

  void _navigateToAddedCart() {
    Navigator.pushNamed(
      context,
      AddCartPreviewScreen.routeName,
      arguments: {
        'customerNo': widget.args.customerNo,
        'scheduleId': widget.args.schedule.id,
        'documentType': widget.args.documentType,
      },
    ).then((value) {
      _loadCountCart();
    });
  }

  String _screenTitle() {
    return "Sale ${widget.args.documentType}";
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabBarName.length,
      child: Scaffold(
        appBar: AppBarWidget(
          heightBottom: heightBottomSearch,
          enableGradient: true,
          title: _screenTitle(),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: scaleFontSize(appSpace)),
              child: BtnIconCircleWidget(
                onPressed: _handleDownload,
                icons: const Icon(Icons.cloud_download_rounded, color: white),
                rounded: appBtnRound,
              ),
            ),
          ],
          bottom: TabBarWidget(
            tabs: tabBarName,
            onTap: (value) {
              activeTap.value = value;
            },
          ),
        ),
        body: BlocBuilder<ProcessCubit, ProcessState>(
          bloc: _cubit,
          builder: (context, state) {
            return TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ItemScreen(
                  schedule: widget.args.schedule,
                  documentType: widget.args.documentType,
                  onRefresh: _loadCountCart,
                  isRefreshing: state.isRefreshing,
                ),
                ItemPromotionScreen(
                  schedule: widget.args.schedule,
                  documentType: widget.args.documentType,
                  onRefresh: _loadCountCart,
                  isRefreshing: state.isRefreshing,
                ),
              ],
            );
          },
        ),
        floatingActionButton: _buildStoreItemBtn(),
      ),
    );
  }

  Widget _buildStoreItemBtn() {
    return BlocBuilder<ProcessCubit, ProcessState>(
      bloc: _cubit,
      builder: (context, state) {
        return SafeArea(
          child: BtnIconCircleWidget(
            bgColor: mainColor50,
            flipX: false,
            onPressed: () => _navigateToAddedCart(),
            icons: Center(
              child: BadgeWidget(
                label: "${state.cartCount}",
                colorIcon: white,
                iconSvg: kAddCart,
              ),
            ),
          ),
        );
      },
    );
  }
}
