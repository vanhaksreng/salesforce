import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/features/more/domain/entities/user_info.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/profile_form/profile_form_state.dart';
import 'package:salesforce/injection_container.dart';

class ProfileFormCubit extends Cubit<ProfileFormState> with MessageMixin {
  ProfileFormCubit() : super(const ProfileFormState(isLoading: false));
  final _repos = getIt<MoreRepository>();

  Future<void> updateProfileUser(UserInfo user) async {
    try {
      await _repos.updateProfileUser(user);
    } catch (error) {
      showErrorMessage(error.toString());
    }
  }

  void getImage(XFile? imgPath) {
    emit(state.copyWith(imgPath: imgPath));
  }
}
