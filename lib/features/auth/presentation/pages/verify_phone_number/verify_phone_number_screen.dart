import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_form_field_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/auth/presentation/pages/forget_password/forget_password_screen.dart';
import 'package:salesforce/features/auth/presentation/pages/verify_phone_number/verify_phone_number_cubit.dart';
import 'package:salesforce/features/auth/presentation/pages/verify_phone_number/verify_phone_number_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class VerifyPhoneNumberScreen extends StatefulWidget {
  const VerifyPhoneNumberScreen({super.key});
  static const String routeName = "verifyPhoneNumber";

  @override
  VerifyPhoneNumberScreenState createState() => VerifyPhoneNumberScreenState();
}

class VerifyPhoneNumberScreenState extends State<VerifyPhoneNumberScreen>
    with MessageMixin {
  final _cubit = VerifyPhoneNumberCubit();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    _cubit.getCompanyInfo();
    super.initState();
  }

  Future<void> verifyResetPassword() async {
    final l = LoadingOverlay.of(context);

    try {
      l.show();
      final result = await _cubit.verifyResetPassword({
        "phone_no": phoneController.text,
        "country_code": (_cubit.state.initialSelection ?? "+855").replaceAll(
          "+",
          "",
        ),
        "account_id": "2",
      });
      if (result) {
        l.hide();
        if (!mounted) return;
        Navigator.pushNamed(context, ForgetPasswordScreen.routeName);
        return;
      }
      l.hide();
    } catch (e) {
      l.hide();
      showErrorMessage(e.toString());
    }
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: BlocBuilder<VerifyPhoneNumberCubit, VerifyPhoneNumberState>(
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
                buildContent(state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildContent(VerifyPhoneNumberState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: scaleFontSize(16)),
      child: Column(
        spacing: scaleFontSize(8),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: greeting("Phone Verification"),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          TextWidget(
            text: greeting(
              "Please enter your phone number. We’ll send you a one-time password (OTP) to verify it.",
            ),
            color: textColor50,
          ),
          Helpers.gapH(20),
          phoneField(state),
          Helpers.gapH(20),
          BtnWidget(
            onPressed: () => verifyResetPassword(),
            title: greeting("Continue"),
            gradient: linearGradient,
          ),
        ],
      ),
    );
  }

  Widget phoneField(VerifyPhoneNumberState state) {
    return Row(
      spacing: scaleFontSize(4),
      children: [
        Row(
          children: [
            BoxWidget(
              borderColor: primary20,
              isBorder: true,
              color: white,
              child: Row(
                children: [
                  CountryCodePicker(
                    onChanged: (country) =>
                        _cubit.selectCountry(country.dialCode ?? '+855'),
                    searchDecoration: InputDecoration(
                      hintText: greeting("Search country"),
                      hintStyle: TextStyle(
                        color: textColor50,
                        fontSize: 14.scale,
                      ),
                    ),
                    margin: EdgeInsets.all(4),
                    padding: EdgeInsets.zero,

                    boxDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.scale),
                    ),

                    initialSelection: state.initialSelection,
                    favorite: ['+855', 'KH'],
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: TextFormFieldWidget(
            filled: true,

            controller: phoneController,
            isDefaultTextForm: true,
            label: greeting("Phone Number"),
            hintText: greeting("Enter your phone number"),
            keyboardType: TextInputType.phone,
          ),
        ),
      ],
    );
  }
}
