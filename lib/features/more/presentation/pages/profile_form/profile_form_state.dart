import 'package:image_picker/image_picker.dart';

class ProfileFormState {
  final bool isLoading;
  final String? error;
  final XFile? imgPath;

  const ProfileFormState({
    this.isLoading = false,
    this.error,
    this.imgPath,
  });

  ProfileFormState copyWith({
    bool? isLoading,
    String? error,
    XFile? imgPath,
  }) {
    return ProfileFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      imgPath: imgPath ?? this.imgPath,
    );
  }
}
