import 'package:salesforce/realm/scheme/schemas.dart';

extension BankAccountExtension on BankAccount {
  static BankAccount fromMap(Map<String, dynamic> json) {
    return BankAccount(
      json['no'] as String,
      name: json['name'] ?? "",
      name2: json['name_2'] ?? "",
      bankAccPostingGroup: json['bank_acc_posting_group'] ?? "",
      bankAccountNo: json['bank_account_no'] ?? "",
      currencyCode: json['currency_code'] ?? "",
    );
  }
}
