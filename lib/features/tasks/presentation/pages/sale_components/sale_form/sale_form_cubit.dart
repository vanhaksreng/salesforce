import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/constants/permission.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/mixins/permission_mixin.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/features/tasks/domain/entities/sale_form_input.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

part 'sale_form_state.dart';

class SaleFormCubit extends Cubit<SaleFormState>
    with PermissionMixin, MessageMixin {
  SaleFormCubit() : super(const SaleFormState(isLoading: true));

  final _taskRepos = getIt<TaskRepository>();

  PosSalesLine? stdSaleLine;

  Future<void> getPromotionType() async {
    try {
      final res = await _taskRepos.getPromotionType();
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

  Future<void> loadInitialData(SaleFormArg arg) async {
    final stableState = state;
    try {
      emit(state.copyWith(isLoading: true));

      final customerResult = await _taskRepos.getCustomer(
        no: arg.schedule.customerNo ?? "",
      );

      Customer? customer = await customerResult.fold(
        (failure) => null,
        (customer) => customer,
      );

      if (customer == null) {
        throw Exception("Customer not found.");
      }

      final saleNo = Helpers.getSaleDocumentNo(
        scheduleId: arg.schedule.id,

        documentType: arg.documentType,
      );

      final getSaleLines = await _taskRepos.getPosSaleLines(
        params: {'document_type': arg.documentType, 'document_no': saleNo},
      );

      List<PosSalesLine> lines = getSaleLines.fold((l) => [], (r) => r);

      final canDiscount = await hasPermission(kManualSellingDiscount);
      final canModifyPrice = await hasPermission(kManualSellingPrice);

      final String itemNo = arg.item.no;
      double manualPrice = 0;
      String salesUomCode = arg.item.salesUomCode ?? "";
      double unitPrice = Helpers.toDouble(arg.item.unitPrice);

      if (lines.isNotEmpty) {
        int rIndex = lines.indexWhere((e) {
          return e.no == itemNo && e.specialType == kPromotionTypeStd;
        });

        if (rIndex != -1) {
          unitPrice = Helpers.toDouble(lines[rIndex].unitPrice);
        }
      }

      emit(state.copyWith(itemUnitPrice: unitPrice));

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

          if (form.code == kPromotionTypeStd) {
            stdSaleLine = lines[rIndex];
            manualPrice = Helpers.formatNumberDb(lines[rIndex].manualUnitPrice);
          }
        }

        if (uomCode.isEmpty) {
          uomCode = arg.item.salesUomCode ?? "";
        }

        if (form.code == kPromotionTypeStd) {
          _updateItemPrice(
            uomCode: form.uomCode,
            orderQty: Helpers.toStrings(quantity),
          );
        }

        return form.copyWith(quantity: quantity, uomCode: uomCode);
      }).toList();

      // double unitPrice = Helpers.toDouble(arg.item.unitPrice);
      // if (lines.isNotEmpty) {
      //   int rIndex = lines.indexWhere((e) {
      //     return e.no == itemNo && e.specialType == kPromotionTypeStd;
      //   });

      //   if (rIndex != -1) {
      //     unitPrice = Helpers.toDouble(lines[rIndex].unitPrice);
      //   }
      // }

      // print("print(unitPrice)");
      // print(unitPrice);
      // print("print(unitPrice)");

      emit(
        state.copyWith(
          isLoading: false,
          canDiscount: canDiscount,
          canModifyPrice: canModifyPrice,
          customer: customer,
          schedule: arg.schedule,
          item: arg.item,
          itemUnitPrice: unitPrice,
          documentType: arg.documentType,
          saleLines: lines,
          saleForm: updatedForms,
          manualPrice: manualPrice,
          saleUomCode: salesUomCode,
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
      final itemUomResponse = await _taskRepos.getItemUom(
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
          // saleUomCode: uomCode,
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
        // saleUomCode: uomCode,
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

    final salePriceResult = await _taskRepos.getItemSaleLinePrice(
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
      final groupPriceResult = await _taskRepos.getItemSaleLinePrice(
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
      final allCustomersPriceResult = await _taskRepos.getItemSaleLinePrice(
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
      final result = await _taskRepos.insertSale(saleData);

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

  SaleArg _prepareSaleData() {
    final item = state.item;

    if (item == null) {
      throw GeneralException("Item cannot empty");
    }

    if (state.schedule == null) {
      throw GeneralException("Schedule cannot empty");
    }

    final inputs = state.saleForm.where((form) {
      return form.quantity > 0;
    }).toList();

    if (inputs.isEmpty) {
      throw GeneralException('No items with quantity found');
    }

    if (item.preventNegativeInventory != kStatusNo &&
        state.documentType != kSaleCreditMemo) {
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

    return SaleArg(
      item: item,
      schedule: state.schedule!,
      inputs: inputs,
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
