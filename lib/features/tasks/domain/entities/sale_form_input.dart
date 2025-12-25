import 'package:salesforce/realm/scheme/schemas.dart';

class SaleFormInput {
  final String code;
  final String description;
  final double quantity;
  final String uomCode;

  const SaleFormInput({required this.code, required this.description, required this.quantity, required this.uomCode});

  factory SaleFormInput.fromJson(PromotionType type) {
    return SaleFormInput(
      code: type.code,
      description: type.code == "STD" ? "Sale quantity" : type.description ?? "",
      quantity: 0,
      uomCode: "",
    );
  }

  SaleFormInput copyWith({String? code, String? description, double? quantity, String? uomCode}) {
    return SaleFormInput(
      code: code ?? this.code,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      uomCode: uomCode ?? this.uomCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'description': description, 'quantity': quantity, 'uom_code': uomCode};
  }
}
