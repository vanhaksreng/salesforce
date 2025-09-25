import 'package:image_picker/image_picker.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';

class ProfileFormState {
  final bool isLoading;
  final String? error;
  final XFile? imgPath;
  final UserSetup? user;

  const ProfileFormState({
    this.isLoading = false,
    this.error,
    this.imgPath,
    this.user,
  });

  ProfileFormState copyWith({
    bool? isLoading,
    String? error,
    XFile? imgPath,
    UserSetup? user,
  }) {
    return ProfileFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      imgPath: imgPath ?? this.imgPath,
      user: user ?? this.user,
    );
  }
}
