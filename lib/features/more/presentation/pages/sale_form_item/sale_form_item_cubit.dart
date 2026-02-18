import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/constants/permission.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/mixins/permission_mixin.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/features/more/domain/entities/item_sale_arg.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/features/more/presentation/pages/sale_form_item/sale_form_item_state.dart';
import 'package:salesforce/features/tasks/domain/entities/sale_form_input.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class SaleFormItemCubit extends Cubit<SaleFormItemState>
    with PermissionMixin, MessageMixin {
  SaleFormItemCubit() : super(SaleFormItemState(isLoading: true));
  final _moreRepos = getIt<MoreRepository>();
  PosSalesLine? stdSaleLine;

  Future<void> getPromotionType() async {
    try {
      final res = await _moreRepos.getPromotionType();
      res.fold((l) => throw Exception(l.message), (promotion) {
        List<SaleFormInput> frmInput =
            promotion.map((p) => SaleFormInput.fromJson(p)).toList()
              ..sort((a, b) {
                if (a.code == "STD") return -1;
                if (b.code == "STD") return 1;
                return a.code.compareTo(b.code);
              });

        emit(
          state.copyWith(
            saleForm: frmInput,
            isExistedStd: frmInput.any((e) => e.code == "STD"),
          ),
        );
      });
    } catch (e) {
      //
    }
  }

  Future<void> loadInitialData(ItemSaleArg arg) async {
    final stableState = state;
    try {
      emit(state.copyWith(isLoading: true));

      final customerResult = await _moreRepos.getCustomer(
        params: {"no": arg.customer.no},
      );

      Customer? customer = await customerResult.fold(
        (failure) => null,
        (customer) => customer,
      );

      if (customer == null) {
        throw Exception("Customer not found.");
      }

      final saleNo = Helpers.getSaleDocumentNo(
        scheduleId: customer.no,
        documentType: arg.documentType,
      );

      final getSaleLines = await _moreRepos.getPosSaleLines(
        params: {'document_type': arg.documentType, 'document_no': saleNo},
      );

      List<PosSalesLine> lines = getSaleLines.fold((l) => [], (r) => r);

      final canDiscount = await hasPermission(kManualSellingDiscount);
      final canModifyPrice = await hasPermission(kManualSellingPrice);

      final String itemNo = arg.item?.no ?? "";
      String salesUomCode = arg.item?.salesUomCode ?? "";
      double unitPrice = Helpers.toDouble(arg.item?.unitPrice);
      double manualPrice = 0;

      if (lines.isNotEmpty) {
        int rIndex = lines.indexWhere((e) {
          return e.no == itemNo && e.specialType == kPromotionTypeStd;
        });

        if (rIndex != -1) {
          stdSaleLine = lines[rIndex];

          unitPrice = Helpers.toDouble(stdSaleLine?.unitPrice);
          salesUomCode = stdSaleLine?.unitOfMeasure ?? "";
          manualPrice = Helpers.formatNumberDb(stdSaleLine?.manualUnitPrice);
        }
      }

      final updatedForms = state.saleForm.map((form) {
        int rIndex = lines.indexWhere((e) {
          return e.no == itemNo && form.code == e.specialType;
        });

        double quantity = 0;
        String uomCode = form.uomCode;

        if (rIndex != -1) {
          quantity = Helpers.formatNumberDb(
            lines[rIndex].quantity,
            option: FormatType.quantity,
          );
          uomCode = lines[rIndex].unitOfMeasure ?? uomCode;
        }

        if (uomCode.isEmpty) {
          uomCode = arg.item?.salesUomCode ?? "";
        }

        if (form.code == kPromotionTypeStd && stdSaleLine == null) {
          _updateItemPrice(
            uomCode: form.uomCode,
            orderQty: Helpers.toStrings(quantity),
          );
        }

        return form.copyWith(quantity: quantity, uomCode: uomCode);
      }).toList();

      emit(
        state.copyWith(
          isLoading: false,
          canDiscount: canDiscount,
          canModifyPrice: canModifyPrice,
          customer: customer,
          schedule: null,
          item: arg.item,
          itemUnitPrice: unitPrice,
          documentType: arg.documentType,
          saleLines: lines,
          saleForm: updatedForms,
          manualPrice: manualPrice,
          saleUomCode: salesUomCode,
          discountAmt: stdSaleLine != null ? stdSaleLine?.discountAmount : 0,
          discountPercentage: stdSaleLine != null
              ? stdSaleLine?.discountPercentage
              : 0,
        ),
      );
    } catch (error) {
      Logger.log(error);
      emit(stableState.copyWith(isLoading: false));
    }
  }

  void _updateItemPrice({
    required String orderQty,
    required String uomCode,
  }) async {
    ItemSalesLinePrices? salePrice = await _getItemSalelinePrice(
      customer: state.customer,
      uomCode: uomCode,
      orderQty: orderQty,
    );

    salePrice ??
        await _getItemSalelinePrice(
          customer: state.customer,
          orderQty: orderQty,
          uomCode: "",
        );

    double itemUnitPrice = 0;
    double manualPrice = 0;
    double disAmt = 0;
    double disPercent = 0;

    if (stdSaleLine != null) {
      disAmt = Helpers.toDouble(stdSaleLine?.discountAmount);
      disPercent = Helpers.toDouble(stdSaleLine?.discountPercentage);
      manualPrice = Helpers.toDouble(stdSaleLine?.manualUnitPrice);
    }

    if (salePrice == null) {
      final itemUomResponse = await _moreRepos.getItemUom(
        params: {
          'item_no': state.item?.no ?? "",
          'unit_of_measure_code': uomCode,
        },
      );

      if (itemUnitPrice == 0) {
        ItemUnitOfMeasure? itemUom = await itemUomResponse.fold(
          (failure) => null,
          (itemUom) => itemUom,
        );

        if (itemUom != null) {
          itemUnitPrice = Helpers.toDouble(itemUom.price);
        }
      }

      if (itemUnitPrice == 0) {
        itemUnitPrice = Helpers.toDouble(state.itemUnitPrice);
      }

      emit(
        state.copyWith(
          itemUnitPrice: itemUnitPrice,
          discountAmt: disAmt,
          discountPercentage: disPercent,
          manualPrice: manualPrice,
        ),
      );

      return;
    }

    disAmt = Helpers.toDouble(salePrice.discountAmount);
    disPercent = Helpers.toDouble(salePrice.discountPercentage);
    if (stdSaleLine != null) {
      disAmt = Helpers.toDouble(stdSaleLine?.discountAmount);
      disPercent = Helpers.toDouble(stdSaleLine?.discountPercentage);
      manualPrice = Helpers.toDouble(stdSaleLine?.manualUnitPrice);
    }

    if (itemUnitPrice == 0) {
      itemUnitPrice = Helpers.toDouble(salePrice.unitPrice);
    }

    if (itemUnitPrice == 0) {
      itemUnitPrice = Helpers.toDouble(state.itemUnitPrice);
    }

    emit(
      state.copyWith(
        itemUnitPrice: itemUnitPrice,
        discountAmt: disAmt,
        discountPercentage: disPercent,
        manualPrice: manualPrice,
      ),
    );
  }

  void updateQuantity(String code, String value) {
    final quantity = Helpers.toDouble(value);
    final updatedForms = state.saleForm.map((form) {
      if (form.code == code) {
        if (code == kPromotionTypeStd) {
          _updateItemPrice(
            uomCode: form.uomCode,
            orderQty: Helpers.toStrings(quantity),
          );
        }

        return form.copyWith(quantity: quantity);
      }

      return form;
    }).toList();

    emit(state.copyWith(saleForm: updatedForms));
  }

  void updateSaleUom(String code, String uomCode) {
    final updatedForms = state.saleForm.map((form) {
      if (form.code == code) {
        if (code == kPromotionTypeStd) {
          _updateItemPrice(
            uomCode: uomCode,
            orderQty: Helpers.toStrings(form.quantity),
          );
        }
        return form.copyWith(uomCode: uomCode);
      }

      return form;
    }).toList();

    emit(state.copyWith(saleForm: updatedForms));

    if (code == kPromotionTypeStd) {
      emit(state.copyWith(saleUomCode: uomCode));
    }
  }

  Future<ItemSalesLinePrices?> _getItemSalelinePrice({
    String orderQty = "1",
    String uomCode = "",
    Customer? customer,
  }) async {
    if (customer == null) return null;

    final salePriceResult = await _moreRepos.getItemSaleLinePrice(
      saleType: "Customer",
      saleCode: customer.no,
      orderQty: orderQty,
      itemNo: state.item?.no ?? "",
      uomCode: uomCode,
    );

    ItemSalesLinePrices? salePrice = await salePriceResult.fold(
      (failure) => null,
      (price) => price,
    );

    if (salePrice == null) {
      final groupPriceResult = await _moreRepos.getItemSaleLinePrice(
        saleType: "Customer Price Group",
        saleCode: customer.customerPriceGroupCode ?? "_N0NE_",
        orderQty: orderQty,
        itemNo: state.item?.no ?? "",
        uomCode: uomCode,
      );

      salePrice = await groupPriceResult.fold(
        (failure) => null,
        (price) => price,
      );
    }

    if (salePrice == null) {
      final allCustomersPriceResult = await _moreRepos.getItemSaleLinePrice(
        saleType: "All Customers",
        orderQty: orderQty,
        itemNo: state.item?.no ?? "",
        uomCode: uomCode,
      );

      salePrice = await allCustomersPriceResult.fold(
        (failure) => null,
        (price) => price,
      );
    }

    return salePrice;
  }

  void updateDiscountAmount(String value) {
    emit(state.copyWith(discountAmt: Helpers.toDouble(value)));
  }

  void updateDiscountPercentage(String value) {
    emit(state.copyWith(discountPercentage: Helpers.toDouble(value)));
  }

  void updateManualPrice(String value) {
    emit(state.copyWith(manualPrice: Helpers.toDouble(value)));
  }

  Future<bool> onSaveRecord() async {
    try {
      // Validate form data
      if (!_validateSaleForm()) {
        return false;
      }
      
      //Prepare sale data
      final saleData = _prepareSaleData();

      //Save to repository
      final result = await _moreRepos.insertSale(saleData);

      result.fold((failure) => throw GeneralException(failure.message), (
        success,
      ) {
        showSuccessMessage("Added success");
      });

      return true;
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
      return false;
    } catch (e) {
      showErrorMessage(e.toString());
      return false;
    }
  }

  bool _validateSaleForm() {
    if (state.saleForm.isEmpty) {
      showWarningMessage('No sale items found');
      return false;
    }

    // Check if at least one item has quantity
    final hasQuantity = state.saleForm.any((form) => form.quantity > 0);
    if (!hasQuantity) {
      showWarningMessage('Please enter quantity for at least one item');
      return false;
    }

    if (state.discountPercentage > 100) {
      showWarningMessage('Discount percentage cannot exceed 100');
      return false;
    }

    // Validate discount if applied
    if ((state.discountAmt > 0 || state.discountPercentage < 0) &&
        !state.canDiscount) {
      showWarningMessage('You do not have permission to apply discounts');
      return false;
    }

    return true;
  }

  SaleItemArg _prepareSaleData() {
    final item = state.item;
    final customer = state.customer;

    if (item == null) {
      throw GeneralException("Item cannot empty");
    }

    final inputs = state.saleForm.where((form) {
      return form.quantity > 0;
    }).toList();

    if (inputs.isEmpty) {
      throw GeneralException('No items with quantity found');
    }

    if (item.preventNegativeInventory != kStatusNo &&
        state.documentType == kSaleInvoice) {
      double decreaseQty = inputs.fold(0.0, (sum, line) {
        return sum + Helpers.toDouble(line.quantity);
      });

      double inventory = state.item?.inventory ?? 0;

      if (decreaseQty > inventory) {
        throw GeneralException(
          'Only $inventory available, but you tried to sell $decreaseQty.',
        );
      }
    }

    final double subTotal = inputs.fold(0.0, (sum, line) {
      double price = state.manualPrice > 0
          ? state.manualPrice
          : state.itemUnitPrice;
      return sum + (Helpers.toDouble(line.quantity) * price);
    });

    if (state.discountAmt > subTotal) {
      throw GeneralException(
        'Discount amount cannot exceed subtotal of $subTotal',
      );
    }

    return SaleItemArg(
      item: item,
      inputs: inputs,
      customer: customer!,
      discountAmount: _getDiscountAmt(),
      discountPercentage: _getDiscountPercent(),
      manualPrice: _getManualPrice(),
      documentType: state.documentType,
      itemUnitPrice: state.itemUnitPrice,
    );
  }

  double? _getManualPrice() {
    if (!state.canModifyPrice) {
      return null;
    }

    if (state.manualPrice > 0) {
      return state.manualPrice;
    }

    return null;
  }

  double? _getDiscountAmt() {
    if (!state.canDiscount) {
      return null;
    }

    if (state.discountAmt > 0) {
      return state.discountAmt;
    }

    return null;
  }

  double? _getDiscountPercent() {
    if (!state.canDiscount) {
      return null;
    }

    if (state.discountPercentage > 0) {
      return state.discountPercentage;
    }

    return null;
  }
}
