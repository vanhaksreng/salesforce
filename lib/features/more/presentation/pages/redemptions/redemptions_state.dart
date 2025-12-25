import 'package:salesforce/realm/scheme/item_schemas.dart';

class RedemptionsState {
  final bool isLoading;
  final String? error;
  final List<ItemPrizeRedemptionHeader> headers;
  final List<ItemPrizeRedemptionLine> lines;

  const RedemptionsState({this.isLoading = false, this.error, this.headers = const [], this.lines = const []});

  RedemptionsState copyWith({
    bool? isLoading,
    String? error,
    List<ItemPrizeRedemptionHeader>? headers,
    List<ItemPrizeRedemptionLine>? lines,
  }) {
    return RedemptionsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      headers: headers ?? this.headers,
      lines: lines ?? this.lines,
    );
  }
}
