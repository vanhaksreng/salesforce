import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_btn_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/auth/presentation/pages/forget_password/forget_password_cubit.dart';
import 'package:salesforce/features/auth/presentation/pages/forget_password/forget_password_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});
  static const String routeName = "forgetPasswordd";

  @override
  ForgetPasswordScreenState createState() => ForgetPasswordScreenState();
}

class ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _cubit = ForgetPasswordCubit();

  @override
  void initState() {
    _cubit.getCompanyInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF59A5F5), Color(0xFFF5F5F5), Color(0xFFF5F5F5)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<ForgetPasswordCubit, ForgetPasswordState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.isLoading) {
              return LoadingPageWidget();
            }

            return ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: ImageNetWorkWidget(
                    imageUrl: state.company?.logo128 ?? "",
                    height: 200,
                    width: 250,
                    isSide: true,
                    sideWidth: 2,
                  ),
                ),
                Helpers.gapH(30),
                buildContent(),
                // buildForm(state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(16)),
      child: Column(
        spacing: scaleFontSize(8),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: greeting("OTP Verification"),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          TextWidget(
            text: greeting(
              "We’re sending you a one-time password (OTP) to verify your phone number: ${000975757575}",
            ),
            color: textColor50,
          ),
          Helpers.gapH(20),
          pinputField(),
          Helpers.gapH(16),
          buildfooter(),
          Helpers.gapH(16),
          BtnWidget(
            onPressed: () {},
            title: greeting("Verify"),
            gradient: linearGradient,
          ),
        ],
      ),
    );
  }

  Widget pinputField() {
    final defaultPinTheme = PinTheme(
      width: scaleFontSize(50),
      height: scaleFontSize(50),
      textStyle: TextStyle(
        fontSize: 20,
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: primary),
        borderRadius: BorderRadius.circular(scaleFontSize(8)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: primary),
      borderRadius: BorderRadius.circular(scaleFontSize(8)),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(color: primary20),
    );
    return Align(
      alignment: Alignment.center,
      child: Column(
        spacing: scaleFontSize(16),
        children: [
          TextWidget(
            text: greeting("Enter your 6-digit code here"),
            color: textColor50,
          ),
          Pinput(
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            length: 6,
            submittedPinTheme: submittedPinTheme,
            validator: (s) {
              return s == '2222' ? null : 'Pin is incorrect';
            },
            pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            showCursor: true,
            // onCompleted: (pin) => print(pin),
          ),
        ],
      ),
    );
  }

  Widget buildfooter() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: scaleFontSize(16),
        children: [
          TextWidget(
            text: greeting("I didn't receive a code!"),
            color: textColor50,
          ),
          TextBtnWidget(
            onTap: () {},
            titleBtn: greeting("Resent code"),
            fontWeight: FontWeight.w500,
            colorBtn: primary,
          ),
        ],
      ),
    );
  }

  // Widget buildBody(ForgetPasswordState state) {
  //   return ListView(children: [const Text("Forget Password Screen")]);
  // }
}
