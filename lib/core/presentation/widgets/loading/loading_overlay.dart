import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salesforce/core/presentation/widgets/loading/loader_screen.dart';

class LoadingOverlay {
  BuildContext _context;

  final ValueNotifier<double> _progress = ValueNotifier(0.0);

  late String _displayText;

  LoadingOverlay._create(this._context);

  Future<void> hide() async {
    Navigator.of(_context).pop();
  }

  Future<void> show([double progress = 0]) async {
    _progress.value = progress;
    _displayText = "System will donwload only related data.";

    showDialog(
      context: _context,
      barrierDismissible: false,
      builder: (ctx) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(statusBarColor: Color.fromARGB(0, 0, 0, 0)),
        sized: false,
        child: ValueListenableBuilder<double>(
          valueListenable: _progress,
          builder: (context, value, child) {
            return LoaderScreen(progress: value, displayText: _displayText);
          },
        ),
      ),
    );
  }

  void updateProgress(double progress, {String text = ""}) {
    _progress.value = progress;
    _displayText = text;
  }

  Future<T> during<T>(Future<T> future) {
    show();
    return future.whenComplete(() => hide());
  }

  factory LoadingOverlay.of(BuildContext context) {
    return LoadingOverlay._create(context);
  }
}
