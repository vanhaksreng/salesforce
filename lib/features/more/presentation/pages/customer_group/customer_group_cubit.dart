import 'package:flutter_bloc/flutter_bloc.dart';

part 'customer_group_state.dart';

class CustomerGroupCubit extends Cubit<CustomerGroupState> {
  CustomerGroupCubit() : super(CustomerGroupInitial());
}
