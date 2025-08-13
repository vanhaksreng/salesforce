import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/auth/domain/entities/login_arg.dart';
import 'package:salesforce/features/auth/presentation/pages/first_download/first_download_screen.dart';
import 'package:salesforce/features/auth/presentation/pages/login/login_cubit.dart';
import 'package:salesforce/features/auth/presentation/pages/login/login_state.dart';
import 'package:salesforce/features/auth/presentation/pages/starter_screen/starter_screen.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/build_logo_header_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_form_field_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/theme/app_colors.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/constants/app_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = "login";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with MessageMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _cubit = LoginCubit();

  ServerType type = ServerType.shared;
  String selectedUrl = sharedUrl;
  List<AppServer> urls = [];
  final server = GetIt.I<AppServer>();

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  void _initLoad() async {
    if (kDebugMode) {
      if (server.id == "local") {
        nameController.text = "012222222";
      } else if (server.id == "smb") {
        nameController.text = "5555";
      }

      passwordController.text = "123456"; //TODO : will remove on production
    }
  }

  Future<void> login() async {
    if (!await _cubit.isConnectedToNetwork()) {
      showWarningMessage("No internet connection. Please check your network settings.");
      return;
    }

    if (!mounted) return;

    final l = LoadingOverlay.of(context);
    l.show();
    try {
      await _cubit.login(
        arg: LoginArg(
          email: nameController.text,
          password: passwordController.text,
          server: server,
          notificationKey: OneSignal.User.pushSubscription.id ?? "",
        ),
      );

      await _cubit.storeAppSyncLog();
      l.hide();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, FirstDownloadScreen.routeName, (route) => false);
    } on GeneralException catch (e) {
      l.hide();
      showWarningMessage(e.message);
    } on Exception catch (e) {
      l.hide();
      showErrorMessage(e.toString());
    }
  }

  void _navigateToServerOption() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      StarterScreen.routeName,
      (route) => false,
      arguments: {'serverId': server.id},
    );
  }

  void buildPushNamedToForgetPassWord(BuildContext context) {
    //TODO
    // return Navigator.pushNamed(context, "");
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
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: const SizedBox.shrink()),
        body: ListView(
          shrinkWrap: true,
          children: [const BuildLogoHeaderWidget(), Helpers.gapH(60), buildForm(context)],
        ),
      ),
    );
  }

  Widget buildForm(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      bloc: _cubit,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace), vertical: scaleFontSize(appSpace)),
          child: Column(
            spacing: scaleFontSize(appSpace),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(text: greeting("login"), fontWeight: FontWeight.bold, fontSize: 26),
              buildTextFormFieldWidget(controller: nameController, hintText: "Username", labelIcon: Icons.person),
              buildTextFormFieldWidget(
                controller: passwordController,
                hintText: "password",
                labelIcon: Icons.lock,
                obscureText: true,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () => buildPushNamedToForgetPassWord(context),
                  child: TextWidget(
                    text: greeting("forget_pass"),
                    decoration: TextDecoration.underline,
                    textAlign: TextAlign.right,
                    softWrap: true,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: primary,
                  ),
                ),
              ),
              BtnWidget(
                title: greeting("login"),
                onPressed: () => login(),
                horizontal: 0,
                gradient: linearGradient,
                size: BtnSize.medium,
              ),
              Helpers.gapH(appSpace8),
              linkUrl(),
            ],
          ),
        );
      },
    );
  }

  Widget linkUrl() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: greeting("connected_to"),
              style: TextStyle(fontSize: 14.scale, fontWeight: FontWeight.bold, color: textColor),
            ),
            TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _navigateToServerOption();
                },
              text: server.url,
              style: TextStyle(
                fontSize: 14.scale,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                color: primary,
                decorationColor: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextFormFieldWidget buildTextFormFieldWidget({
    required TextEditingController controller,
    String hintText = "",
    IconData? labelIcon,
    bool obscureText = false,
  }) {
    return TextFormFieldWidget(
      controller: controller,
      hintText: greeting(hintText),
      hintColor: textColor50,
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: grey)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: grey)),
      obscureText: obscureText,
      prefixIcon: Icon(labelIcon, color: textColor50, size: scaleFontSize(20)),
      isDefaultTextForm: true,
    );
  }
}
