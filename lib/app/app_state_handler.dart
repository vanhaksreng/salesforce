import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/presentation/widgets/empty_screen.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/no_internet_widget.dart';

class AppStateHandler extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<dynamic>? records;
  final Widget Function() onData;
  final VoidCallback? onRetry;

  const AppStateHandler({
    super.key,
    required this.isLoading,
    required this.error,
    required this.records,
    required this.onData,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingPageWidget();
    }

    if (error == errorInternetMessage) {
      return NoInternetScreen(onRetry: onRetry ?? () {});
    }

    if ((records == null || records!.isEmpty)) {
      return const EmptyScreen();
    }

    return onData();
  }
}
