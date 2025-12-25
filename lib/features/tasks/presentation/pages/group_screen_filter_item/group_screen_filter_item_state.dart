part of 'group_screen_filter_item_cubit.dart';

class GroupScreenFilterItemState {
  final bool isLoading;
  final bool isFetching;
  final List<String>? grupCode;
  final String? lastSelectedCode;
  final List<ItemGroup>? itemsGroup;
  final int currentPage;
  final String statusStock;

  const GroupScreenFilterItemState({
    this.isLoading = false,
    this.isFetching = false,
    this.itemsGroup,
    this.grupCode,
    this.currentPage = 1,
    this.lastSelectedCode,
    this.statusStock = "",
  });

  GroupScreenFilterItemState copyWith({
    bool? isLoading,
    bool? isFetching,
    List<ItemGroup>? itemsGroup,
    String? lastSelectedCode,
    List<String>? grupCode,
    int? currentPage,
    String? statusStock,
  }) {
    return GroupScreenFilterItemState(
      isLoading: isLoading ?? this.isLoading,
      itemsGroup: itemsGroup ?? this.itemsGroup,
      isFetching: isFetching ?? this.isFetching,
      grupCode: grupCode ?? this.grupCode,
      currentPage: currentPage ?? this.currentPage,
      lastSelectedCode: lastSelectedCode ?? this.lastSelectedCode,
      statusStock: statusStock ?? this.statusStock,
    );
  }
}
