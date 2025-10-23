import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/auth/domain/entities/user.dart';
import 'package:salesforce/features/auth/domain/repositories/auth_repository.dart';
import 'package:salesforce/features/more/domain/entities/menu_data.dart';
import 'package:salesforce/features/more/domain/entities/more_model.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

part 'more_main_page_state.dart';

class MoreMainPageCubit extends Cubit<MoreMainPageState> with MessageMixin {
  MoreMainPageCubit() : super(MoreMainPageState(isLoading: true));

  final _authRepo = getIt<AuthRepository>();

  final MenuData menus = MenuData();

  Future<void> getMenus(bool isLoading) async {
    emit(
      state.copyWith(
        listMenus: await menus.getListMenus(),
        isLoading: isLoading,
      ),
    );
  }

  void getInitData() {
    final User? user = getAuth();
    emit(state.copyWith(auth: user));
  }

  Future<bool> logout() async {
    try {
      return await _authRepo.logout();
    } catch (e) {
      return false;
    }
  }
}
