import 'package:salesforce/realm/scheme/schemas.dart';

extension SubContractTypeExtension on SubContractType {
  static SubContractType fromMap(Map<String, dynamic> item) {
    return SubContractType(
      item['code'] as String? ?? "",
      description: item['description'] as String?,
      description2: item['description_2'] as String?,
      contractCode: item['contract_code'] as String?,
      inactived: item['inactived'] as String?,
    );
  }
}
