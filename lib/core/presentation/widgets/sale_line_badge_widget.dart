import 'package:flutter/material.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class SaleLineBadge extends StatelessWidget {
  const SaleLineBadge({
    super.key,
    required this.item,
    required this.onTap,
    this.isSelected = false,
  });

  final ItemSalesLinePrices item;
  final bool isSelected;
  final VoidCallback onTap;

  String _saleLineDescription() {
    String sCode = item.salesCode ?? "";

    if (sCode.isNotEmpty) {
      return sCode;
    }

    return item.salesType ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: scaleFontSize(12),
          vertical: scaleFontSize(8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? primary.withValues(alpha: 0.12) : Colors.white,
          border: Border.all(
            color: isSelected ? primary : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(scaleFontSize(10)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: scaleFontSize(110),
              child: Text(
                _saleLineDescription(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: scaleFontSize(12),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? primary : Colors.black87,
                ),
              ),
            ),
            SizedBox(height: scaleFontSize(4)),
            Text(
              "${Helpers.formatNumber(item.unitPrice, option: FormatType.price)} / ${item.uomCode}",
              style: TextStyle(
                fontSize: scaleFontSize(13),
                fontWeight: FontWeight.bold,
                color: isSelected ? primary : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
