import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/text_form_field_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/administration/administration_cubit.dart';
import 'package:salesforce/features/more/presentation/pages/administration/administration_state.dart';
import 'package:salesforce/features/more/presentation/pages/administration/adminstatration_helper.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/thermal_printer.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class FormConnectPrinter extends StatefulWidget {
  const FormConnectPrinter({super.key});
  static const String routeName = "FromConnetPrinter";

  @override
  State<FormConnectPrinter> createState() => _FormConnectPrinterState();
}

class _FormConnectPrinterState extends State<FormConnectPrinter> {
  final TextEditingController _nameDevice = TextEditingController();
  final TextEditingController _modelPrinter = TextEditingController();
  final TextEditingController _bluetoothname = TextEditingController();
  TypeConnectDevice? _character = TypeConnectDevice.bluetooth;
  final _cubit = AdministrationCubit();

  List<String> list = <String>['3Inch 80mm', '2Inch 50mm'];
  String? selectedPaperWidth;
  final List<String> stringType = ['Bluetooth', 'Network', 'USB'];
  final List<TypeConnectDevice> enumValues = [
    TypeConnectDevice.bluetooth,
    TypeConnectDevice.network,
    TypeConnectDevice.usb,
  ];
  double paperWidth = 576; //80mm
  PrinterDeviceDiscover? selectDevice;
  ActionState actionState = ActionState.create;

  @override
  void initState() {
    selectedPaperWidth = list.first;
    if (_cubit.state.printerDeviceDiscover.isEmpty) {
      _cubit.startScanning();
    }
    super.initState();
  }

  Future<void> storeDevice() async {
    final deviceType = _character.toString().split('.').last;

    final data = DevicePrinter(
      _nameDevice.text,
      _modelPrinter.text,
      deviceType,
      selectDevice?.name ?? "Unknown",
      selectDevice?.address ?? "Unknown",
      paperWidth,
    );

    try {
      final result = await _cubit.storeDevicePrinter(device: data);

      if (!mounted) return;

      if (result) {
        actionState = ActionState.created;
        _cubit.showSuccessMessage("Device printer created successfully!");
        Navigator.pop(context, actionState);
      }
    } catch (e) {
      _cubit.showErrorMessage(e.toString());
    }
  }

  void _showDeviceBottomSheet() {
    // Start scanning when bottom sheet opens
    _cubit.startScanning();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          BlocBuilder<AdministrationCubit, AdministrationState>(
            bloc: _cubit,
            builder: (context, state) {
              final availableDevices = state.printerDeviceDiscover;
              final isScanning = state.isScanning;

              return DraggableScrollableSheet(
                initialChildSize: 0.6,
                minChildSize: 0.3,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return BoxWidget(
                    color: Colors.white,
                    topLeft: 16,
                    topRight: 16,
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.bluetooth,
                                    color: mainColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  TextWidget(
                                    text: "Available Devices",
                                    fontSize: scaleFontSize(16),
                                    fontWeight: FontWeight.bold,
                                    color: textColor50,
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),

                        // Device list or loading
                        Expanded(
                          child: isScanning
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 4,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                mainColor,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      TextWidget(
                                        text: "Finding devices...",
                                        fontSize: scaleFontSize(16),
                                        fontWeight: FontWeight.w500,
                                        color: textColor50,
                                      ),
                                      const SizedBox(height: 8),
                                      TextWidget(
                                        text: "Please wait",
                                        fontSize: scaleFontSize(14),
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                )
                              : availableDevices.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.bluetooth_disabled,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      TextWidget(
                                        text: "No devices found",
                                        fontSize: scaleFontSize(14),
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton.icon(
                                        onPressed: () {
                                          _cubit.startScanning();
                                        },
                                        icon: const Icon(Icons.refresh),
                                        label: const Text("Scan Again"),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  controller: scrollController,
                                  itemCount: availableDevices.length,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemBuilder: (context, index) {
                                    final device = availableDevices[index];
                                    final isSelected =
                                        selectDevice?.address == device.address;

                                    return BoxWidget(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: mainColor
                                              .withOpacity(0.1),
                                          child: Icon(
                                            Icons.bluetooth,
                                            color: mainColor,
                                          ),
                                        ),
                                        title: TextWidget(
                                          text: device.name,
                                          fontSize: scaleFontSize(14),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        subtitle: TextWidget(
                                          text: device.address,
                                          fontSize: scaleFontSize(12),
                                          color: Colors.grey,
                                        ),
                                        trailing: isSelected
                                            ? Icon(
                                                Icons.check_circle,
                                                color: mainColor,
                                              )
                                            : const Icon(Icons.chevron_right),
                                        onTap: () {
                                          setState(() {
                                            selectDevice = device;
                                            _bluetoothname.text = device.name;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: "Create Printer"),
      body: _buildBody(),
      persistentFooterButtons: [
        BtnWidget(
          onPressed: () => storeDevice(),
          title: "Save",
          gradient: linearGradient,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: EdgeInsets.all(scaleFontSize(16)),
      children: [
        TextFormFieldWidget(
          suffixIcon: Icon(Icons.print, color: mainColor),
          isDefaultTextForm: true,
          fillColor: white,
          filled: true,
          controller: _nameDevice,
          label: "Enter name device",
        ),
        Helpers.gapH(16),
        TextFormFieldWidget(
          fillColor: white,
          filled: true,
          suffixIcon: Icon(Icons.model_training, color: mainColor),
          isDefaultTextForm: true,
          controller: _modelPrinter,
          label: "Enter model",
        ),
        Helpers.gapH(16),
        _buildSelectOption(),
        Helpers.gapH(16),
        _buildSelectDevice(),
        Helpers.gapH(16),
        _buildPapers(),
      ],
    );
  }

  Widget _buildPapers() {
    return BoxWidget(
      padding: EdgeInsets.symmetric(
        horizontal: scaleFontSize(16),
        vertical: scaleFontSize(4),
      ),

      border: Border.all(color: Colors.grey.shade300),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextWidget(
            text: "Select paper width",
            fontSize: scaleFontSize(13),
            color: textColor50,
            fontWeight: FontWeight.w600,
          ),
          const Spacer(),
          DropdownButton<String>(
            value: selectedPaperWidth,
            icon: Icon(Icons.arrow_downward, size: scaleFontSize(16)),
            elevation: 16,
            hint: TextWidget(text: "asdfasdf"),
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(height: 2, color: Colors.deepPurpleAccent),
            onChanged: (String? value) {
              setState(() {
                selectedPaperWidth = value!;
              });
            },
            items: list.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectOption() {
    return BoxWidget(
      padding: EdgeInsets.symmetric(
        horizontal: scaleFontSize(16),
        vertical: scaleFontSize(4),
      ),
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade300),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextWidget(
            text: "Choose connect type",
            fontSize: scaleFontSize(13),
            color: textColor50,
            fontWeight: FontWeight.w600,
          ),
          const Spacer(),
          DropdownButton<TypeConnectDevice>(
            value: _character,
            icon: Icon(Icons.arrow_downward, size: scaleFontSize(16)),
            elevation: 16,
            hint: TextWidget(text: " "),
            style: const TextStyle(color: mainColor),
            underline: Container(height: 2, color: mainColor),
            onChanged: (TypeConnectDevice? value) {
              setState(() {
                _character = value!;
              });
            },
            items: enumValues.map<DropdownMenuItem<TypeConnectDevice>>((
              TypeConnectDevice value,
            ) {
              return DropdownMenuItem<TypeConnectDevice>(
                value: value,
                child: Text(value.toString().toUpperCase().split('.').last),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectDevice() {
    return BoxWidget(
      padding: EdgeInsets.all(scaleFontSize(16)),
      child: Column(
        spacing: scaleFontSize(16),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: "Find Connection here!",
            color: textColor50,
            fontWeight: FontWeight.w600,
          ),
          Row(
            spacing: scaleFontSize(appSpace8),
            children: [
              Flexible(
                flex: 2,
                child: TextFormFieldWidget(
                  readOnly: true,
                  fillColor: grey,
                  filled: true,
                  hintText: "123",
                  suffixIcon: Icon(Icons.history, color: mainColor),
                  isDefaultTextForm: true,
                  controller: _bluetoothname,
                  label: "BluetoothName",
                ),
              ),
              Expanded(
                child: BtnWidget(
                  onPressed: _showDeviceBottomSheet,
                  icon: Icon(Icons.search),
                  title: "Search",
                  gradient: linearGradient,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
