import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/presentation/pages/task_component/build_customer_address.dart';
import 'package:salesforce/core/presentation/widgets/header_bottom_sheet.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class ChooseAddressCustomer extends StatelessWidget {
  ChooseAddressCustomer({super.key, required this.cusAddress, required this.getAddress, this.getValue = ""});

  final List<CustomerAddress> cusAddress;
  final Function(CustomerAddress address) getAddress;
  final String getValue;
  final ValueNotifier<String> address = ValueNotifier("");

  @override
  Widget build(BuildContext context) {
    address.value = getValue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: scaleFontSize(appSpace),
      children: [
        const HeaderBottomSheet(
          childWidget: TextWidget(
            text: "Let's select one customer Address.",
            fontSize: 14,
            color: white,
            fontWeight: FontWeight.bold,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: address,
          builder: (context, result, child) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(cusAddress.length, (int index) {
                  final address = cusAddress[index];
                  return BuildCustomerBoxAddress(
                    isSelected: result == address.id,
                    onTap: () {
                      Navigator.pop(context);
                      getAddress(address);
                    },
                    csAddress: cusAddress[index],
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }
}
