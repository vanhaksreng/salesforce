import 'package:salesforce/features/tasks/domain/entities/app_version.dart';

class AboutState {
  final bool isLoading;
  final String? error;
  final AppVersion? appVersion;

  const AboutState({this.isLoading = false, this.error, this.appVersion});

  AboutState copyWith({
    bool? isLoading,
    String? error,
    AppVersion? appVersion,
  }) {
    return AboutState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}
