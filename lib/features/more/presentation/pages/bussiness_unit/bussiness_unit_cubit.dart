import 'package:flutter_bloc/flutter_bloc.dart';

part 'bussiness_unit_state.dart';

class BussinessUnitCubit extends Cubit<BussinessUnitState> {
  BussinessUnitCubit() : super(BussinessUnitInitial());
}
