import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class ItemPrizeRedemptionState {
  final bool isLoading;
  final List<ItemPrizeRedemptionHeader> headers;
  final List<ItemPrizeRedemptionLine> lines;
  final List<ItemPrizeRedemptionLineEntry> entries;
  final DefaultProcessArgs? args;

  const ItemPrizeRedemptionState({
    this.isLoading = false,
    this.args,
    this.headers = const [],
    this.lines = const [],
    this.entries = const [],
  });

  ItemPrizeRedemptionState copyWith({
    bool? isLoading,
    DefaultProcessArgs? args,
    List<ItemPrizeRedemptionHeader>? headers,
    List<ItemPrizeRedemptionLine>? lines,
    List<ItemPrizeRedemptionLineEntry>? entries,
  }) {
    return ItemPrizeRedemptionState(
      isLoading: isLoading ?? this.isLoading,
      headers: headers ?? this.headers,
      lines: lines ?? this.lines,
      entries: entries ?? this.entries,
      args: args ?? this.args,
    );
  }
}
