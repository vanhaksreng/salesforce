import 'package:salesforce/realm/scheme/item_schemas.dart';

class PromotionState {
  final bool isLoading;
  final String? error;
  final List<ItemPromotionHeader> headers;

  const PromotionState({this.isLoading = false, this.error, this.headers = const []});

  PromotionState copyWith({bool? isLoading, String? error, List<ItemPromotionHeader>? headers}) {
    return PromotionState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      headers: headers ?? this.headers,
    );
  }
}
