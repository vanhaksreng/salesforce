import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/list_tile_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/search_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/presentation/pages/payment_screen/payment_screen_cubit.dart';
import 'package:salesforce/features/tasks/presentation/pages/payment_screen/payment_screen_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class PaymentScreenScreen extends StatefulWidget {
  const PaymentScreenScreen({Key? key, required this.paymentCode}) : super(key: key);
  static const String routeName = "paymentScreen";
  final String paymentCode;

  @override
  PaymentScreenScreenState createState() => PaymentScreenScreenState();
}

class PaymentScreenScreenState extends State<PaymentScreenScreen> {
  final _cubit = PaymentScreenDartCubit();
  late String selectedCode;

  @override
  void initState() {
    super.initState();
    _cubit.selectedPayment(widget.paymentCode);
    _cubit.getPaymentType();
  }

  void _onSelectedCode(PaymentMethod payments) {
    Navigator.pop(context, payments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: greeting("payment_type"),
        bottom: const SearchWidget(),
        heightBottom: heightBottomSearch,
      ),
      // backgroundColor: white,
      body: BlocBuilder<PaymentScreenDartCubit, PaymentScreenState>(
        bloc: _cubit,
        builder: (context, state) {
          return buildBody(state);
        },
      ),
    );
  }

  Widget buildBody(PaymentScreenState state) {
    return Padding(
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      child: Column(
        spacing: 8.scale,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(text: "${state.paymentMethods.length} Items"),
          _buildItemGroups(state),
        ],
      ),
    );
  }

  Widget _buildItemGroups(PaymentScreenState state) {
    final paymentMethods = state.paymentMethods;
    return Expanded(
      child: ListView.separated(
        itemCount: paymentMethods.length,
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (index == paymentMethods.length) {
            return const LoadingPageWidget();
          }

          final paymentType = paymentMethods[index];
          return ListTitleWidget(
            key: ValueKey(paymentType.code),
            label: paymentType.description ?? "",
            subTitle: paymentType.code,
            type: ListTileType.trailingSelect,
            onTap: () => _onSelectedCode(paymentType),
            fontWeight: FontWeight.normal,
            isSelected: state.codePayment == paymentType.code,
          );
        },
        separatorBuilder: (context, index) => Padding(
          key: ValueKey(index),
          padding: const EdgeInsets.symmetric(horizontal: appSpace8),
          child: Hr(key: ValueKey(index), width: double.infinity),
        ),
      ),
    );
  }
}
