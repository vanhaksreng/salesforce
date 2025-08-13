import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

mixin DefaultSalePersonMixin {
  final _repo = getIt<BaseAppRepository>();

  Future<Salesperson?> defaultSaleperson() async {
    final usersetup = await _repo.getUserSetup().then((r) {
      return r.fold((f) => null, (userSetup) => userSetup);
    });

    return await _repo.getSaleperson(params: {'code': usersetup?.salespersonCode ?? ""}).then((r) {
      return r.fold((f) => null, (saleperson) => saleperson);
    });
  }

  Future<List<Salesperson>> getDownLines() async {
    final defaultSale = await defaultSaleperson();

    if (defaultSale == null) {
      GeneralException("Salesperson not found!");
      return [];
    }

    List<String> downLines = [];

    String downLine = defaultSale.downLineData ?? "";

    if (downLine.isEmpty) {
      downLines.add(defaultSale.code);
    } else {
      downLines = downLine.split(',').map((e) => e.trim()).toList();
    }
    String codesInClause = downLines.map((e) => '"$e"').join(',');

    return await _repo.getSalepersons(params: {'code': 'IN {$codesInClause}'}).then((r) {
      return r.fold((f) => [], (saleperson) => saleperson);
    });
  }
}
