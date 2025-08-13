import 'package:flutter/material.dart';

class LoadingPageWidget extends StatelessWidget {
  const LoadingPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
