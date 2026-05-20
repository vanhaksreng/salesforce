import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/features/auth/domain/entities/login_arg.dart';
import 'package:salesforce/features/auth/domain/repositories/auth_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

/// Printer size options
enum PrinterSize {
  mm80('80mm', '80'),
  mm58('58mm', '58');

  const PrinterSize(this.label, this.value);
  final String label;
  final String value;
}

/// Callback invoked when the user confirms the printer setup.
/// [address]     – Bluetooth MAC address of the selected device.
/// [deviceName]  – Human-readable device name.
/// [printerSize] – Chosen paper width ('80' or '58').
typedef OnPrinterConfirmed = void Function({
  required String address,
  required String deviceName,
  required String printerSize,
});

class BluetoothListWidget extends StatefulWidget {
  const BluetoothListWidget({
    super.key,
    required this.devices,
    required this.printerConfig,
    this.onConfirm,
  });

  final List<Map<String, dynamic>> devices;

  /// Optional callback fired when the user presses "Connect & Save".
  final OnPrinterConfirmed? onConfirm;
  final DevicePrinter? printerConfig;

  @override
  State<BluetoothListWidget> createState() => _BlueToothDialogState();
}

class _BlueToothDialogState extends State<BluetoothListWidget> {
  static const _primary = Color(0xFF4A1A8D);
  // static const _accent = Color(0xFF2979FF);
  static const _errorRed = Color(0xFFE53935);
  static const _textDark = Color(0xFF1A1A2E);
  static const _textMuted = Color(0xFF8E8E9A);

  PrinterSize _selectedSize = PrinterSize.mm80;

  String? _selectedAddress;
  String? _selectedDeviceName;

  /// Device address that has been confirmed / connected.
  String? _connectedDevice;

  bool _isConnecting = false;
  String? _errorMessage;

  @override
  initState() {
    super.initState();
    _initializeState();
  }

  void _initializeState() {
    if (widget.printerConfig != null) {
      _selectedAddress = widget.printerConfig!.macAddress;
      _selectedDeviceName = widget.printerConfig!.deviceName;
      _connectedDevice = widget.printerConfig!.macAddress;
      _selectedSize = widget.printerConfig!.paperSize.toInt().toString() == "58"
          ? PrinterSize.mm58
          : PrinterSize.mm80;
    }

    print("Initialized BluetoothListWidget with address: $_selectedAddress, deviceName: $_selectedDeviceName, paperSize: ${_selectedSize.value}");
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.18),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          // Constrain height so the dialog stays on-screen on smaller phones.
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPrinterSizeCard(),
                  const SizedBox(height: 16),
                  _buildBluetoothCard(),
                ],
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            _buildErrorBanner(),
          ],
          const SizedBox(height: 20),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.print_rounded,
            color: _primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Setup Printer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textDark,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'POS Receipt Printer',
              style: TextStyle(
                fontSize: 13,
                color: _textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrinterSizeCard() {
    return _buildCard(
      title: 'ទំហំក្រដាស / Paper Size',
      icon: Icons.straighten_rounded,
      child: Row(
        children: PrinterSize.values
            .map((size) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: size == PrinterSize.mm80 ? 8 : 0,
                    ),
                    child: _buildSizeToggle(size),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSizeToggle(PrinterSize size) {
    final isSelected = _selectedSize == size;
    return GestureDetector(
      onTap: () => setState(() => _selectedSize = size),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _primary : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 22,
              color: isSelected ? Colors.white : _textMuted,
            ),
            const SizedBox(height: 6),
            Text(
              size.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : _textDark,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBluetoothCard() {
    return _buildCard(
      title: 'Bluetooth',
      icon: Icons.bluetooth_rounded,
      child: widget.devices.isEmpty
          ? _buildEmptyDevices()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ឧបករណ៍ដែលរកឃើញ:',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'KhmerOS',
                    color: _textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.devices.map(_buildDeviceItem),
              ],
            ),
    );
  }

  Widget _buildEmptyDevices() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bluetooth_disabled_rounded,
              size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Text(
            'រកមិនឃើញឧបករណ៍',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'KhmerOS',
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(Map<String, dynamic> d) {
    final address = d['address'] as String? ?? '';
    final name = d['name'] as String? ?? 'Unknown';
    final isConnected = _connectedDevice == address;
    final isSelected = _selectedAddress == address;

    return GestureDetector(
      onTap: () {
        if (!isConnected) {
          setState(() {
            _selectedAddress = address;
            _selectedDeviceName = name;
            _errorMessage = null;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isConnected
                ? Colors.green.shade400
                : isSelected
                    ? _primary
                    : Colors.grey.shade200,
            width: (isConnected || isSelected) ? 2 : 1,
          ),
          color: isConnected
              ? Colors.green.shade50
              : isSelected
                  ? _primary.withValues(alpha: 0.05)
                  : Colors.white,
        ),
        child: ListTile(
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isConnected
                  ? Colors.green.shade100
                  : isSelected
                      ? _primary.withValues(alpha: 0.12)
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.print_rounded,
              size: 17,
              color: isConnected
                  ? Colors.green.shade700
                  : isSelected
                      ? _primary
                      : Colors.grey.shade500,
            ),
          ),
          title: Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isConnected
                  ? Colors.green.shade800
                  : isSelected
                      ? _primary
                      : _textDark,
            ),
          ),
          subtitle: Text(
            address,
            style: const TextStyle(fontSize: 11, color: _textMuted),
          ),
          trailing: isConnected
              ? const Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 20)
              : isSelected
                  ? Icon(Icons.radio_button_checked_rounded,
                      color: _primary, size: 20)
                  : Icon(Icons.radio_button_unchecked_rounded,
                      color: Colors.grey.shade400, size: 20),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _errorRed.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 16, color: _errorRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                  fontSize: 12,
                  color: _errorRed,
                  fontFamily: 'KhmerOS'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final canConfirm = _selectedAddress != null && !_isConnecting;

    return Row(
      children: [
        // Cancel
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: _textMuted,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'បោះបង់',
              style: TextStyle(fontFamily: 'KhmerOS', fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Confirm
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: canConfirm ? _handleConfirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade200,
              disabledForegroundColor: Colors.grey.shade400,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isConnecting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Connect & Save',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleConfirm() async {
    if (_selectedAddress == null) {
      setState(() =>
          _errorMessage = 'សូមជ្រើសរើសឧបករណ៍ Bluetooth មុនសិន');
      return;
    }

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      // ── Your actual connection logic goes here ──────────────────────
      // e.g. await _bluetoothService.connect(_selectedAddress!);
      // ───────────────────────────────────────────────────────────────

      // Simulate async work during development.
      await Future.delayed(const Duration(milliseconds: 600));

      setState(() => _connectedDevice = _selectedAddress);

      widget.onConfirm?.call(
        address: _selectedAddress!,
        deviceName: _selectedDeviceName ?? 'Unknown',
        printerSize: _selectedSize.value,
      );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _errorMessage = 'មិនអាចតភ្ជាប់បានទេ: $e');
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                Icon(icon, size: 16, color: _textDark),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    fontFamily: 'KhmerOS',
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: child,
          ),
        ],
      ),
    );
  }
}