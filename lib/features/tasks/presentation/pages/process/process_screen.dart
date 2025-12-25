import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/constants/permission.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/svg_widget.dart';
import 'package:salesforce/core/presentation/widgets/title_section_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/process_dtos.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/collections/collections_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/item_prize_redemption/item_prize_redemption_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/posm_and_merchanding_competitor/posm_and_merchanding_competior_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/process/process_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/tabbar_items/check_stock_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/tabbar_items/sales_item_screen.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/list_tile_wiget.dart';
import 'package:salesforce/theme/app_colors.dart';

class ProcessScreen extends StatefulWidget {
  static const String routeName = "processScreen";
  final CheckStockArgs args;
  // final SalespersonSchedule schedule;
  // final Customer customer;

  const ProcessScreen({
    super.key,
    // required this.schedule,
    // required this.customer,
    required this.args,
  });

  @override
  State<ProcessScreen> createState() => _ProcessScreenState();
}

class _ProcessScreenState extends State<ProcessScreen> with MessageMixin {
  final _cubit = ProcessCubit();

  @override
  void initState() {
    super.initState();
    _cubit.loadInitialData(widget.args.schedule);
    // _handleDownload();
  }

  ProcessDtos _buildProcessModel({
    required String icon,
    required String titleKey,
    required String subtitleKey,
    String? routeName,
    ProcessArgs? args,
    int countNumber = 0,
    String? permissionCode,
    bool show = true,
    String type = "",
  }) {
    return ProcessDtos(
      icon: icon,
      title: greeting(titleKey),
      routeName: routeName,
      args: args,
      type: type,
      subTitle: greeting(subtitleKey),
      countNumber: countNumber,
      permissionCode: permissionCode,
      show: show,
    );
  }

  void _handleProcessTap(ProcessDtos process) async {
    if (process.routeName?.isNotEmpty ?? false) {
      if (process.permissionCode != null &&
          !await _cubit.hasPermission(process.permissionCode!)) {
        showWarningMessage("Access Denied");
        return;
      }

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        process.routeName!,
        arguments: process.args,
      ).then((value) {
        _cubit.loadInitialData(widget.args.schedule);
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getProcessListAsync() async {
    return [
      {
        "Label": "inventory_management",
        "data": [
          _buildProcessModel(
            icon: kPngCheckStock,
            titleKey: 'check_stock',
            routeName: CheckStockScreen.routeName,
            args: CheckStockArgs(
              schedule: widget.args.schedule,
              customerNo: widget.args.customerNo,
            ),
            subtitleKey: 'count_remaining_quantity_of_items_at_customer_place',
            countNumber: _cubit.state.countCheckStock,
            type: "IM",
            show: await _cubit.hasPermission(kUseCheckStock),
          ),
          _buildProcessModel(
            icon: kPngPOSM,
            titleKey: greeting('POSM'),
            subtitleKey: greeting('posm_subtitle'),
            routeName: PosmAndMerchandingCompetitorScreen.routeName,
            countNumber: _cubit.state.countPosm,
            type: "IM",
            args: PosmAndMerchandingCompetitorArg(
              schedule: widget.args.schedule,
              posmMerchandingType: PosmMerchandingType.psom,
            ),
            show: await _cubit.hasPermission(kUsePosm),
          ),
          _buildProcessModel(
            icon: kPngMerchandising,
            titleKey: greeting('Merchandising'),
            type: "IM",
            subtitleKey: greeting('merchandising_sub_title'),
            routeName: PosmAndMerchandingCompetitorScreen.routeName,
            countNumber: _cubit.state.countMerchandising,
            args: PosmAndMerchandingCompetitorArg(
              schedule: widget.args.schedule,
              posmMerchandingType: PosmMerchandingType.merchanding,
            ),
            show: await _cubit.hasPermission(kUseMerchandising),
          ),
          // _buildProcessModel(
          //   icon: kCompetitorIcon,
          //   titleKey: greeting('competitor_promotion'),
          //   subtitleKey: greeting('take_note_competitor\'s_promotion.'),
          //   type: "IM",
          //   routeName: PosmAndMerchandingCompetitorScreen.routeName,
          //   // routeName: CompetitorPromotionScreen.routeName,
          //   countNumber: _cubit.state.countCompetitorPromotion,
          //   args: PosmAndMerchandingCompetitorArg(
          //     schedule: widget.schedule,
          //     posmMerchandingType: PosmMerchandingType.competitorPro,
          //   ),
          //   // args: SaleItemArgs(
          //   //   schedule: widget.schedule,
          //   //   documentType: kSaleCreditMemo,
          //   // ),
          //   show: await _cubit.hasPermission(kUseCompletitorPromotion),
          // ),
        ],
      },
      {
        "Label": greeting("Sales Management"),
        "data": [
          _buildProcessModel(
            icon: kSaleOrderIcon,
            titleKey: 'sales_order',
            routeName: SalesItemScreen.routeName,
            subtitleKey: 'create_sales_order_for_customer',
            countNumber: _cubit.state.countSaleOrder,
            args: SaleItemArgs(
              customerNo: widget.args.customerNo,
              schedule: widget.args.schedule,
              documentType: kSaleOrder,
            ),
            show: await _cubit.hasPermission(kUseSaleOrder),
          ),
          _buildProcessModel(
            icon: kSaleInvoiceIcon,
            titleKey: 'sales_invoice',
            routeName: SalesItemScreen.routeName,
            subtitleKey: 'create_sale_invoice_for_customer',
            countNumber: _cubit.state.countSaleInvoice,
            args: SaleItemArgs(
              customerNo: widget.args.customerNo,
              schedule: widget.args.schedule,
              documentType: kSaleInvoice,
            ),
            show: await _cubit.hasPermission(kUseSaleInvoice),
          ),
          _buildProcessModel(
            icon: kSaleCreMemoIcon,
            titleKey: greeting('sales_credit_memo'),
            routeName: SalesItemScreen.routeName,
            subtitleKey: greeting('sales_credit_memo_for_customer'),
            countNumber: _cubit.state.countSaleCreditMemo,
            args: SaleItemArgs(
              customerNo: widget.args.customerNo,
              schedule: widget.args.schedule,
              documentType: kSaleCreditMemo,
            ),
            show: await _cubit.hasPermission(kUseSaleCredit),
          ),
          _buildProcessModel(
            icon: kCollection,
            titleKey: greeting('collection'),
            subtitleKey: greeting('collect_payment_from_the_customer'),
            routeName: CollectionsScreen.routeName,
            countNumber: _cubit.state.countCollection,
            args: CollectionsArg(schedule: widget.args.schedule),
            show: await _cubit.hasPermission(kUseCollection),
          ),
          _buildProcessModel(
            icon: kItemPrize,
            routeName: ItemPrizeRedemptionScreen.routeName,
            titleKey: greeting('item_prize_redemption'),
            subtitleKey: greeting('redempt_item_programs_for_the_customers'),
            args: DefaultProcessArgs(schedule: widget.args.schedule),
            show: await _cubit.hasPermission(kUseItemPriceRedeption),
            countNumber: _cubit.state.countItemPrizeRedeption,
          ),
        ],
      },
    ];
  }

  Future<void> _handleDownload() async {
    final loading = LoadingOverlay.of(context);

    try {
      if (!await _cubit.isConnectedToNetwork()) {
        debugPrint('No network connection.');
        return;
      }

      const tables = [
        // "customer_ledger_entry",
        // "cash_receipt_journals",
        // "promotion_type",
        // "vat_posting_setup",
      ];

      if(tables.isEmpty) {
        loading.hide();
        return;
      }

      final filter = tables.map((table) => '"$table"').join(',');

      final appSyncLogs = await _cubit.getAppSyncLogs({
        'tableName': 'IN {$filter}',
      });

      if (appSyncLogs.isEmpty) {
        debugPrint('No tables to download.');
        return;
      }

      if (!mounted) return;

      loading.show();

      await _cubit.downloadDatas(
        appSyncLogs,
        showMessageAfterSuccess: false,
      );

    } on Exception catch (e) {
      debugPrint('Download error: $e');
    } finally {
      loading.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        onBack: () => Navigator.of(context).pop(widget.args.schedule),
        title: greeting("process"),
      ),
      body: BlocBuilder<ProcessCubit, ProcessState>(
        bloc: _cubit,
        builder: (context, state) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _getProcessListAsync(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const LoadingPageWidget();
              }
              final processList = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.only(top: appSpace),
                child: SafeArea(child: _buildListLabel(processList)),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildListLabel(List<Map<String, dynamic>> processList) {
    return ListView.builder(
      itemCount: processList.length,
      itemBuilder: (context, index) {
        final process = processList[index];

        final List<ProcessDtos> dataProcess = (process["data"] as List)
            .cast<ProcessDtos>()
            .where((e) => e.show)
            .toList();
        if (dataProcess.isEmpty) {
          return const SizedBox.shrink();
        }
        return _buildListData(process, dataProcess);
      },
    );
  }

  Widget _buildListData(
    Map<String, dynamic> process,
    List<ProcessDtos> dataProcess,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: appSpace, vertical: 8.scale),
      child: TitleSectionWidget(
        label: process["Label"] ?? "",
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.scale),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dataProcess.length,
          itemBuilder: (context, indexData) {
            return _buildProcessItem(dataProcess[indexData]);
          },
        ),
      ),
    );
  }

  Widget _buildProcessItem(ProcessDtos process) {
    if (!process.show) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.scale),
      child: ListTitleWidget(
        key: Key(process.title),
        label: process.title,
        fontSizeLabel: 15,
        subTitle: process.subTitle,
        onTap: () => _handleProcessTap(process),
        leading: _buildProcessIcon(process.icon),
        countNumber: process.countNumber,
      ),
    );
  }

  Widget _buildProcessIcon(String iconPath) {
    return BtnIconCircleWidget(
      rounded: 6,
      bgColor: mainColor50.withValues(alpha: .1),
      onPressed: () {},
      flipX: false,
      icons: SvgWidget(colorSvg: mainColor, assetName: iconPath),
    );
  }
}
