import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/hr.dart';
import 'package:salesforce/core/presentation/widgets/select_option_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_form_field_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/tasks/presentation/pages/group_screen_filter_item/list_tile_selected.dart';
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
  // TypeConnectDevice? selectedValue;

  List<String> list = <String>['3Inch 80mm', '2Inch 50mm'];
  String? dropdownValue;
  final List<String> stringType = ['Bluetooth', 'Network', 'USB'];
  final List<TypeConnectDevice> enumValues = [
    TypeConnectDevice.bluetooth,
    TypeConnectDevice.network,
    TypeConnectDevice.usb,
  ];
  double paperWidth = 576; //80mm

  // Sample device list for demonstration
  final List<Map<String, String>> _availableDevices = [
    {'name': 'Printer-BT-001', 'address': '00:11:22:33:44:55'},
    {'name': 'Thermal Printer 80mm', 'address': '00:11:22:33:44:66'},
    {'name': 'Receipt Printer', 'address': '00:11:22:33:44:77'},
    {'name': 'Mobile Printer', 'address': '00:11:22:33:44:88'},
  ];

  @override
  void initState() {
    dropdownValue = list.first;
    super.initState();
  }

  void _showDeviceBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
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
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        text: "Available Devices",
                        fontSize: scaleFontSize(16),
                        fontWeight: FontWeight.bold,
                        color: textColor50,
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(),

                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _availableDevices.length,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final device = _availableDevices[index];
                      return BoxWidget(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: mainColor.withValues(alpha: 0.1),
                            child: Icon(Icons.print, color: mainColor),
                          ),
                          title: TextWidget(
                            text: device['name']!,
                            fontSize: scaleFontSize(14),
                            fontWeight: FontWeight.w600,
                          ),
                          subtitle: TextWidget(
                            text: device['address']!,
                            fontSize: scaleFontSize(12),
                            color: Colors.grey,
                          ),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            setState(() {
                              _bluetoothname.text = device['name']!;
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: "Create Printer"),
      body: _buildBody(),
      persistentFooterButtons: [
        BtnWidget(onPressed: () {}, title: "Save", gradient: linearGradient),
      ],
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: EdgeInsets.all(scaleFontSize(16)),
      children: [
        TextFormFieldWidget(
          suffixIcon: Icon(Icons.print, color: grey),
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
          suffixIcon: Icon(Icons.model_training, color: grey),
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
            value: dropdownValue,
            icon: Icon(Icons.arrow_downward, size: scaleFontSize(16)),
            elevation: 16,
            hint: TextWidget(text: "asdfasdf"),
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(height: 2, color: Colors.deepPurpleAccent),
            onChanged: (String? value) {
              setState(() {
                dropdownValue = value!;
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
                  suffixIcon: Icon(Icons.history, color: grey),
                  isDefaultTextForm: true,
                  controller: _bluetoothname,
                  label: " BluetoothName",
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
