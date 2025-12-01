import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';

class BluetoothDeviceItem extends StatelessWidget {
  final DevicePrinter device;
  final Function(DevicePrinter)? onTap;
  final Function(DevicePrinter)? onConnect;
  final Function(DevicePrinter)? onDisconnect;
  final Function(DevicePrinter)? onDelete;
  final bool isConnected;
  final bool isConnecting;

  const BluetoothDeviceItem({
    super.key,
    required this.device,
    this.onTap,
    this.onConnect,
    this.onDisconnect,
    this.onDelete,
    this.isConnected = false,
    this.isConnecting = false,
  });

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      onLongPress: () {
        onDelete?.call(device);
      },
      onPress: () {
        onTap?.call(device);
      },
      margin: const EdgeInsets.only(bottom: 6),
      isBorder: true,
      borderColor: isConnected
          ? mainColor.withValues(alpha: .5)
          : Colors.transparent,
      padding: EdgeInsets.all(scaleFontSize(appSpace8)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isConnected
                  ? mainColor.withValues(alpha: .1)
                  : grey.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.print_rounded,
              color: isConnected ? mainColor : Colors.grey[700],
              size: 28,
            ),
          ),
          Helpers.gapW(scaleFontSize(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextWidget(
                        text: device.deviceName,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isConnected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const TextWidget(
                          text: 'Paired',
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                Helpers.gapH(4),
                TextWidget(
                  text: device.originDeviceName,
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                Helpers.gapH(scaleFontSize(4)),
              ],
            ),
          ),

          if (isConnected)
            IconButton(
              onPressed: () => onDisconnect?.call(device),
              icon: const Icon(Icons.link_off, color: Colors.red, size: 20),
              tooltip: 'Disconnect',
            )
          else
            IconButton(
              onPressed: () => onConnect?.call(device),
              icon: Icon(Icons.link, color: mainColor, size: 20),
              tooltip: 'Connect',
            ),
        ],
      ),
    );
  }
}
