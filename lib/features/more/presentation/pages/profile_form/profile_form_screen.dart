import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/bottom_sheet_fn.dart';
import 'package:salesforce/core/presentation/widgets/btn_icon_circle_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/header_bottom_sheet.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/presentation/widgets/list_tile_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading/loading_overlay.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_form_field_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/auth/domain/entities/user.dart';
import 'package:salesforce/features/more/domain/entities/user_info.dart';
import 'package:salesforce/features/more/presentation/pages/profile_form/profile_form_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/profile_form/profile_form_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});
  static const String routeName = "profileFormScreen";

  @override
  ProfileFormScreenState createState() => ProfileFormScreenState();
}

class ProfileFormScreenState extends State<ProfileFormScreen>
    with MessageMixin {
  final _cubit = ProfileFormCubit();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final locationCodeController = TextEditingController();
  final salesPersonCodeController = TextEditingController();
  User? _auth;

  String? image;
  late ActionState _action = ActionState.init;

  @override
  void initState() {
    onInit();
    super.initState();
  }

  onInit() async {
    _auth = getAuth();
    await _cubit.getUserSetup();
    final userSetUp = _cubit.state.user;
    final userName = _auth?.userName ?? "";
    List<String> nameParts = userName.trim().split(" ");

    String firstName = nameParts.isNotEmpty ? nameParts.first : "";
    String lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(" ")
        : "";
    firstNameController.text = firstName;
    lastNameController.text = lastName;
    emailController.text = _auth?.email ?? "";
    phoneController.text = _auth?.phoneNo ?? "";
    image = _auth?.imgPath ?? "";
    locationCodeController.text = userSetUp?.locationCode ?? "";
    salesPersonCodeController.text = userSetUp?.salespersonCode ?? "";
  }

  _saveInfoUser() async {
    final l = LoadingOverlay.of(context);
    try {
      l.show();
      await _cubit.updateProfileUser(
        UserInfo(
          phoneNumber: phoneController.text,
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          userImagePath: _cubit.state.imgPath?.path ?? image ?? "",
        ),
      );
      _action = ActionState.updated;
      if (!mounted) return;
      l.hide();
      Navigator.of(context).pop(_action);
    } catch (e) {
      l.hide();
      showErrorMessage(e.toString());
    }
  }

  Future _pickImage(ImageSource imageSource) async {
    Navigator.pop(context);
    try {
      final picker = await ImagePicker().pickImage(
        imageQuality: 100,
        source: imageSource,
      );
      if (picker == null) return;
      _cubit.getImage(XFile(picker.path));
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }

  void openCamera(BuildContext context) {
    _pickImage(ImageSource.camera);
  }

  showBottomSheetCamera() {
    modalBottomSheet(
      context,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: scaleFontSize(appSpace),
          children: [
            HeaderBottomSheet(
              childWidget: TextWidget(
                text: greeting("Select a single option below."),
                fontSize: 16,
                color: white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(scaleFontSize(8)),
              child: Column(
                spacing: scaleFontSize(8),
                children: [
                  ListTitleWidget(
                    leading: const Icon(Icons.camera_alt, color: mainColor),
                    onTap: () => openCamera(context),
                    label: greeting("Camera"),
                    subTitle: greeting("Take photo by using camera."),
                  ),
                  ListTitleWidget(
                    leading: const Icon(Icons.photo, color: mainColor),
                    onTap: () => _pickImage(ImageSource.gallery),
                    label: greeting("gallery"),
                    subTitle: greeting("Take photo from gallery."),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        onBack: () => Navigator.of(context).pop(_action),
        title: greeting("Profile Form"),
      ),
      body: BlocBuilder<ProfileFormCubit, ProfileFormState>(
        bloc: _cubit,
        builder: (BuildContext context, ProfileFormState state) {
          if (state.isLoading) {
            return const LoadingPageWidget();
          }

          return buildBody(state);
        },
      ),
      persistentFooterButtons: [
        BtnWidget(
          horizontal: appSpace,
          onPressed: () => _saveInfoUser(),
          gradient: linearGradient,
          title: greeting("Save Info"),
        ),
      ],
    );
  }

  Widget buildBody(ProfileFormState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(scaleFontSize(appSpace)),
      child: Column(
        spacing: scaleFontSize(20),
        children: [_buildEditImageProfile(state), _buildInfoProfile()],
      ),
    );
  }

  Widget _buildInfoProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: scaleFontSize(appSpace),
      children: [
        TextWidget(
          text: greeting("Personal Information"),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),

        Row(
          spacing: 8.scale,
          children: [
            Expanded(
              child: TextFormFieldWidget(
                hintColor: textColor50,
                label: greeting("First Name"),
                controller: firstNameController,
                isDefaultTextForm: true,
              ),
            ),
            Expanded(
              child: TextFormFieldWidget(
                hintColor: textColor50,
                label: greeting("Last Name"),
                controller: lastNameController,
                isDefaultTextForm: true,
              ),
            ),
          ],
        ),
        TextFormFieldWidget(
          readOnly: true,
          filled: true,
          label: greeting("Email"),
          controller: emailController,
          isDefaultTextForm: true,
        ),
        TextFormFieldWidget(
          label: greeting("Phone Number"),
          controller: phoneController,
          isDefaultTextForm: true,
        ),

        Row(
          spacing: 8.scale,
          children: [
            Expanded(
              child: TextFormFieldWidget(
                readOnly: true,

                filled: true,
                label: greeting("Location Code"),
                controller: locationCodeController,
                isDefaultTextForm: true,
              ),
            ),
            Expanded(
              child: TextFormFieldWidget(
                readOnly: true,

                filled: true,
                label: greeting("Salesperson Code"),
                controller: salesPersonCodeController,
                isDefaultTextForm: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Center _buildEditImageProfile(ProfileFormState state) {
    return Center(
      child: Stack(
        children: [
          ClipOval(
            child: ImageNetWorkWidget(
              imageUrl: state.imgPath?.path ?? image ?? "",
              isShadows: true,
              height: 150,
              width: 150,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: BtnIconCircleWidget(
              bgColor: mainColor50.withValues(alpha: .2),
              flipX: false,
              onPressed: () => showBottomSheetCamera(),
              icons: const Icon(Icons.edit, color: mainColor50),
            ),
          ),
        ],
      ),
    );
  }
}
