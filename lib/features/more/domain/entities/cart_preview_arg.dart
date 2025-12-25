import 'package:salesforce/realm/scheme/schemas.dart';

class CartPreviewArg {
  final String documentType;
  final Customer customer;

  CartPreviewArg({required this.documentType, required this.customer});
}
