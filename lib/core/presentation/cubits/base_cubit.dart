import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/injection_container.dart';

abstract class BaseCubit<T> extends Cubit<T> {
  BaseCubit(super.initialState);
}

abstract class TaskBaseCubit<T> extends Cubit<T> {
  final TaskRepository taskRepository;

  TaskBaseCubit(super.initialState) : taskRepository = getIt<TaskRepository>();
}
