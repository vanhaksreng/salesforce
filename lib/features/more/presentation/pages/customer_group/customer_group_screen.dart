import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';

class CustomerGroupScreen extends StatefulWidget {
  const CustomerGroupScreen({super.key});
  static const routeName = "customerGroupScreen";

  @override
  State<CustomerGroupScreen> createState() => _CustomerGroupScreenState();
}

class _CustomerGroupScreenState extends State<CustomerGroupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting("customer_group"),
        bottom: Padding(
          padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace), vertical: 8.scale),
          child: Row(
            children: [Expanded(child: SearchWidget(onSubmitted: (value) async {}))],
          ),
        ),
        heightBottom: 40,
      ),
    );
  }
}
