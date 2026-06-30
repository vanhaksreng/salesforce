import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/constants/app_setting.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/mixins/permission_mixin.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/tasks/domain/entities/checkout_arg.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/features/tasks/presentation/pages/sale_components/sale_checkout/sale_checkout_state.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class SaleCheckoutCubit extends Cubit<SaleCheckoutState>
    with PermissionMixin, MessageMixin, AppMixin {
  SaleCheckoutCubit() : super(const SaleCheckoutState(isLoading: true));

  final _taskRepo = getIt<TaskRepository>();

  CustomerAddress? _defaultShipment;

  Future<void> loadInitialData(CheckoutArg arg) async {
    try {
      final PosSalesHeader header = arg.salesHeader;

      final hidePayment = await getSetting(kHidePaymentInv);
      final showPaymentDis = await getSetting(kShowPaymentDis);
      final showPaymentInputOnSaleOrder = await getAppSetting(
        kKabasPaymentDisPercent,
      );

      final result = await _taskRepo.getCustomer(no: header.customerNo ?? "");
      final customer = result.fold(
        (l) => throw GeneralException(l.message),
        (customer) => customer,
      );

      _defaultShipment = CustomerAddress(
        "_init_",
        code: header.shipToCode,
        name: header.shipToName,
        address: header.shipToAddress,
        address2: header.shipToAddress2,
        phoneNo: header.shipToPhoneNo,
        phoneNo2: header.shipToPhoneNo2,
      );

      emit(
        state.copyWith(
          isLoading: false,
          saleHeaser: header,
          shipmentAddress: _defaultShipment,
          hidePayment: hidePayment == kStatusYes,
          showPaymentDis: showPaymentDis == kStatusYes,
          showPaymentInputOnSaleOrder:
              showPaymentInputOnSaleOrder == kStatusYes,
          amountToPay: arg.amountDue,
          customer: customer,
        ),
      );

      calcPaymentDiscount(
        arg,
        Helpers.toDouble(customer?.defaultDiscountPercent),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> calcPaymentDiscount(CheckoutArg arg, double disPercent) async {
    final disAmt = Helpers.formatNumberDb(
      arg.amountDue * (disPercent / 100),
      option: FormatType.amount,
    );

    emit(
      state.copyWith(
        paymentDiscountAmt: disAmt,
        paymentDiscountPercent: disPercent,
        amountToPay: Helpers.formatNumberDb(
          arg.amountDue - disAmt,
          option: FormatType.amount,
        ),
      ),
    );
  }

  Future<void> calcPaymentDiscountAmt(CheckoutArg arg, double disAmt) async {
    final amountDue = Helpers.formatNumberDb(
      arg.amountDue,
      option: FormatType.amount,
    );

    final disPercent = (disAmt / amountDue) * 100;

    if (amountDue < disAmt) {
      showWarningMessage('Value cannot be greater than $amountDue');
    }

    emit(
      state.copyWith(
        amountToPay: Helpers.formatNumberDb(
          amountDue - disAmt,
          option: FormatType.amount,
        ),
        paymentDiscountPercent: Helpers.formatNumberDb(
          disPercent,
          option: FormatType.percentage,
        ),
        paymentDiscountAmt: disAmt,
      ),
    );
  }

  Future<void> getDefaultPaymentType() async {
    await _taskRepo.getPaymentMethod();
  }

  Future<void> getDefaultPaymentTerm(String termCode) async {
    await _taskRepo.getPaymentTerm(param: {'code': termCode}).then((response) {
      response.fold((l) => throw GeneralException(l.message), (r) {
        changePaymentTerm(r);
      });
    });
  }

  void changeShipmentAddress(CustomerAddress shipmentAddress) {
    emit(state.copyWith(shipmentAddress: shipmentAddress));
  }

  void changePaymentMethod(PaymentMethod paymentMethod) {
    emit(state.copyWith(paymentMethod: paymentMethod));
  }

  void changePaymentTerm(PaymentTerm? paymentTerm) {
    emit(state.copyWith(paymentTerm: paymentTerm));
  }

  void clearTextFromField(TextEditingController data) {
    data.clear();
    emit(
      state.copyWith(
        distributCtr: TextEditingController(text: ""),
        codeDis: "",
      ),
    );
  }

  void setDistribute(String codeDis) {
    emit(state.copyWith(codeDis: codeDis));
  }

  Future<bool> processCheckout(CheckoutSubmitArg arg) async {
    final result = await _taskRepo.processCheckout(arg);
    return await result.fold((l) {
      showErrorMessage(l.message);
      return false;
    }, (r) => true);
  }

  void onPickDate(DateTime date) {
    emit(state.copyWith(pickDate: date));
  }

  Future<void> getCustomerLedgerEntry(String customerNo) async {
    try {
      final response = await _taskRepo.getCustomerLedgerEntry(
        param: {"customer_no": customerNo},
      );

      response.fold((l) => throw GeneralException(l.message), (r) {
        emit(state.copyWith(customerLedgerEntries: r));
      });
    } on GeneralException catch (e) {
      showWarningMessage(e.message);
    } on Exception {
      showErrorMessage();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
