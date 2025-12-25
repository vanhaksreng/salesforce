import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

extension DistributionSetUpExtension on DistributionSetUp {
  static DistributionSetUp fromMap(Map<String, dynamic> json) {
    return DistributionSetUp(Helpers.toStrings(json["key"]), Helpers.toStrings(json["value"]));
  }
}
