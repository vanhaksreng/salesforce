import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:salesforce/features/more/presentation/pages/imin_device/imin_printer_service.dart';

class ReceiptPreviewWidget extends StatelessWidget {
  final String? companyName;
  final String? companyAddress;
  final String? companyPhone;
  final String? invoiceNo;
  final String? date;
  final String? customerName;
  final List<ReceiptItem> items;
  final String? totalAmount;
  final Uint8List? logoBytes;

  const ReceiptPreviewWidget({
    super.key,
    this.companyName,
    this.companyAddress,
    this.companyPhone,
    this.invoiceNo,
    this.date,
    this.customerName,
    required this.items,
    this.totalAmount,
    this.logoBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 384, // 58mm paper width
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo
          if (logoBytes != null)
            Center(
              child: Image.memory(
                logoBytes!,
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          if (logoBytes != null) const SizedBox(height: 8),

          // Company Name
          if (companyName != null)
            Text(
              companyName!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSansKhmer',
              ),
              textAlign: TextAlign.center,
            ),
          if (companyName != null) const SizedBox(height: 4),

          // Company Address
          if (companyAddress != null)
            Text(
              companyAddress!,
              style: const TextStyle(fontSize: 14, fontFamily: 'NotoSansKhmer'),
              textAlign: TextAlign.center,
            ),
          if (companyAddress != null) const SizedBox(height: 4),

          // Company Phone
          if (companyPhone != null)
            Text(
              'Phone: $companyPhone',
              style: const TextStyle(fontSize: 14, fontFamily: 'NotoSansKhmer'),
              textAlign: TextAlign.center,
            ),
          if (companyPhone != null) const SizedBox(height: 8),

          // Separator
          const Divider(color: Colors.black, thickness: 1),

          // Invoice Details
          if (invoiceNo != null) _buildInfoRow('Invoice', invoiceNo!),
          if (date != null) _buildInfoRow('Date', date!),
          if (customerName != null) _buildInfoRow('Customer', customerName!),

          const SizedBox(height: 8),
          const Divider(color: Colors.black, thickness: 1),

          // Table Headers - Khmer
          _buildTableHeader(
            no: 'ល.រ',
            item: 'ឈ្មោះទំនិញ',
            qty: 'ចំនួន',
            price: 'តម្លៃ',
            disc: 'ចុះតម្លៃ',
            total: 'សរុប',
          ),

          // Table Headers - English
          _buildTableHeader(
            no: 'No.',
            item: 'Item',
            qty: 'Qty',
            price: 'Price',
            disc: 'Disc',
            total: 'Total',
          ),

          const Divider(color: Colors.black, thickness: 1),

          // Items
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _buildItemRow(
                  no: '${index + 1}',
                  item: item.item,
                  qty: item.qty,
                  price: item.price,
                  disc: item.disc,
                  total: item.total,
                ),
                if (index < items.length - 1)
                  const Divider(color: Colors.grey, thickness: 0.5, height: 8),
              ],
            );
          }),

          const Divider(color: Colors.black, thickness: 1),

          // Total
          if (totalAmount != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'TOTAL AMOUNT: $totalAmount',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansKhmer',
                ),
                textAlign: TextAlign.right,
              ),
            ),

          const SizedBox(height: 16),

          // Footer Message
          const Text(
            'Thank you for your business!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSansKhmer',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Please come again',
            style: TextStyle(fontSize: 14, fontFamily: 'NotoSansKhmer'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 14, fontFamily: 'NotoSansKhmer'),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontFamily: 'NotoSansKhmer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader({
    required String no,
    required String item,
    required String qty,
    required String price,
    required String disc,
    required String total,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              no,
              style: const TextStyle(fontSize: 12, fontFamily: 'NotoSansKhmer'),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item,
              style: const TextStyle(fontSize: 12, fontFamily: 'NotoSansKhmer'),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              qty,
              style: const TextStyle(fontSize: 12, fontFamily: 'NotoSansKhmer'),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              price,
              style: const TextStyle(fontSize: 12, fontFamily: 'NotoSansKhmer'),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              disc,
              style: const TextStyle(fontSize: 12, fontFamily: 'NotoSansKhmer'),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              total,
              style: const TextStyle(fontSize: 12, fontFamily: 'NotoSansKhmer'),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow({
    required String no,
    required String item,
    required String qty,
    required String price,
    required String disc,
    required String total,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Text(
              no,
              style: const TextStyle(fontSize: 11, fontFamily: 'NotoSansKhmer'),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item,
              style: const TextStyle(fontSize: 11, fontFamily: 'NotoSansKhmer'),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              qty,
              style: const TextStyle(fontSize: 11, fontFamily: 'NotoSansKhmer'),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              price,
              style: const TextStyle(fontSize: 11, fontFamily: 'NotoSansKhmer'),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              disc,
              style: const TextStyle(fontSize: 11, fontFamily: 'NotoSansKhmer'),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              total,
              style: const TextStyle(fontSize: 11, fontFamily: 'NotoSansKhmer'),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
