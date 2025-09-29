import 'package:flutter/material.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

class LoaderScreen extends StatefulWidget {
  const LoaderScreen({
    super.key,
    this.progress = 0.0,
    this.displayText = "Please wait..",
  });

  final double progress;
  final String displayText;

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      body: PopScope(
        canPop: false,
        child: Container(
          alignment: Alignment.center,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _getBody(widget.progress),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getBody(double progress) {
    if (progress > 0) {
      return Container(
        width: SizeConfig.screenWidth * 0.85,
        padding: EdgeInsets.all(24.scale),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.scale),
          color: white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.scale,
                  height: 40.scale,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primary, primary.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12.scale),
                  ),
                  child: Icon(
                    Icons.cloud_download_outlined,
                    color: white,
                    size: 20.scale,
                  ),
                ),
                Helpers.gapW(12.scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: widget.displayText,
                        color: primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      Helpers.gapH(4.scale),
                      TextWidget(
                        text: "${progress.toInt()}% complete",
                        color: grey.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Helpers.gapH(20.scale),
            _buildProgressBar(),
          ],
        ),
      );
    }

    return _buildLoadingText();
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.scale),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 8.scale,
                decoration: BoxDecoration(
                  color: grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.scale),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width:
                    (SizeConfig.screenWidth * 0.85 - 48.scale) *
                    (widget.progress / 100).clamp(0.0, 1.0),
                height: 8.scale,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12.scale),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingText() {
    return Container(
      width: 180.scale,
      height: 180.scale,
      padding: EdgeInsets.symmetric(vertical: 32.scale, horizontal: 24.scale),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24.scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LoadingPageWidget(label: "Processing..."),
    );
  }
}

class LoaderScreenModern extends StatefulWidget {
  const LoaderScreenModern({
    super.key,
    this.progress = 0.0,
    this.displayText = "Please wait..",
  });

  final double progress;
  final String displayText;

  @override
  State<LoaderScreenModern> createState() => _LoaderScreenModernState();
}

class _LoaderScreenModernState extends State<LoaderScreenModern>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black.withValues(alpha: 0.6),
      body: PopScope(
        canPop: false,
        child: Container(
          alignment: Alignment.center,
          child: FadeTransition(
            opacity: _controller,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
              ),
              child: widget.progress > 0
                  ? _buildProgressCard()
                  : _buildLoadingCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      width: SizeConfig.screenWidth * 0.85,
      padding: EdgeInsets.all(28.scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.scale),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [white, white.withValues(alpha: 0.95)],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextWidget(
            text: widget.displayText,
            color: primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: 24.scale),
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 12.scale,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20.scale),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width:
                    (SizeConfig.screenWidth * 0.85 - 56.scale) *
                    (widget.progress / 100).clamp(0.0, 1.0),
                height: 12.scale,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(20.scale),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.scale),
          TextWidget(
            text: "${widget.progress.toInt()}%",
            color: primary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: 200.scale,
      padding: EdgeInsets.all(36.scale),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(28.scale),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60.scale,
            height: 60.scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary.withValues(alpha: 0.15),
                  primary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 36.scale,
                height: 36.scale,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.scale),
          const TextWidget(
            text: "Processing",
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: primary,
          ),
          SizedBox(height: 8.scale),
          TextWidget(
            text: "Hold on tight...",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: grey.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}
