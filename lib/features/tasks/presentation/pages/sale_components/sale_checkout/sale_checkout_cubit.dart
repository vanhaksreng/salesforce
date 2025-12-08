import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/mixins/app_mixin.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/mixins/permission_mixin.dart';
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

  Future<void> loadInitialData(PosSalesHeader saleHeaser) async {
    try {
      _taskRepo.getCustomer(no: saleHeaser.customerNo ?? "").then((response) {
        response.fold((l) => throw GeneralException(l.message), (customer) {
          emit(state.copyWith(customer: customer));
        });
      });

      _defaultShipment = CustomerAddress(
        "_init_",
        code: saleHeaser.shipToCode,
        name: saleHeaser.shipToName,
        address: saleHeaser.shipToAddress,
        address2: saleHeaser.shipToAddress2,
        phoneNo: saleHeaser.shipToPhoneNo,
        phoneNo2: saleHeaser.shipToPhoneNo2,
      );

      emit(
        state.copyWith(
          isLoading: false,
          saleHeaser: saleHeaser,
          shipmentAddress: _defaultShipment,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false));
    }
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
