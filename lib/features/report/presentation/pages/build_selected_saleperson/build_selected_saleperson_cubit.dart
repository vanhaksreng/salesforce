import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/mixins/default_sale_person_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

part 'build_selected_saleperson_state.dart';

class BuildSelectedSalepersonCubit extends Cubit<BuildSelectedSalepersonState>
    with MessageMixin, DefaultSalePersonMixin {
  BuildSelectedSalepersonCubit() : super(const BuildSelectedSalepersonState(isLoading: true));

  Future<void> getSalespersons({Map<String, dynamic>? param}) async {
    final salesPersons = await getDownLines();
    emit(state.copyWith(salespersons: salesPersons));
  }

  void selectedSalePersonCode(String salePersonCode) {
    emit(state.copyWith(salePersonCode: salePersonCode));
  }
}
