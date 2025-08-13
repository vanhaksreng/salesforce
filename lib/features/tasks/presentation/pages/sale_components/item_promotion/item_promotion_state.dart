import 'package:salesforce/realm/scheme/item_schemas.dart';

class ItemPromotionState {
  final bool isLoading;
  final List<ItemPromotionHeader> headers;

  const ItemPromotionState({this.isLoading = false, this.headers = const []});

  ItemPromotionState copyWith({bool? isLoading, List<ItemPromotionHeader>? headers}) {
    return ItemPromotionState(isLoading: isLoading ?? this.isLoading, headers: headers ?? this.headers);
  }
}
