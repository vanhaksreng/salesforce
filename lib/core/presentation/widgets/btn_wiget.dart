import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/theme/app_colors.dart';

enum BtnVariant { primary, secondary, outline, ghost, destructive }

enum BtnSize { xs, small, medium, large }

class BtnWidget extends StatefulWidget {
  const BtnWidget({
    super.key,
    this.title = "",
    this.extendTitle = "",
    required this.onPressed,
    this.height,
    this.fntSize,
    this.horizontal = 0,
    this.vertical = 0,
    this.width = double.infinity,
    this.isLoading = false,
    this.isDisabled = false,
    this.bgColor,
    this.textColor,
    this.icon,
    this.suffixIcon,
    this.radius,
    this.variant = BtnVariant.primary,
    this.size = BtnSize.medium,
    this.enableHapticFeedback = true,
    this.enableRipple = true,
    this.elevation = 0,
    this.borderWidth = 1.5,
    this.borderColor,
    this.gradient,
    this.shadowColor,
    this.loadingText,
  });

  final String title;
  final String extendTitle;
  final VoidCallback? onPressed;
  final double? height;
  final double? fntSize;
  final double horizontal;
  final double vertical;
  final double? width;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final Widget? suffixIcon;
  final Color? bgColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? shadowColor;
  final double? radius;
  final double elevation;
  final double borderWidth;
  final BtnVariant variant;
  final BtnSize size;
  final bool enableHapticFeedback;
  final bool enableRipple;
  final Gradient? gradient;
  final String? loadingText;

  @override
  State<BtnWidget> createState() => _BtnWidgetState();
}

class _BtnWidgetState extends State<BtnWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Get button dimensions based on size
  double get _height {
    if (widget.height != null) {
      return scaleFontSize(widget.height!);
    }

    switch (widget.size) {
      case BtnSize.xs:
        return 30.scale;
      case BtnSize.small:
        return 36.scale;
      case BtnSize.medium:
        return 45.scale;
      case BtnSize.large:
        return 56.scale;
    }
  }

  double get _fontSize {
    if (widget.fntSize != null) {
      return widget.fntSize!;
    }

    switch (widget.size) {
      case BtnSize.xs:
        return 10;
      case BtnSize.small:
        return 12;
      case BtnSize.medium:
        return 14;
      case BtnSize.large:
        return 16;
    }
  }

  double get _borderRadius {
    if (widget.radius != null) {
      return scaleFontSize(widget.radius!);
    }

    switch (widget.size) {
      case BtnSize.xs:
        return 2.scale;
      case BtnSize.small:
        return 4.scale;
      case BtnSize.medium:
        return 8.scale;
      case BtnSize.large:
        return 12.scale;
    }
  }

  double get _horizontalPadding {
    switch (widget.size) {
      case BtnSize.xs:
        return 10.scale;
      case BtnSize.small:
        return 12.scale;
      case BtnSize.medium:
        return 16.scale;
      case BtnSize.large:
        return 20.scale;
    }
  }

  // Get colors based on variant and state
  ButtonColors get _colors {
    final isDisabled = widget.isDisabled || widget.onPressed == null;

    switch (widget.variant) {
      case BtnVariant.primary:
        return ButtonColors(
          background: isDisabled ? Colors.grey.shade300 : widget.bgColor ?? secondary,
          text: isDisabled ? Colors.grey.shade500 : widget.textColor ?? white,
          border: isDisabled ? Colors.grey.shade300 : widget.borderColor ?? (widget.bgColor ?? secondary),
        );

      case BtnVariant.secondary:
        return ButtonColors(
          background: isDisabled ? Colors.grey.shade100 : Colors.grey.shade100,
          text: isDisabled ? Colors.grey.shade400 : widget.textColor ?? Colors.grey.shade800,
          border: isDisabled ? Colors.grey.shade200 : widget.borderColor ?? Colors.grey.shade300,
        );

      case BtnVariant.outline:
        return ButtonColors(
          background: isDisabled ? Colors.transparent : Colors.transparent,
          text: isDisabled ? Colors.grey.shade400 : widget.textColor ?? secondary,
          border: isDisabled ? Colors.grey.shade300 : widget.borderColor ?? secondary,
        );

      case BtnVariant.ghost:
        return ButtonColors(
          background: Colors.transparent,
          text: isDisabled ? Colors.grey.shade400 : widget.textColor ?? secondary,
          border: Colors.transparent,
        );

      case BtnVariant.destructive:
        return ButtonColors(
          background: isDisabled ? Colors.grey.shade300 : error,
          text: isDisabled ? Colors.grey.shade500 : white,
          border: isDisabled ? Colors.grey.shade300 : error,
        );
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isDisabled) {
      setState(() => isPressed = true);
      _animationController.forward();

      if (widget.enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    if (mounted) {
      setState(() => isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTap() {
    if (widget.onPressed != null && !widget.isDisabled && !widget.isLoading) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: scaleFontSize(widget.horizontal),
        vertical: scaleFontSize(widget.vertical),
      ),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(height: _height, width: widget.width, child: _buildAndroidBtn()),
          );
        },
      ),
    );
  }

  Widget _buildAndroidBtn() {
    final colors = _colors;
    final isDisabled = widget.isDisabled || widget.onPressed == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.isLoading ? null : _handleTap,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        borderRadius: BorderRadius.circular(_borderRadius),
        splashColor: widget.enableRipple ? colors.text.withValues(alpha: .1) : Colors.transparent,
        highlightColor: widget.enableRipple ? colors.text.withValues(alpha: .05) : Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.gradient != null ? null : colors.background,
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(_borderRadius),
            border: widget.variant == BtnVariant.outline || widget.variant == BtnVariant.secondary
                ? Border.all(color: colors.border, width: widget.borderWidth)
                : null,
            boxShadow: widget.elevation > 0 && !isDisabled
                ? [
                    BoxShadow(
                      color: widget.shadowColor ?? colors.background.withValues(alpha: .3),
                      blurRadius: widget.elevation * 2,
                      offset: Offset(0, widget.elevation),
                    ),
                  ]
                : null,
          ),
          child: _buildContent(colors),
        ),
      ),
    );
  }

  Widget _buildContent(ButtonColors colors) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null && !widget.isLoading) ...[
            IconTheme(
              data: IconThemeData(color: colors.text, size: _fontSize + 2),
              child: widget.icon!,
            ),
            if (widget.title.isNotEmpty) SizedBox(width: 8.scale),
          ],
          if (widget.isLoading) ...[
            SizedBox(
              height: _fontSize,
              width: _fontSize,
              child: CircularProgressIndicator(color: colors.text, strokeWidth: 2),
            ),
            if (widget.loadingText != null || widget.title.isNotEmpty) SizedBox(width: 8.scale),
          ],
          if (widget.title.isNotEmpty || widget.loadingText != null)
            Flexible(
              child: TextWidget(
                text: widget.isLoading && widget.loadingText != null
                    ? greeting(widget.loadingText!)
                    : greeting(widget.title),
                color: colors.text,
                fontSize: _fontSize,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (widget.extendTitle.isNotEmpty && widget.extendTitle != "0") ...[
            SizedBox(width: 8.scale),
            ChipWidget(
              fontSize: (_fontSize - 2).clamp(10, 14),
              horizontal: 6.scale,
              vertical: 2.scale,
              colorText: mainColor,
              borderColor: colors.text.withValues(alpha: .3),
              bgColor: colors.text.withValues(alpha: .1),
              isCircle: true,
              label: greeting(widget.extendTitle),
            ),
          ],
          if (widget.suffixIcon != null && !widget.isLoading) ...[
            if (widget.title.isNotEmpty) SizedBox(width: 8.scale),
            IconTheme(
              data: IconThemeData(color: colors.text, size: _fontSize + 2),
              child: widget.suffixIcon!,
            ),
          ],
        ],
      ),
    );
  }
}

class ButtonColors {
  final Color background;
  final Color text;
  final Color border;

  const ButtonColors({required this.background, required this.text, required this.border});
}

// Usage Examples:
/*
// Primary button
BtnWidget(
  title: "Primary Button",
  onPressed: () {},
  variant: BtnVariant.primary,
  size: BtnSize.medium,
)

// Secondary button with icon
BtnWidget(
  title: "Secondary",
  icon: Icon(Icons.add),
  onPressed: () {},
  variant: BtnVariant.secondary,
)

// Outline button with gradient
BtnWidget(
  title: "Gradient Button",
  onPressed: () {},
  variant: BtnVariant.outline,
  gradient: LinearGradient(
    colors: [Colors.blue, Colors.purple],
  ),
)

// Loading button
BtnWidget(
  title: "Submit",
  loadingText: "Submitting...",
  isLoading: true,
  onPressed: () {},
)

// Small destructive button
BtnWidget(
  title: "Delete",
  onPressed: () {},
  variant: BtnVariant.destructive,
  size: BtnSize.small,
  icon: Icon(Icons.delete),
)

// Ghost button with suffix icon
BtnWidget(
  title: "Learn More",
  suffixIcon: Icon(Icons.arrow_forward),
  onPressed: () {},
  variant: BtnVariant.ghost,
)
*/
