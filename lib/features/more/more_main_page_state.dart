part of 'more_main_page_cubit.dart';

class MoreMainPageState {
  final bool isLoading;
  final bool isSelectAll;
  final bool refresh;
  final List<AppSyncLog>? records;
  final List<MoreModel> listMenus;
  final User? auth;

  MoreMainPageState({
    this.isLoading = false,
    this.isSelectAll = false,
    this.refresh = true,
    this.records,
    this.listMenus = const [],
    this.auth,
  });

  MoreMainPageState copyWith({
    bool? isLoading,
    bool? isSelectAll,
    bool? refresh,
    List<AppSyncLog>? records,
    List<MoreModel>? listMenus,
    User? auth,
  }) {
    return MoreMainPageState(
      isLoading: isLoading ?? this.isLoading,
      isSelectAll: isSelectAll ?? this.isSelectAll,
      refresh: refresh ?? this.refresh,
      records: records ?? this.records,
      listMenus: listMenus ?? this.listMenus,
      auth: auth ?? this.auth,
    );
  }
}
