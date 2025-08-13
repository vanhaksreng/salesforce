class CalculateSalePrices {
  final double unitPrice;
  final double quantity;
  final double discountAmount;
  final double discountPercentage;
  final double vatPercentage;
  final bool priceIncludeVat;
  final bool vatBeforeDiscount;

  late final double baseAmount;
  late final double amount; // Final amount after discount, before VAT
  late final double vatAmount;
  late final double vatBaseAmount;
  late final double amountExcludeVat;
  late final double amountIncludeVat;

  CalculateSalePrices({
    required this.unitPrice,
    required this.quantity,
    required this.vatPercentage,
    this.discountAmount = 0,
    this.discountPercentage = 0,
    this.priceIncludeVat = false,
    this.vatBeforeDiscount = false,
  }) {
    _calculate();
  }

  void _calculate() {
    baseAmount = unitPrice * quantity;
    double preDiscountAmount = baseAmount;

    // --- VAT before discount ---
    if (vatBeforeDiscount) {
      if (priceIncludeVat) {
        vatAmount = preDiscountAmount -
            (preDiscountAmount / (1 + (vatPercentage / 100)));
        vatBaseAmount = preDiscountAmount / (1 + (vatPercentage / 100));
        amountExcludeVat = preDiscountAmount - vatAmount;
      } else {
        vatBaseAmount = preDiscountAmount;
        vatAmount = preDiscountAmount * (vatPercentage / 100);
        amountExcludeVat = preDiscountAmount;
      }

      double totalDiscount = 0;
      if (discountPercentage > 0) {
        totalDiscount += amountExcludeVat * (discountPercentage / 100);
      }
      if (discountAmount > 0) {
        totalDiscount += discountAmount;
      }

      amount = amountExcludeVat - totalDiscount;
      amountIncludeVat = amount + vatAmount;
    }

    // --- VAT after discount ---
    else {
      double totalDiscount = 0;
      if (discountPercentage > 0) {
        totalDiscount += preDiscountAmount * (discountPercentage / 100);
      }
      if (discountAmount > 0) {
        totalDiscount += discountAmount;
      }

      amount = preDiscountAmount - totalDiscount;

      if (priceIncludeVat) {
        vatBaseAmount = amount / (1 + (vatPercentage / 100));
        vatAmount = amount - vatBaseAmount;
        amountExcludeVat = vatBaseAmount;
      } else {
        vatBaseAmount = amount;
        vatAmount = amount * (vatPercentage / 100);
        amountExcludeVat = amount;
      }

      amountIncludeVat = amountExcludeVat + vatAmount;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'unit_price': unitPrice,
      'quantity': quantity,
      'base_amount': baseAmount,
      'amount': amount,
      'vat_base_amount': vatBaseAmount,
      'vat_amount': vatAmount,
      'amount_exclude_vat': amountExcludeVat,
      'amount_include_vat': amountIncludeVat,
      'discount_amount': discountAmount,
      'discount_percentage': discountPercentage,
      'vat_percentage': vatPercentage,
      'price_include_vat': priceIncludeVat,
      'vat_before_discount': vatBeforeDiscount,
    };
  }
}
