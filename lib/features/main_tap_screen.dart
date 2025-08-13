import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/app/custom_bottom_navigation_bar.dart';
import 'package:salesforce/app/navigation_item.dart';
import 'package:salesforce/features/more/more_main_page.dart';
import 'package:salesforce/features/more/more_main_page_cubit.dart';
import 'package:salesforce/features/notification/notification_screen.dart';
import 'package:salesforce/features/report/main_page_report_screen.dart';
import 'package:salesforce/features/stock/main_page_stock_screen.dart';
import 'package:salesforce/features/tasks/tasks_main_cubit.dart';
import 'package:salesforce/features/tasks/tasks_main_screen.dart';

class MainTapScreen extends StatelessWidget {
  MainTapScreen({super.key});

  static String routeName = "homeScreen";

  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.calendar_month_outlined,
      label: 'Visit',
      screen: BlocProvider(create: (context) => TasksMainCubit(), child: const TasksMainScreen()),
    ),
    const NavigationItem(icon: Icons.category_outlined, label: 'stock', screen: MainPageStockScreen()),
    const NavigationItem(icon: Icons.receipt_long_outlined, label: 'report', screen: MainPageReportScreen()),
    const NavigationItem(icon: Icons.notifications_active_outlined, label: 'Reminders', screen: NotificationScreen()),
    NavigationItem(
      icon: Icons.grid_view_outlined,
      label: 'more',
      screen: BlocProvider(create: (context) => MoreMainPageCubit(), child: const MoreMainPage()),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, index, _) {
          return KeyedSubtree(key: ValueKey(index), child: _navigationItems[index].screen);
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, index, _) {
          return CustomBottomNavigationBar(
            currentIndex: index,
            onTap: (newIndex) => _selectedIndex.value = newIndex,
            navigationItems: _navigationItems,
          );
        },
      ),
    );
  }
}
