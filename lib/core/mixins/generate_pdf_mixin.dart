import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/injection_container.dart';

mixin GeneratePdfMixin {
  final _appRepo = getIt<MoreRepository>();

  Future<String> getInvoiceHtml({required String documentNo, required String documenType}) async {
    return await _appRepo.getInvoiceHtml(param: {"doc_no": documentNo, "doc_type": documenType}).then((r) {
      return r.fold((l) => "", (r) => r);
    });
  }
}
