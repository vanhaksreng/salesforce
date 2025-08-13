import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/presentation/widgets/btn_text_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/presentation/pages/group_screen_filter_item/group_screen_filter_item_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/group_screen_filter_item/list_tile_selected.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class GroupScreenFilterItem extends StatefulWidget {
  const GroupScreenFilterItem({super.key, required this.args});
  static const String routeName = "group_screen_filter";
  final GroupFilterArgs args;

  @override
  State<GroupScreenFilterItem> createState() => _GroupScreenFilterItemState();
}

class _GroupScreenFilterItemState extends State<GroupScreenFilterItem> {
  final _cubit = GroupScreenFilterItemCubit();
  final ValueNotifier<int> page = ValueNotifier<int>(1);
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  List<String> status = [kInStock, kOutOfStock];
  late String searchString;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _cubit.getItemsGroup(page: 1);
    });

    checkEmitValue();
    _scrollController.addListener(_handleScrolling);
    super.initState();
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

    await _cubit.getItemsGroup(page: page, isLoading: false, param: params);
  }

  void _onSearchItem(String value) async {
    searchString = value;
    _itemFilter();
  }

  void checkEmitValue() {
    for (var a in widget.args.groupCodes) {
      _cubit.selectedGroupCode(a);
    }

    _cubit.selectStatus(getStatus());
  }

  String getStatus() {
    if (widget.args.status == "< 1") {
      return kOutOfStock;
    } else if (widget.args.status == "> 0") {
      return kInStock;
    }
    return "";
  }

  void _onCallback() {
    Navigator.pop(context, {"groupCode": _cubit.state.grupCode, "stock": _cubit.state.statusStock});
  }

  void _resetFilter() {
    widget.args.groupCodes.clear();
    _cubit.resetFilter();
  }

  onSelectedStatus(String statusStock) {
    _cubit.selectStatus(statusStock);
  }

  bool isShowResetBtn({required String status, required List<String>? grupCode}) {
    return status.isNotEmpty || (grupCode ?? []).isNotEmpty;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    isLoading.dispose();
    page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting("filter"),
        isBackIcon: true,
        heightBottom: heightBottomSearch,
        bottom: SearchWidget(onSubmitted: (value) => _onSearchItem(value)),
      ),
      body: BlocBuilder<GroupScreenFilterItemCubit, GroupScreenFilterItemState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }
          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(GroupScreenFilterItemState state) {
    final List<ItemGroup> itemGroup = state.itemsGroup ?? [];
    return Padding(
      padding: EdgeInsets.all(scaleFontSize(appSpace8)),
      child: Column(
        spacing: scaleFontSize(appSpace8),
        children: [
          BoxWidget(
            width: double.infinity,
            isBoxShadow: false,
            padding: EdgeInsets.all(8.scale),
            child: Column(
              spacing: scaleFontSize(appSpace),
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(text: greeting("Status"), fontSize: 16, fontWeight: FontWeight.bold),
                Wrap(
                  spacing: 8.scale,
                  children: List.generate(
                    status.length,
                    (int index) => BtnTextWidget(
                      rounded: 16,
                      vertical: 8,
                      horizontal: 16,
                      borderColor: grey20,
                      bgColor: state.statusStock == status[index] ? mainColor : grey20,
                      onPressed: () => onSelectedStatus(status[index].toString()),
                      child: TextWidget(
                        text: status[index].toString(),
                        color: state.statusStock == status[index] ? white : textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BoxWidget(
              isBoxShadow: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(scaleFontSize(8.scale)),
                    child: TextWidget(text: greeting("groups"), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  _buildItemGroups(itemGroup),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Row(
              spacing: scaleFontSize(8),
              children: [
                if (isShowResetBtn(status: state.statusStock, grupCode: state.grupCode))
                  Expanded(
                    child: BtnWidget(bgColor: red, title: greeting("reset"), onPressed: () => _resetFilter()),
                  ),
                Expanded(
                  child: BtnWidget(gradient: linearGradient, title: greeting("apply"), onPressed: () => _onCallback()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemGroups(List<ItemGroup> itemGroup) {
    return Expanded(
      child: ListView.separated(
        controller: _scrollController,
        itemCount: itemGroup.length,
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (index == itemGroup.length) {
            return const LoadingPageWidget();
          }

          final group = itemGroup[index];
          return ListTileSelected(
            group: group,
            onSelected: () => _cubit.selectedGroupCode(group.code),
            isSelected: _cubit.state.grupCode?.contains(group.code) ?? false,
          );
        },
        separatorBuilder: (context, index) => const Hr(width: double.infinity),
      ),
    );
  }
}
