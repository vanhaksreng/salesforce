import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/mixins/permission_mixin.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/domain/entities/more_model.dart';
import 'package:salesforce/features/more/more_main_page_cubit.dart';
import 'package:salesforce/features/more/presentation/components/more_shape.dart';
import 'package:salesforce/features/more/presentation/pages/about/about_screen.dart';
import 'package:salesforce/features/more/presentation/pages/invoice_printer/invoice_printer_screen.dart';
import 'package:salesforce/features/more/presentation/pages/profile_form/profile_form_screen.dart';
import 'package:salesforce/features/more/presentation/pages/reset_password/reset_password_screen.dart';
import 'package:salesforce/features/more/profile_design.dart';
import 'package:salesforce/localization/trans.dart';

class MoreMainPage extends StatefulWidget {
  const MoreMainPage({Key? key}) : super(key: key);

  @override
  State<MoreMainPage> createState() => _MoreMainPageState();
}

class _MoreMainPageState extends State<MoreMainPage> with PermissionMixin {
  late MoreMainPageCubit _cubit;

  List<MoreModel> listSettings = [
    MoreModel(
      title: greeting("administration"),
      subTitle: greeting("account_management_and_permissions"),
      icon: Icons.admin_panel_settings_outlined,
      routeName: InvoicePrinterScreen.routeName,
      arg: Args(titelArg: greeting("administration"), parentTitle: greeting("more")),
    ),
    MoreModel(
      title: greeting("reset_password"),
      subTitle: greeting("change_your_account_password"),
      icon: Icons.password,
      routeName: ResetPasswordScreen.routeName, // TODO ResetPasswordScreen.routeName,
      arg: Args(titelArg: greeting("reset_password"), parentTitle: greeting("more")),
    ),
  ];

  List<MoreModel> listSupport = [
    MoreModel(
      title: greeting("about"),
      subTitle: greeting("app_version_and_legal_information"),
      icon: Icons.info_outline,
      routeName: AboutScreen.routeName,
      arg: Args(titelArg: greeting("about"), parentTitle: greeting("more")),
    ),
    MoreModel(
      title: greeting("log_out"),
      subTitle: greeting("logout_your_account"),
      icon: Icons.logout_outlined,
      routeName: "logout",
      arg: Args(titelArg: greeting("log_out"), parentTitle: greeting("more")),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _cubit = context.read<MoreMainPageCubit>();
    _initLoad();
  }

  Future<void> _initLoad() async {
    _cubit.getInitData();
    await _cubit.getMenus(false);
  }

  _pushToDetail(BuildContext context) {
    return Navigator.pushNamed(context, ProfileFormScreen.routeName).then((value) {
      if (Helpers.shouldReload(value)) {
        _cubit.getInitData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BlocBuilder<MoreMainPageCubit, MoreMainPageState>(
            builder: (context, state) {
              return TransitionAppBar(
                onTap: () => _pushToDetail(context),
                title: state.auth?.userName ?? "",
                subtitle: state.auth?.email ?? "",
                avatar: ImageNetWorkWidget(width: double.infinity, imageUrl: state.auth?.imgPath ?? ""),
              );
            },
          ),
          buildSingleChildScrollView(),
        ],
      ),
    );
  }

  Widget buildSingleChildScrollView() {
    return SliverToBoxAdapter(
      child: BlocBuilder<MoreMainPageCubit, MoreMainPageState>(
        bloc: _cubit,
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(scaleFontSize(appSpace)),
            child: Column(
              spacing: scaleFontSize(appSpace),
              children: [
                if (state.isLoading) const LoadingPageWidget(),
                BuildMore(listActionMore: state.listMenus, lable: greeting("operations")),
                BuildMore(listActionMore: listSettings, lable: greeting("account_&_security")),
                BuildMore(listActionMore: listSupport, lable: greeting("support")),
              ],
            ),
          );
        },
      ),
    );
  }
}
