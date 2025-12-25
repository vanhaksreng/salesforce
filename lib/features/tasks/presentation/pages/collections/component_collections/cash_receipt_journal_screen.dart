import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/presentation/pages/collections/component_collections/row_title.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class CashReceiptJournalScreen extends StatelessWidget {
  const CashReceiptJournalScreen({
    super.key,
    this.onPressed,
    required this.cashReJournals,
    required this.paymentMethods,
  });

  final List<CashReceiptJournals> cashReJournals;
  final List<PaymentMethod> paymentMethods;
  final void Function(CashReceiptJournals)? onPressed;

  Color _getBageBgColor(String status) {
    if (status == kStatusOpen) {
      return const Color.fromARGB(130, 0, 123, 255);
    }

    return const Color.fromARGB(224, 91, 173, 111);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: cashReJournals.length,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final mathchList = cashReJournals[index];
        PaymentMethod? paymentMethod;
        final pIndex = paymentMethods.indexWhere((e) => e.code == mathchList.paymentMethodCode);
        if (pIndex != -1) {
          paymentMethod = paymentMethods[pIndex];
        }

        return Container(
          key: ValueKey(mathchList.id),
          padding: EdgeInsets.all(12.scale),
          decoration: BoxDecoration(
            color: mathchList.status == "Open" ? primary.withAlpha(50) : success.withAlpha(50),
            borderRadius: const BorderRadius.all(appRounding),
            border: Border(
              left: BorderSide(width: 4.scale, color: mathchList.status == "Open" ? primary : success),
            ),
          ),
          child: Stack(
            key: ValueKey(mathchList.id),
            clipBehavior: Clip.none,
            children: [
              Column(
                key: ValueKey(mathchList.id),
                spacing: 12.scale,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        fontWeight: FontWeight.bold,
                        text: DateTimeExt.parse(mathchList.documentDate).toDateNameString(),
                        fontSize: 14.scale,
                      ),
                      if (mathchList.status != kStatusOpen || onPressed == null)
                        ChipWidget(
                          label: mathchList.status ?? "",
                          fontWeight: FontWeight.bold,
                          fontSize: 10.scale,
                          colorText: white,
                          radius: 15.scale,
                          bgColor: _getBageBgColor(mathchList.status ?? "Open"),
                        ),
                    ],
                  ),
                  rowCollectionTitle(
                    key: "Receive Amount".toUpperCase(),
                    value: Helpers.formatNumber(mathchList.amount, option: FormatType.amount),
                    key2: "Payment Method".toUpperCase(),
                    value2: paymentMethod == null
                        ? mathchList.paymentMethodCode ?? ""
                        : paymentMethod.description ?? "",
                    fontSize: 14,
                  ),
                ],
              ),
              if (mathchList.status == kStatusOpen && onPressed != null)
                Positioned(
                  top: -18.scale,
                  right: -18.scale,
                  child: BtnIconCircleWidget(
                    bgColor: red,
                    onPressed: () {
                      if (onPressed != null) {
                        onPressed?.call(mathchList);
                      }
                    },
                    icons: Icon(Icons.remove, size: 18.scale, color: white),
                  ),
                ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(height: 8.scale);
      },
    );
  }
}
