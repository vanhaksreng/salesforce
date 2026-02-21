import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

extension PosSalesHeaderExtension on PosSalesHeader {
  static PosSalesHeader fromMap(Map<String, dynamic> json) {
    return PosSalesHeader(
      json['id'] ?? 0,
      no: json['no'] as String? ?? '',
      documentType: json['document_type'] as String? ?? '',
      customerNo: json['customer_no'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      customerName2: json['customer_name_2'] as String? ?? '',
      customerGroupCode: json['customer_group_code'] as String? ?? '',
      locationCode: json['location_code'] as String? ?? '',
      address: json['address'] as String? ?? '',
      address2: json['address_2'] as String? ?? '',
      shipToName: json['ship_to_name'] as String? ?? '',
      shipToName2: json['ship_to_name_2'] as String? ?? '',
      shipToAddress: json['ship_to_address'] as String? ?? '',
      shipToAddress2: json['ship_to_address_2'] as String? ?? '',
      shipToPhoneNo: json['ship_to_phone_no'] as String? ?? '',
      shipToPhoneNo2: json['ship_to_phone_no_2'] as String? ?? '',
      documentDate: json['document_date'],
      postingDate: json['posting_date'],
      requestShipmentDate: json['request_shipment_date'],
      postingDescription: json['posting_description'] as String? ?? '',
      paymentTermCode: json['payment_term_code'] as String? ?? '',
      paymentMethodCode: json['payment_method_code'] as String? ?? '',
      currencyCode: json['currency_code'] as String? ?? '',
      currencyFactor: Helpers.toDouble(json['currency_factor']),
      priceIncludeVat: json['price_include_vat'] as String? ?? '',
      salespersonCode: json['salesperson_code'] as String? ?? '',
      distributorCode: json['distributor_code'] as String? ?? '',
      storeCode: json['store_code'] as String? ?? '',
      businessUnitCode: json['business_unit_code'] as String? ?? '',
      departmentCode: json['department_code'] as String? ?? '',
      projectCode: json['project_code'] as String? ?? '',
      externalDocumentNo: json['external_document_no'] as String? ?? '',
      sourceType: json['source_type'] as String? ?? '',
      sourceNo: json['source_no'] as String? ?? '',
      status: json['status'] as String? ?? '',
      amount: Helpers.formatNumberDb(
        json['total_amount'],
        option: FormatType.amount,
      ),
      orderDate: json["order_date"] as String? ?? '',
    );
  }

  static PosSalesHeader toObj({
    required String documentNo,
    required Customer customer,
    required UserSetup userSetup,
    required String documentType,
    SalespersonSchedule? schedule,
    String storeCode = "",
    String divisionCode = "",
    String businessUnitCode = "",
    String departmentCode = "",
    String projectCode = "",
  }) {
    final int headerId = Helpers.generateUniqueNumber();
    final String today = DateTime.now().toDateString();

    return PosSalesHeader(
      headerId,
      no: documentNo,
      locationCode: userSetup.locationCode,
      salespersonCode: userSetup.salespersonCode,
      documentType: documentType,
      customerNo: customer.no,
      customerName: customer.name,
      customerName2: customer.name2,
      address: customer.address,
      address2: customer.address2,
      shipToName: customer.name,
      shipToName2: customer.name2,
      shipToAddress: customer.address,
      shipToAddress2: customer.address2,
      shipToContactName: customer.contactName,
      shipToPhoneNo: customer.phoneNo,
      shipToPhoneNo2: customer.phoneNo2,
      arPostingGroupCode: customer.recPostingGroupCode,
      genBusPostingGroupCode: customer.genBusPostingGroupCode,
      vatBusPostingGroupCode: customer.vatPostingGroupCode,
      priceIncludeVat: customer.priceIncludeVat,
      paymentTermCode: customer.paymentTermCode,
      orderDate: today,
      documentDate: today,
      postingDate: today,
      status: kStatusOpen,
      storeCode: storeCode,
      divisionCode: divisionCode,
      businessUnitCode: businessUnitCode,
      departmentCode: departmentCode,
      projectCode: projectCode,
      sourceType: kSourceTypeVisit,
      sourceNo: schedule?.id ?? "",
      currencyCode: "",
      currencyFactor: 1,
    );
  }
}
