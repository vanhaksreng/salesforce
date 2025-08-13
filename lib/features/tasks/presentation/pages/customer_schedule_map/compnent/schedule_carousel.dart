import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:salesforce/features/tasks/presentation/pages/customer_schedule_map/compnent/customer_map_schedule_card.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

class ScheduleCarousel extends StatelessWidget {
  final List<SalespersonSchedule> schedules;
  final List<Customer> customers;
  final CarouselSliderController? carouselController;
  final ValueChanged<SalespersonSchedule> onPageChanged;
  const ScheduleCarousel({
    super.key,
    required this.schedules,
    required this.onPageChanged,
    this.carouselController,
    required this.customers,
  });

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return const Center(child: Text("No schedules available."));
    }
    return SafeArea(
      child: CarouselSlider.builder(
        carouselController: carouselController,
        options: CarouselOptions(
          enlargeFactor: 0.2,
          autoPlay: false,
          enableInfiniteScroll: false,
          enlargeCenterPage: true,
          viewportFraction: .9,
          aspectRatio: 1.7,
          onPageChanged: (index, reason) => onPageChanged(schedules[index]),
          initialPage: schedules.length > 2 ? 2 : 0,
        ),
        itemCount: schedules.length,
        itemBuilder: (context, index, _) {
          final schedule = schedules[index];
          final customer = customers.firstWhere((e) => e.no == schedule.customerNo);

          return CustomerMapScheduleCard(schedule: schedule, customer: customer);
        },
      ),
    );
  }
}
