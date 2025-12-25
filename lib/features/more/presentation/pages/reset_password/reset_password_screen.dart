import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/text_form_field_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/presentation/pages/reset_password/reset_password_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/reset_password/reset_password_state.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  static const routeName = "resetPasswordScreen";

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _cubit = ResetPasswordCubit();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBarWidget(title: greeting("reset_password")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(appSpace),
          child: BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
            bloc: _cubit,
            builder: (context, state) {
              return Column(
                children: [
                  TextFormFieldWidget(
                    label: greeting("current_password"),
                    filled: true,
                    fillColor: white,
                    controller: _currentPasswordController,
                    isDefaultTextForm: true,
                    obscureText: state.isCurrentObscure,
                    suffixIcon: IconButton(
                      onPressed: _cubit.toggleCurrent,
                      icon: Icon(state.isCurrentObscure ? Icons.visibility_off : Icons.remove_red_eye_sharp),
                    ),
                  ),
                  Helpers.gapH(25),
                  TextFormFieldWidget(
                    label: greeting("new_password"),
                    filled: true,
                    fillColor: white,
                    controller: _newPasswordController,
                    isDefaultTextForm: true,
                    obscureText: state.isNewObscure,
                    suffixIcon: IconButton(
                      onPressed: _cubit.toggleNew,
                      icon: Icon(state.isNewObscure ? Icons.visibility_off : Icons.remove_red_eye_sharp),
                    ),
                  ),
                  Helpers.gapH(25),
                  TextFormFieldWidget(
                    label: greeting("confirm_password"),
                    filled: true,
                    fillColor: white,
                    controller: _confirmPasswordController,
                    isDefaultTextForm: true,
                    obscureText: state.isConfirmObscure,
                    suffixIcon: IconButton(
                      onPressed: _cubit.toggleConfirm,
                      icon: Icon(state.isConfirmObscure ? Icons.visibility_off : Icons.remove_red_eye_sharp),
                    ),
                  ),
                  Helpers.gapH(25),
                  BtnWidget(
                    onPressed: () {
                      if (_currentPasswordController.text.isEmpty ||
                          _newPasswordController.text.isEmpty ||
                          _confirmPasswordController.text.isEmpty) {
                        Helpers.showMessage(msg: greeting("please_fill_all_fields"), status: MessageStatus.errors);
                        return;
                      }

                      final l = LoadingOverlay.of(context);

                      _cubit.isMatchingPassword(
                        _newPasswordController.text.toString(),
                        _confirmPasswordController.text.toString(),
                      );

                      if (_cubit.state.isMatchingPassword) {
                        l.show();

                        _cubit.resetPassword(
                          params: {
                            "password": _currentPasswordController.text.toString(),
                            "new_password": _confirmPasswordController.text.toString(),
                          },
                        );
                        if (_cubit.state.resetPasswordSuccess || !_cubit.state.loading) {
                          l.hide();
                        }
                      }
                    },
                    title: greeting("confirm_password_change"),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
