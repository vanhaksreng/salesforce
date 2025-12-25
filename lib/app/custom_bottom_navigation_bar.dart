import 'package:flutter/material.dart';
import 'package:salesforce/app/navigation_item.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.navigationItems,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationItem> navigationItems;

  @override
  BottomNavigationBar build(BuildContext context) {
    return BottomNavigationBar(
      key: super.key,
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: scaleFontSize(14),
      unselectedFontSize: scaleFontSize(13),
      selectedItemColor: mainColor50,
      elevation: 5,
      useLegacyColorScheme: true,
      showSelectedLabels: true,
      backgroundColor: white,
      unselectedItemColor: textColor50,
      items: navigationItems.asMap().entries.map((entry) {
        final NavigationItem item = entry.value;
        return BottomNavigationBarItem(
          key: ValueKey(entry.key),
          icon: Icon(item.icon, size: scaleFontSize(appBarIconSize)),
          label: greeting(item.label),
        );
      }).toList(),
    );
  }

  // NavigationBar build(BuildContext context) {
  //   return NavigationBar(
  //     selectedIndex: currentIndex,
  //     onDestinationSelected: onTap,
  //     key: super.key,
  //     indicatorColor: mainColor50.withValues(alpha: .2),
  //     destinations: navigationItems.asMap().entries.map((entry) {
  //       final NavigationItem item = entry.value;
  //       return NavigationDestination(
  //         key: ValueKey(entry.key),
  //         icon: Icon(
  //           item.icon,
  //           size: scaleFontSize(appBarIconSize),
  //           color: textColor50,
  //         ),
  //         selectedIcon: Icon(
  //           item.icon,
  //           size: scaleFontSize(appBarIconSize),
  //           color: mainColor, // Selected color
  //         ),
  //         label: greeting(item.label),
  //       );
  //     }).toList(),
  //   );
  // }
}
