import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';

import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class LoadingPageWidget extends StatelessWidget {
  final String label;
  final Color color;
  final double size;
  final bool showLabel;
  final String imagePath;
  final double imageSize;
  final LoadingType loadingType;

  const LoadingPageWidget({
    super.key,
    this.label = "loading",
    this.color = mainColor,
    this.size = 45.0,
    this.showLabel = true,
    this.imagePath = blueTechnologyImgLoading,
    this.imageSize = 30.0,
    this.loadingType = LoadingType.imageWithRing,
  });

  @override
  Widget build(BuildContext context) {
    Widget indicator;

    switch (loadingType) {
      case LoadingType.image:
        indicator = _RotatingImage(size: size, imagePath: imagePath);
        break;
      case LoadingType.imageWithRing:
        indicator = _ImageWithRing(
          size: size,
          imagePath: imagePath,
          color: color,
          imageSize: imageSize,
        );
        break;
      case LoadingType.pulse:
        indicator = _PulsingImage(size: size, imagePath: imagePath);
        break;
      case LoadingType.circular:
        indicator = _CircularLoading(size: size, color: color);
        break;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          if (showLabel) ...[
            Helpers.gapH(10),
            TextWidget(
              text: greeting(label),
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ],
        ],
      ),
    );
  }
}

/// ---------------------- Circular ----------------------
class _CircularLoading extends StatelessWidget {
  final double size;
  final Color color;
  const _CircularLoading({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: 3.0, color: color),
    );
  }
}

/// ---------------------- Rotating Image ----------------------
class _RotatingImage extends StatelessWidget {
  final double size;
  final String imagePath;
  const _RotatingImage({required this.size, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 2 * 3.14159),
      duration: const Duration(seconds: 2),
      builder: (context, angle, child) {
        return Transform.rotate(angle: angle, child: child);
      },
      onEnd: () {}, // auto repeats by using AnimatedBuilder + vsync optional
      child: ClipOval(
        child: Image.asset(
          imagePath,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// ---------------------- Pulsing Image ----------------------
class _PulsingImage extends StatefulWidget {
  final double size;
  final String imagePath;
  const _PulsingImage({required this.size, required this.imagePath});

  @override
  State<_PulsingImage> createState() => _PulsingImageState();
}

class _PulsingImageState extends State<_PulsingImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);
  late final Animation<double> _animation = Tween(
    begin: 0.8,
    end: 1.2,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) =>
          Transform.scale(scale: _animation.value, child: child),
      child: ClipOval(
        child: Image.asset(
          widget.imagePath,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// ---------------------- Image With Ring ----------------------
class _ImageWithRing extends StatefulWidget {
  final double size;
  final String imagePath;
  final Color color;
  final double imageSize;

  const _ImageWithRing({
    required this.size,
    required this.imagePath,
    required this.color,
    required this.imageSize,
  });

  @override
  State<_ImageWithRing> createState() => _ImageWithRingState();
}

class _ImageWithRingState extends State<_ImageWithRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();
  late final Animation<double> _rotation = Tween<double>(
    begin: 0,
    end: 2 * 3.14159,
  ).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotation,
      builder: (_, child) {
        return SizedBox(
          width: scaleFontSize(widget.size),
          height: scaleFontSize(widget.size),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: _rotation.value,
                child: SizedBox(
                  width: scaleFontSize(widget.size),
                  height: scaleFontSize(widget.size),
                  child: CircularProgressIndicator(
                    strokeWidth: scaleFontSize(3),
                    color: widget.color,
                    backgroundColor: widget.color.withValues(alpha: 0.2),
                  ),
                ),
              ),
              ClipOval(
                child: Image.asset(
                  widget.imagePath,
                  width: scaleFontSize(widget.imageSize),
                  height: scaleFontSize(widget.imageSize),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
