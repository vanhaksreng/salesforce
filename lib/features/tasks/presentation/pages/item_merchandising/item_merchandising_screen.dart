import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/item_merchandising/item_merchandising_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/posm_merchanding_preview/posm_merchanding_preview_screen.dart';
import 'package:salesforce/features/tasks/presentation/pages/process_components/item_posm_and_merchanding_box.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class ItemMerchandisingScreen extends StatefulWidget {
  const ItemMerchandisingScreen({super.key, required this.args});
  static const String routeName = "item_merchanding";
  final ItemPosmAndMerchandiseArg args;

  @override
  State<ItemMerchandisingScreen> createState() => _ItemMerchandisingScreenState();
}

class _ItemMerchandisingScreenState extends State<ItemMerchandisingScreen> with MessageMixin {
  final _cubit = ItemMerchandisingCubit();

  final _scrollController = ScrollController();

  late String filterString;
  late String searchString;

  @override
  void initState() {
    super.initState();
    _cubit.getMerchandises();
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

    await _cubit.getMerchandises(page: page, isLoading: false, param: params);
  }

  void _onSearchItem(String value) async {
    searchString = value;
    _itemFilter();
  }

  void onPushToPriview() {
    Navigator.pushNamed(
      context,
      PosmMerchandingPreviewScreen.routeName,
      arguments: ItemPosmAndMerchandiseArg(
        schedule: widget.args.schedule,
        posmMerchandType: PosmMerchandingType.merchanding,
      ),
    ).then((value) {
      _getSalesPersonScheduleMerchandise();
    });
  }

  // Future<void> _onSubMerchanDise() async {
  //   final lists = _cubit.state.spsms.where((e) => e.status == kStatusOpen);
  //   if (lists.isEmpty) {
  //     showWarningMessage("Nothing to submit");
  //     return;
  //   }

  //   Helpers.showDialogAction(
  //     context,
  //     labelAction: greeting("submitt"),
  //     subtitle: greeting("do_you_want_to_submit_now?"),
  //     confirm: () {
  //       _cubit.submitMerchandiseSchdedule();
  //       Navigator.pop(context);
  //     },
  //   );
  // }

  void _getSalesPersonScheduleMerchandise() {
    _cubit.getSalesPersonScheduleMerchandises(
      param: {
        "visit_no": widget.args.schedule.id,
        "competitor_no": widget.args.competitor?.no,
        "merchandise_option": kMerchandize,
      },
    );
  }

  void _onUpdateQtyHandler(double value, Merchandise merchandis) async {
    await _cubit.storeSalesPersonScheduleMerchandise(
      args: ItemPosmAndMerchandiseArg(
        schedule: widget.args.schedule,
        merchandis: merchandis,
        qty: value,
        competitor: widget.args.competitor,
        posmMerchandType: PosmMerchandingType.merchanding,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting("merchanding_item"),
        heightBottom: heightBottomSearch,
        bottom: SearchWidget(onSubmitted: (String value) => _onSearchItem(value)),
      ),
      body: BlocBuilder<ItemMerchandisingCubit, ItemMerchandisingState>(
        bloc: _cubit,
        builder: (context, state) {
          final merchindises = state.merchindises ?? [];
          if (merchindises.isEmpty) {
            return const EmptyScreen();
          }
          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(ItemMerchandisingState state) {
    List<Merchandise> merchindises = state.merchindises ?? [];
    return Padding(
      padding: EdgeInsets.all(scaleFontSize(appSpace8)),
      child: Column(
        spacing: scaleFontSize(appSpace8),
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: merchindises.length,
              itemBuilder: (context, index) {
                final item = merchindises[index];
                final matching = state.spsms.where((entry) {
                  return entry.merchandiseCode == item.code && "${entry.visitNo}" == widget.args.schedule.id;
                }).toList();

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
                    description: item.description ?? "",
                    description2: item.description2 ?? "",
                    status: status ?? "",
                    onUpdateQty: (double value) => _onUpdateQtyHandler(value, item),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: BtnWidget(
              gradient: linearGradient,
              onPressed: () => onPushToPriview(),
              // onPressed: () => _onSubMerchanDise(),
              title: greeting("Priview"),
            ),
          ),
        ],
      ),
    );
  }
}
