import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/bank_account_extension.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class BankAccountHandler extends BaseTableHandler<BankAccount> {
  @override
  String get tableName => "bank_account";

  @override
  BankAccount fromMap(Map<String, dynamic> map) {
    return BankAccountExtension.fromMap(map);
  }

  @override
  String extractKey(BankAccount record) => record.no;

  @override
  Type get type => BankAccount;
}
