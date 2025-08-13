import 'package:salesforce/features/tasks/domain/entities/app_version.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

class TasksMainState {
  final bool isLoading;
  final bool refreshChild;
  final int activeTap;
  final int countCheckOut;
  final int countNoneCheckOut;
  final bool hasPendingOldSchedule;
  final String text;
  final AppVersion? appVersion;
  final UserSetup? user;
  final List<SalespersonSchedule> oldSchedules;

  const TasksMainState({
    this.isLoading = false,
    this.refreshChild = false,
    this.activeTap = 0,
    this.countCheckOut = 0,
    this.countNoneCheckOut = 0,
    this.text = "",
    this.appVersion,
    this.user,
    this.hasPendingOldSchedule = false,
    this.oldSchedules = const [],
  });

  TasksMainState copyWith({
    bool? isLoading,
    bool? refreshChild,
    int? activeTap,
    int? countCheckOut,
    int? countNoneCheckOut,
    String? text,
    AppVersion? appVersion,
    UserSetup? user,
    bool? hasPendingOldSchedule,
    List<SalespersonSchedule>? oldSchedules,
  }) {
    return TasksMainState(
      isLoading: isLoading ?? this.isLoading,
      refreshChild: refreshChild ?? this.refreshChild,
      activeTap: activeTap ?? this.activeTap,
      countCheckOut: countCheckOut ?? this.countCheckOut,
      countNoneCheckOut: countNoneCheckOut ?? this.countNoneCheckOut,
      text: text ?? this.text,
      appVersion: appVersion ?? this.appVersion,
      user: user ?? this.user,
      hasPendingOldSchedule: hasPendingOldSchedule ?? this.hasPendingOldSchedule,
      oldSchedules: oldSchedules ?? this.oldSchedules,
    );
  }
}
