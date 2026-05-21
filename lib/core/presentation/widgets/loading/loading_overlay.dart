import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salesforce/core/presentation/widgets/loading/loader_screen.dart';

class LoadingOverlay {
  BuildContext _context;

  final ValueNotifier<_LoadingOverlayState> _state = ValueNotifier(
    const _LoadingOverlayState(
      progress: 0.0,
      displayText: '',
      message: '',
    ),
  );

  bool _isVisible = false;

  LoadingOverlay._create(this._context);

  Future<void> hide() async {
    if (_isVisible) {
      _isVisible = false;
      Navigator.of(_context).pop();
    }
  }

  Future<void> show({double progress = 0, String message = "Loading..."}) async {
    final updatedState = _state.value.copyWith(
      progress: progress,
      displayText: "System will donwload only related data.",
      message: message,
    );

    _state.value = updatedState;

    if (_isVisible) {
      return;
    }

    _isVisible = true;
    await showDialog(
      context: _context,
      barrierDismissible: false,
      builder: (ctx) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Color.fromARGB(0, 0, 0, 0),
        ),
        sized: false,
        child: ValueListenableBuilder<_LoadingOverlayState>(
          valueListenable: _state,
          builder: (context, value, child) {
            return LoaderScreen(
              progress: value.progress,
              displayText: value.displayText,
              message: value.message,
            );
          },
        ),
      ),
    );
    _isVisible = false;
  }

  void updateProgress(double progress, {String text = ""}) {
    _state.value = _state.value.copyWith(
      progress: progress,
      displayText: text,
      message: text,
    );
  }

  Future<T> during<T>(Future<T> future) {
    show();
    return future.whenComplete(() => hide());
  }

  factory LoadingOverlay.of(BuildContext context) {
    return LoadingOverlay._create(context);
  }
}

class _LoadingOverlayState {
  final double progress;
  final String displayText;
  final String message;

  const _LoadingOverlayState({
    required this.progress,
    required this.displayText,
    required this.message,
  });

  _LoadingOverlayState copyWith({
    double? progress,
    String? displayText,
    String? message,
  }) {
    return _LoadingOverlayState(
      progress: progress ?? this.progress,
      displayText: displayText ?? this.displayText,
      message: message ?? this.message,
    );
  }
}
