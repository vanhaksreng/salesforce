import 'package:flutter/material.dart';
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

  SpeedDialChild({required this.icon, required this.onTap});
}

class _CustomSpeedDialState extends State<CustomSpeedDial> with SingleTickerProviderStateMixin {
  final GlobalKey _fabKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
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
    final RenderBox fabRenderBox = _fabKey.currentContext!.findRenderObject() as RenderBox;
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
                  left: fabPosition.dx,
                  top: fabPosition.dy - (widget.children.length * 60.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.children.map((child) => _buildChildFab(child.icon, child.onTap)).toList(),
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

  Widget _buildChildFab(IconData icon, VoidCallback onTap) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: SizedBox(
          width: 45.scale,
          height: 45.scale,
          child: FloatingActionButton(
            backgroundColor: mainColor50,
            heroTag: null,
            // mini: true,
            onPressed: () {
              onTap();
              _toggleDial();
            },
            child: Icon(icon),
          ),
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
          child: Icon(_isOpen ? Icons.close : Icons.location_on_rounded),
        ),
      ),
    );
  }
}
