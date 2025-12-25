import 'package:flutter/material.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/theme/app_colors.dart';

class CustomSpeedDial extends StatefulWidget {
  const CustomSpeedDial({super.key, required this.children});
  final List<SpeedDialChild> children;

  @override
  State<CustomSpeedDial> createState() => _CustomSpeedDialState();
}

class SpeedDialChild {
  final IconData icon;
  final VoidCallback onTap;
  final String label;

  SpeedDialChild({required this.icon, required this.onTap, this.label = ""});
}

class _CustomSpeedDialState extends State<CustomSpeedDial>
    with SingleTickerProviderStateMixin {
  final GlobalKey _fabKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _toggleDial() {
    setState(() {
      _isOpen = !_isOpen;
    });

    if (_isOpen) {
      _animationController.forward();
      _showOverlay();
    } else {
      _animationController.reverse();
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    final RenderBox fabRenderBox =
        _fabKey.currentContext!.findRenderObject() as RenderBox;
    final fabPosition = fabRenderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: _toggleDial,
          child: Material(
            color: textColor.withValues(alpha: .3),
            child: Stack(
              children: [
                Positioned(
                  right:
                      MediaQuery.of(context).size.width -
                      fabPosition.dx -
                      45.scale,
                  top: fabPosition.dy - (widget.children.length * 60.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.children
                        .map(
                          (child) => _buildChildFab(
                            child.icon,
                            child.onTap,
                            label: child.label,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildChildFab(
    IconData icon,
    VoidCallback onTap, {
    required String label,
  }) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Padding(
        padding: EdgeInsets.only(bottom: scaleFontSize(10)),
        child: Row(
          spacing: scaleFontSize(8),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (label.isNotEmpty)
              ChipWidget(
                radius: 6,
                bgColor: mainColor50,
                ishadowColor: true,
                label: label,
              ),

            SizedBox(
              width: 45.scale,
              height: 45.scale,
              child: FloatingActionButton(
                backgroundColor: mainColor50,
                heroTag: null,
                onPressed: () {
                  onTap();
                  _toggleDial();
                },
                child: Icon(icon),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _fabKey,
      child: SizedBox(
        width: 45.scale,
        height: 45.scale,
        child: FloatingActionButton(
          backgroundColor: mainColor,
          onPressed: _toggleDial,
          child: Icon(_isOpen ? Icons.close : Icons.more_vert),
        ),
      ),
    );
  }
}
