import 'package:flutter/material.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class ListTileSelected extends StatelessWidget {
  const ListTileSelected({super.key, required this.group, required this.onSelected, required this.isSelected});

  final ItemGroup group;
  final VoidCallback onSelected;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        dense: true,
        hoverColor: secondary.withValues(alpha: .1),
        splashColor: secondary.withValues(alpha: .2),
        focusColor: secondary.withValues(alpha: .1),
        selected: isSelected,
        selectedTileColor: primary.withValues(alpha: .1),
        trailing: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isSelected ? Icons.check_circle_rounded : null,
            key: ValueKey(isSelected),
            color: isSelected ? primary : Colors.grey,
          ),
        ),
        onTap: onSelected,
        title: TextWidget(text: group.description ?? "", fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal),
        subtitle: showDescription2(),
      ),
    );
  }

  showDescription2() {
    if (group.description2?.isNotEmpty == true) {
      return TextWidget(text: group.description2!, fontSize: 13, color: textColor50);
    }
    null;
  }
}
