part of 'build_selected_saleperson_cubit.dart';

class BuildSelectedSalepersonState {
  final bool isLoading;

  final String? salePersonCode;

  final List<Salesperson>? salespersons;

  const BuildSelectedSalepersonState({
    this.isLoading = false,
    this.salespersons,
    this.salePersonCode,
  });

  BuildSelectedSalepersonState copyWith({
    bool? isLoading,
    String? uomCode,
    List<Salesperson>? salespersons,
    String? salePersonCode,
  }) {
    return BuildSelectedSalepersonState(
      isLoading: isLoading ?? this.isLoading,
      salespersons: salespersons ?? this.salespersons,
      salePersonCode: salePersonCode ?? this.salePersonCode,
    );
  }
}
