import 'package:flutter/material.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class EmptyScreen extends StatefulWidget {
  const EmptyScreen({super.key});

  @override
  State<EmptyScreen> createState() => _EmptyScreenState();
}

class _EmptyScreenState extends State<EmptyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.scale),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextWidget(
                    text: greeting("Ooop!"),
                    wordSpacing: 1,
                    color: mainColor50,
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                  ),

                  Helpers.gapH(16.scale),

                  Container(
                    constraints: BoxConstraints(maxWidth: 320.scale),
                    child: TextWidget(
                      textAlign: TextAlign.center,
                      text: greeting(
                        'Nothing to see here yet.\nTry adding some items or check back later!',
                      ),
                      color: mainColor50.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 1.7,
                    ),
                  ),
                  // Helpers.gapH(32.scale),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: List.generate(
                  //     5,
                  //     (index) => AnimatedContainer(
                  //       duration: Duration(milliseconds: 300 + (index * 100)),
                  //       margin: EdgeInsets.symmetric(horizontal: 3.scale),
                  //       width: index == 2 ? 10.scale : 6.scale,
                  //       height: index == 2 ? 10.scale : 6.scale,
                  //       decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         color: mainColor50.withValues(
                  //           alpha: index == 2 ? 0.4 : 0.2,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Minimal version - even simpler
class EmptyScreenMinimal extends StatefulWidget {
  const EmptyScreenMinimal({super.key});

  @override
  State<EmptyScreenMinimal> createState() => _EmptyScreenMinimalState();
}

class _EmptyScreenMinimalState extends State<EmptyScreenMinimal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _animation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 48.scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Simple gradient background
              Container(
                height: 4.scale,
                width: 60.scale,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.scale),
                  gradient: LinearGradient(
                    colors: [
                      mainColor50.withValues(alpha: 0.3),
                      mainColor50.withValues(alpha: 0.6),
                      mainColor50.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
              Helpers.gapH(32.scale),

              TextWidget(
                text: greeting("Ooop!"),
                wordSpacing: 1,
                color: mainColor50,
                fontSize: 38,
                fontWeight: FontWeight.w700,
              ),
              Helpers.gapH(16.scale),

              Container(
                constraints: BoxConstraints(maxWidth: 300.scale),
                child: TextWidget(
                  textAlign: TextAlign.center,
                  text: greeting(
                    'Nothing to see here yet.\nTry adding some items or check back later!',
                  ),
                  color: mainColor50.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              Helpers.gapH(32.scale),

              Container(
                height: 4.scale,
                width: 60.scale,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.scale),
                  gradient: LinearGradient(
                    colors: [
                      mainColor50.withValues(alpha: 0.3),
                      mainColor50.withValues(alpha: 0.6),
                      mainColor50.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
