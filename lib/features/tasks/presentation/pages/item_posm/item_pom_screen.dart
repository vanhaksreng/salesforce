import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/item_posm/item_posm_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/posm_merchanding_preview/posm_merchanding_preview_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/process_components/item_posm_and_merchanding_box.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class ItemPosmScreen extends StatefulWidget {
  const ItemPosmScreen({super.key, required this.arg});

  static const String routeName = "itemPosmTaskScreen";
  final ItemPosmAndMerchandiseArg arg;

  @override
  State<ItemPosmScreen> createState() => _ItemPosmScreenState();
}

class _ItemPosmScreenState extends State<ItemPosmScreen> with MessageMixin {
  final posm = PosmMerchandingType.psom;
  final _cubit = ItemPosmCubit();
  final _scrollController = ScrollController();

  late String filterString;
  late String searchString;
  @override
  void initState() {
    super.initState();
    _cubit.getPosms();
    _getSalesPersonScheduleMerchandise();
    _scrollController.addListener(_handleScrolling);
  }

  void _handleScrolling() {
    if (_shouldLoadMore()) {
      _loadMoreItems();
    }
  }

  bool _shouldLoadMore() {
    return _scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_cubit.state.isFetching;
  }

  void _loadMoreItems() {
    final page = Helpers.toInt(_cubit.state.currentPage) + 1;
    _itemFilter(page);
  }

  void _itemFilter([int page = 1]) async {
    Map<String, dynamic> params = {};

    if (searchString.isNotEmpty) {
      params["description"] = 'LIKE $searchString%';
    }

    await _cubit.getPosms(page: page, isLoading: false, param: params);
  }

  void _onSearchItem(String value) async {
    searchString = value;
    _itemFilter();
  }

  void _getSalesPersonScheduleMerchandise() {
    _cubit.getSalesPersonScheduleMerchandises(
      param: {
        "visit_no": widget.arg.schedule.id,
        "competitor_no": widget.arg.competitor?.no,
        "merchandise_option": kPOSM,
      },
    );
  }

  void _onUpdateQtyHandler(double value, PointOfSalesMaterial posm) async {
    await _cubit.storePosmMerchan(
      args: ItemPosmAndMerchandiseArg(
        schedule: widget.arg.schedule,
        posm: posm,
        qty: value,
        competitor: widget.arg.competitor,
        posmMerchandType: PosmMerchandingType.psom,
      ),
    );
  }

  onPushToPriview() {
    Navigator.pushNamed(
      context,
      PosmMerchandingPreviewScreen.routeName,
      arguments: ItemPosmAndMerchandiseArg(schedule: widget.arg.schedule, posmMerchandType: PosmMerchandingType.psom),
    ).then((value) {
      _getSalesPersonScheduleMerchandise();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting("posm_item"),
        bottom: SearchWidget(onSubmitted: (String value) => _onSearchItem(value)),
        heightBottom: heightBottomSearch,
      ),
      body: BlocBuilder<ItemPosmCubit, ItemPosmState>(
        bloc: _cubit,
        builder: (context, state) {
          final posms = state.posms;
          if (posms.isEmpty) {
            return const EmptyScreen();
          }
          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(ItemPosmState state) {
    final posm = state.posms;
    return Padding(
      padding: EdgeInsets.all(scaleFontSize(appSpace8)),
      child: Column(
        spacing: scaleFontSize(appSpace8),
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: posm.length,
              itemBuilder: (context, index) {
                final item = posm[index];

                final matching = state.spsms
                    .where(
                      (entry) =>
                          entry.merchandiseCode == item.code && entry.visitNo?.toString() == widget.arg.schedule.id,
                    )
                    .toList();

                double qty = 0.0;
                String? status = "";

                if (matching.isNotEmpty) {
                  qty = Helpers.toDouble(matching.first.quantity ?? 0.0);

                  status = matching.first.status == "Submitted" ? matching.first.status : "";
                }

                return ItemPosmAndMerchandingBox(
                  key: ValueKey(item.code),
                  args: ItemPosmAndMerchandise(
                    qtyStock: qty,
                    description: item.code,
                    description2: item.description ?? "",
                    status: status ?? "",
                    onUpdateQty: (qty) => _onUpdateQtyHandler(qty, item),
                    onEditScreen: null,
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: BtnWidget(
              gradient: linearGradient,
              // onPressed: () => _onSubmitPosm(),
              onPressed: onPushToPriview,
              // title: greeting("submit"),
              title: greeting("Priview"),
            ),
          ),
        ],
      ),
    );
  }
}
