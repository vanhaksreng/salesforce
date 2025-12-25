import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/more/presentation/pages/promotion_detail/promotion_detail_state.dart';
import 'package:salesforce/features/tasks/domain/entities/promotion_item_line_entity.dart';
import 'package:salesforce/features/tasks/domain/entities/promotion_line_entity.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

class PromotionDetailCubit extends Cubit<PromotionDetailState> with MessageMixin {
  PromotionDetailCubit() : super(const PromotionDetailState(isLoading: true));
  final _taskRepo = getIt<TaskRepository>();

  bool _haveOwnLine(String lineType) {
    return ['Item', 'G/L Account'].contains(lineType);
  }

  Future<void> getPromotionLines(String promotionCode) async {
    try {
      final response = await _taskRepo.getItemPromotionLines(params: {'promotion_no': promotionCode});

      await response.fold(
        (failure) => throw GeneralException(failure.message),
        (lines) => _processPromotionLines(lines),
      );
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } catch (e) {
      showErrorMessage(e.toString());
    }
  }

  Future<void> _processPromotionLines(List<ItemPromotionLine> lines) async {
    final items = await _getItems();
    final template = await _buildPromotionTemplate(lines, items);

    emit(state.copyWith(lines: lines, linesTemplate: template, isLoading: false));
  }

  Future<List<Item>> _getItems() async {
    final itemResult = await _taskRepo.getItems();
    return itemResult.fold((failure) => <Item>[], (items) => items);
  }

  Future<List<PromotionLineEntity>> _buildPromotionTemplate(List<ItemPromotionLine> lines, List<Item> items) async {
    final template = <PromotionLineEntity>[];
    final processedTypes = <String>{};

    for (final line in lines) {
      String type = line.type ?? "";
      if (!_haveOwnLine(type)) {
        type = line.itemNo ?? "";
      }

      if (type.isNotEmpty && !processedTypes.contains(type)) {
        processedTypes.add(type);

        final typeLines = lines.where((e) => e.type == line.type).toList();
        final itemLines = await _buildItemLines(typeLines, items);
        final totalQty = _calculateTotalQuantity(typeLines);

        template.add(
          PromotionLineEntity(
            type: type,
            promotionType: line.promotionType ?? "",
            lines: itemLines,
            line: line,
            qty: totalQty,
            totalLineQty: _haveOwnLine(type) ? totalQty : 0,
          ),
        );
      }
    }

    return template;
  }

  Future<List<PromotionItemLineEntity>> _buildItemLines(
    List<ItemPromotionLine> promotionLines,
    List<Item> items,
  ) async {
    final itemLines = <PromotionItemLineEntity>[];

    for (final line in promotionLines) {
      final lineItems = await _getItemsForPromotionLine(line, items);
      itemLines.addAll(lineItems);
    }

    return itemLines;
  }

  Future<List<PromotionItemLineEntity>> _getItemsForPromotionLine(ItemPromotionLine line, List<Item> items) async {
    switch (line.type) {
      case "Item":
        return _getItemsByItem(line, items);
      case "Category":
        return _getItemsByCategory(line, items);
      case "Group":
        return _getItemsByGroup(line, items);
      case "Brand":
        return _getItemsByBrand(line, items);
      case "Discount Group":
        return _getItemsByDiscountCode(line, items);
      case "Promotion Scheme":
        return await _getItemsByPromotionScheme(line, items);
      case "G/L Account":
        return _getGlRecords(line);
      default:
        return <PromotionItemLineEntity>[];
    }
  }

  List<PromotionItemLineEntity> _getItemsByItem(ItemPromotionLine line, List<Item> items) {
    final item = items.firstWhere(
      (item) => item.no == line.itemNo,
      orElse: () => throw Exception('Item not found: ${line.itemNo}'),
    );

    return [
      PromotionItemLineEntity(
        itemNo: item.no,
        itemName: line.description ?? "",
        qty: Helpers.formatNumberDb(line.quantity, option: FormatType.quantity),
        orderQty: Helpers.formatNumberDb(line.quantity, option: FormatType.quantity),
        saleUomCode: line.unitOfMeasureCode ?? "",
        itemPicture: item.picture ?? "",
        promotionType: line.promotionType ?? "",
        lineCode: line.itemNo ?? "",
        item: item,
      ),
    ];
  }

  Future<List<PromotionItemLineEntity>> _getItemsByPromotionScheme(ItemPromotionLine line, List<Item> items) async {
    final pschemes = await _taskRepo.getPromotionScheme(params: {'code': line.itemNo});

    ItemPromotionScheme? scheme = await pschemes.fold((l) => null, (s) => s);

    if (scheme == null || scheme.itemsNos == null || scheme.itemsNos!.isEmpty) {
      return <PromotionItemLineEntity>[];
    }

    final itemNoList = scheme.itemsNos!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final filteredItems = items.where((item) => itemNoList.contains(item.no)).toList();

    return _mapItemsToPromotionItemLines(filteredItems, line);
  }

  List<PromotionItemLineEntity> _getItemsByDiscountCode(ItemPromotionLine line, List<Item> items) {
    final categoryItems = items.where((item) => item.itemDiscountGroupCode == line.itemNo);

    return _mapItemsToPromotionItemLines(categoryItems, line);
  }

  List<PromotionItemLineEntity> _getItemsByCategory(ItemPromotionLine line, List<Item> items) {
    final categoryItems = items.where((item) => item.itemCategoryCode == line.itemNo);

    return _mapItemsToPromotionItemLines(categoryItems, line);
  }

  List<PromotionItemLineEntity> _getItemsByGroup(ItemPromotionLine line, List<Item> items) {
    final groupItems = items.where((item) => item.itemGroupCode == line.itemNo);

    return _mapItemsToPromotionItemLines(groupItems, line);
  }

  List<PromotionItemLineEntity> _getItemsByBrand(ItemPromotionLine line, List<Item> items) {
    final brandItems = items.where((item) => item.itemBrandCode == line.itemNo);

    return _mapItemsToPromotionItemLines(brandItems, line);
  }

  List<PromotionItemLineEntity> _mapItemsToPromotionItemLines(Iterable<Item> items, ItemPromotionLine line) {
    return items
        .map(
          (item) => PromotionItemLineEntity(
            itemNo: item.no,
            itemName: item.description ?? "",
            qty: 0,
            orderQty: 0,
            saleUomCode: item.salesUomCode ?? "",
            itemPicture: item.picture ?? "",
            promotionType: line.promotionType ?? "",
            lineCode: line.itemNo ?? "",
            item: item,
          ),
        )
        .toList();
  }

  List<PromotionItemLineEntity> _getGlRecords(ItemPromotionLine line) {
    return [
      PromotionItemLineEntity(
        itemNo: line.itemNo ?? "",
        itemName: line.description ?? "",
        qty: Helpers.formatNumberDb(line.quantity, option: FormatType.quantity),
        orderQty: Helpers.formatNumberDb(line.quantity, option: FormatType.quantity),
        saleUomCode: line.unitOfMeasureCode ?? "",
        itemPicture: "",
        promotionType: line.promotionType ?? "",
        lineCode: line.itemNo ?? "",
        item: null,
      ),
    ];
  }

  double _calculateTotalQuantity(List<ItemPromotionLine> lines) {
    return lines.fold<double>(0.0, (sum, line) => sum + Helpers.toDouble(line.quantity));
  }
}
