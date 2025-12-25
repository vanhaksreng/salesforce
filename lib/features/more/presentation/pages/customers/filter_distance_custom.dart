import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/box_widget.dart';
import 'package:salesforce/core/presentation/widgets/chip_widgett.dart';
import 'package:salesforce/core/presentation/widgets/custom_slider_thumb.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class FilterDistanceCustom extends StatelessWidget {
  const FilterDistanceCustom({
    super.key,

    this.onChanged,
    required this.onSelectedDistance,
    required this.distancevalue,
    this.isSortDistance = false,
    this.changeSortBy,
  });

  final Function(double)? onChanged;
  final Function(double)? onSelectedDistance;
  final Function(bool isShort)? changeSortBy;
  final bool isSortDistance;
  final double distancevalue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => changeSortBy?.call(!isSortDistance),
          child: Padding(
            padding: EdgeInsets.all(scaleFontSize(16)),
            child: Column(
              spacing: 8.scale,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.scale,
                  children: [
                    Icon(
                      isSortDistance
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: isSortDistance ? mainColor : textColor50,
                    ),
                    Expanded(
                      child: Column(
                        spacing: 8.scale,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: greeting("Sort by Distance"),
                            fontWeight: FontWeight.w500,
                          ),
                          TextWidget(
                            text: greeting(
                              "Sort by distance will sort customer by your current location.",
                            ),
                            color: textColor50,
                            fontSize: 12,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        BoxWidget(
          isBoxShadow: false,
          padding: EdgeInsets.all(scaleFontSize(16)),
          margin: EdgeInsets.all(scaleFontSize(16)),
          isBorder: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BoxWidget(
                    padding: const EdgeInsets.all(8),
                    gradient: linearGradient50,
                    child: Icon(
                      Icons.location_on,
                      color: white,
                      size: scaleFontSize(20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    spacing: 4.scale,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: greeting('Distance Filter'),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      TextWidget(
                        text:
                            'Find within ${distancevalue.toStringAsFixed(0)} km',
                        color: textColor,
                        // fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  const Spacer(),
                  ChipWidget(
                    fontSize: 14,
                    colorText: mainColor,
                    bgColor: mainColor.withValues(alpha: 0.2),
                    label: '${distancevalue.toStringAsFixed(0)} km',
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: mainColor,
                      inactiveTrackColor: grey,
                      thumbColor: white,
                      thumbShape: CustomSliderThumb(
                        thumbRadius: 16,
                        value: distancevalue,
                      ),
                      overlayColor: mainColor.withValues(alpha: 0.3),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 24,
                      ),
                      trackHeight: 6,
                      activeTickMarkColor: Colors.transparent,
                      inactiveTickMarkColor: Colors.transparent,
                    ),
                    child: Slider(
                      value: distancevalue,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: onChanged,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRangeLabel('0 km', Colors.grey.shade600),
                        _buildRangeLabel('25 km', Colors.grey.shade500),
                        _buildRangeLabel('50 km', Colors.grey.shade500),
                        _buildRangeLabel('75 km', Colors.grey.shade500),
                        _buildRangeLabel('100 km', Colors.grey.shade600),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickButton('5 km', 5),
                  _buildQuickButton('15 km', 15),
                  _buildQuickButton('30 km', 30),
                  _buildQuickButton('50 km', 50),
                  _buildQuickButton('100 km', 100),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRangeLabel(String text, Color color) {
    return TextWidget(
      text: text,
      fontSize: 12,
      color: color,
      fontWeight: FontWeight.w500,
    );
  }

  Widget _buildQuickButton(String label, double value) {
    bool isSelected = distancevalue == value;
    return BoxWidget(
      isBoxShadow: false,
      padding: EdgeInsets.all(scaleFontSize(8)),
      onPress: () => onSelectedDistance?.call(value),
      color: isSelected ? mainColor : white,
      isBorder: true,
      child: TextWidget(
        text: label,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isSelected ? Colors.white : Colors.grey.shade700,
      ),
    );
  }
}
