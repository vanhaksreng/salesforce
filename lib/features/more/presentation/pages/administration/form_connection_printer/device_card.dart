import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/administration/adminstatration_helper.dart';
import 'package:salesforce/theme/app_colors.dart';

class BluetoothDeviceItem extends StatelessWidget {
  final DeviceConnect device;
  final Function(DeviceConnect)? onTap;

  const BluetoothDeviceItem({super.key, required this.device, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BoxWidget(
      onPress: () => onTap?.call(device),
      margin: const EdgeInsets.only(bottom: 6),
      isBorder: true,
      borderColor: device.isConnected
          ? mainColor.withValues(alpha: .5)
          : Colors.transparent,
      padding: EdgeInsets.all(scaleFontSize(appSpace8)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: device.isConnected
                  ? mainColor.withValues(alpha: .1)
                  : grey.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.print_rounded,
              color: device.isConnected ? mainColor : Colors.grey[700],
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
                        text: device.name,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (device.isPaired)
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
                  text: device.connectorDevice.bluetoothName,
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                Helpers.gapH(scaleFontSize(4)),
              ],
            ),
          ),
          if (device.isConnected)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: .1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
            )
          else
            Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
