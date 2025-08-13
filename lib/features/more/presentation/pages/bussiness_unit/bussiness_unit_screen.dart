import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';

class BussinessUnitScreen extends StatefulWidget {
  const BussinessUnitScreen({super.key});
  static const routeName = "bussinessUnitScreen";

  @override
  State<BussinessUnitScreen> createState() => _BussinessUnitScreenState();
}

class _BussinessUnitScreenState extends State<BussinessUnitScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting("business_unit"),
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
