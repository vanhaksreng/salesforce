import 'dart:typed_data';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/thermal_printer.dart';

enum ReceiptCommandType { text, image, feedPaper, cutPaper, row, separator }

// Receipt command model
class ReceiptCommand {
  final ReceiptCommandType type;
  final Map<String, dynamic> params;

  ReceiptCommand(this.type, this.params);
}

// Receipt builder to collect commands
class ReceiptBuilder {
  final List<ReceiptCommand> _commands = [];

  List<ReceiptCommand> get commands => List.unmodifiable(_commands);

  void addText(
    String text, {
    int fontSize = 24,
    int maxCharPerLine = 32,
    bool bold = false,
    AlignStyle align = AlignStyle.left,
  }) {
    _commands.add(
      ReceiptCommand(ReceiptCommandType.text, {
        'text': text,
        'fontSize': fontSize,
        'bold': bold,
        'maxCharsPerLine': maxCharPerLine,
        'align': align.value,
      }),
    );
  }

  void printImage(Uint8List imageBytes, {int width = 384}) {
    _commands.add(
      ReceiptCommand(ReceiptCommandType.image, {
        'imageBytes': imageBytes,
        'width': width,
      }),
    );
  }

  void feedPaper(int lines) {
    _commands.add(
      ReceiptCommand(ReceiptCommandType.feedPaper, {'lines': lines}),
    );
  }

  void cutPaper() {
    _commands.add(ReceiptCommand(ReceiptCommandType.cutPaper, {}));
  }

  void clear() {
    _commands.clear();
  }

  void addRow(
    List<PosColumn> columns, {
    int fontSize = 22,
    bool autoAdjust = false, // Auto-adjust widths to equal 12
  }) {
    // Validate columns is not empty
    if (columns.isEmpty) {
      throw Exception('Columns list cannot be empty');
    }

    List<PosColumn> finalColumns = columns;

    // Calculate total width
    final totalWidth = columns.fold<int>(0, (sum, col) => sum + col.width);

    if (autoAdjust && totalWidth != 12) {
      // Auto-adjust column widths proportionally
      finalColumns = _adjustColumnWidths(columns);
    } else if (totalWidth != 12) {
      throw Exception(
        'Total column width must equal 12, got $totalWidth. '
        'Current widths: ${columns.map((c) => c.width).join(", ")}. '
        'Set autoAdjust: true to fix automatically.',
      );
    }

    // Validate individual column widths
    for (var i = 0; i < finalColumns.length; i++) {
      final col = finalColumns[i];
      if (col.width <= 0 || col.width > 12) {
        throw Exception(
          'Column $i width must be between 1 and 12, got ${col.width}',
        );
      }
    }

    _commands.add(
      ReceiptCommand(ReceiptCommandType.row, {
        'columns': finalColumns.map((col) => col.toMap()).toList(),
        'fontSize': fontSize,
      }),
    );
  }

  // Helper method to adjust column widths proportionally
  List<PosColumn> _adjustColumnWidths(List<PosColumn> columns) {
    final totalWidth = columns.fold<int>(0, (sum, col) => sum + col.width);

    if (totalWidth == 12) return columns;

    final adjustedColumns = <PosColumn>[];
    var remainingWidth = 12;

    for (var i = 0; i < columns.length; i++) {
      final col = columns[i];

      if (i == columns.length - 1) {
        // Last column gets remaining width
        adjustedColumns.add(col.copyWith(width: remainingWidth));
      } else {
        // Proportional adjustment
        final newWidth = ((col.width / totalWidth) * 12).round().clamp(1, 12);
        adjustedColumns.add(col.copyWith(width: newWidth));
        remainingWidth -= newWidth;
      }
    }

    return adjustedColumns;
  }

  void addSeparator({int width = 48}) {
    _commands.add(
      ReceiptCommand(ReceiptCommandType.separator, {'width': width}),
    );
  }
}

extension SmoothPrinting on ReceiptBuilder {
  Future<void> executeSmooth(
    Type printerClass, {
    Duration delayBetweenCommands = const Duration(milliseconds: 250),
    Duration delayAfterImage = const Duration(milliseconds: 200),
  }) async {
    for (int i = 0; i < _commands.length; i++) {
      final command = _commands[i];

      try {
        switch (command.type) {
          case ReceiptCommandType.text:
            await ThermalPrinter.printText(
              command.params['text'] as String,
              fontSize: command.params['fontSize'] as int? ?? 24,
              bold: command.params['bold'] as bool? ?? false,
              align: command.params['align'] as String? ?? 'left',
              maxCharPerLine: command.params['maxCharsPerLine'] as int? ?? 0,
            );
            break;

          case ReceiptCommandType.image:
            await ThermalPrinter.printImage(
              command.params['imageBytes'] as Uint8List,
              width: command.params['width'] as int? ?? 384,
            );
            // Extra delay after images
            await Future.delayed(delayAfterImage);
            break;

          case ReceiptCommandType.feedPaper:
            await ThermalPrinter.feedPaper(command.params['lines'] as int);
            break;

          case ReceiptCommandType.cutPaper:
            await ThermalPrinter.cutPaper();
            break;

          case ReceiptCommandType.row:
            await ThermalPrinter.printRow(
              columns: command.params['columns'] as List<Map<String, dynamic>>,
              fontSize: command.params['fontSize'] as int? ?? 24,
            );
            break;

          case ReceiptCommandType.separator:
            await ThermalPrinter.printSeparator(
              width: command.params['width'] as int,
            );
            break;
        }

        // CRITICAL: Wait between commands to prevent motor overload
        if (i < _commands.length - 1) {
          await Future.delayed(delayBetweenCommands);
        }
      } catch (e) {
        rethrow;
      }
    }
  }

  /// Execute commands in batches with delays between batches
  /// Useful for very large receipts
  Future<void> executeBatched(
    Type printerClass, {
    int batchSize = 5,
    Duration delayBetweenBatches = const Duration(milliseconds: 200),
  }) async {
    for (
      int batchStart = 0;
      batchStart < _commands.length;
      batchStart += batchSize
    ) {
      final batchEnd = (batchStart + batchSize).clamp(0, _commands.length);
      final batch = _commands.sublist(batchStart, batchEnd);

      for (final command in batch) {
        switch (command.type) {
          case ReceiptCommandType.text:
            await ThermalPrinter.printText(
              command.params['text'] as String,
              fontSize: command.params['fontSize'] as int? ?? 24,
              bold: command.params['bold'] as bool? ?? false,
              align: command.params['align'] as String? ?? 'left',
              maxCharPerLine: command.params['maxCharsPerLine'] as int? ?? 0,
            );
            break;

          case ReceiptCommandType.image:
            await ThermalPrinter.printImage(
              command.params['imageBytes'] as Uint8List,
              width: command.params['width'] as int? ?? 384,
            );
            break;

          case ReceiptCommandType.feedPaper:
            await ThermalPrinter.feedPaper(command.params['lines'] as int);
            break;

          case ReceiptCommandType.cutPaper:
            await ThermalPrinter.cutPaper();
            break;

          case ReceiptCommandType.row:
            await ThermalPrinter.printRow(
              columns: command.params['columns'] as List<Map<String, dynamic>>,
              fontSize: command.params['fontSize'] as int? ?? 24,
            );
            break;
          case ReceiptCommandType.separator:
            await ThermalPrinter.printSeparator(
              width: command.params['width'] as int,
            );
            break;
        }
      }

      // Delay between batches
      if (batchEnd < _commands.length) {
        await Future.delayed(delayBetweenBatches);
      }
    }
  }

  Future<void> executeBatch(Type printerClass) async {
    try {
      await ThermalPrinter.startBatch();

      for (int i = 0; i < _commands.length; i++) {
        final command = _commands[i];

        try {
          switch (command.type) {
            case ReceiptCommandType.text:
              await ThermalPrinter.printText(
                command.params['text'] as String,
                fontSize: command.params['fontSize'] as int? ?? 24,
                bold: command.params['bold'] as bool? ?? false,
                align: command.params['align'] as String? ?? 'left',
                maxCharPerLine: command.params['maxCharsPerLine'] as int? ?? 0,
              );
              break;

            case ReceiptCommandType.image:
              await ThermalPrinter.printImage(
                command.params['imageBytes'] as Uint8List,
                width: command.params['width'] as int? ?? 384,
              );
              break;

            case ReceiptCommandType.feedPaper:
              await ThermalPrinter.feedPaper(command.params['lines'] as int);
              break;

            case ReceiptCommandType.cutPaper:
              await ThermalPrinter.cutPaper();
              break;

            case ReceiptCommandType.row:
              await ThermalPrinter.printRow(
                columns:
                    command.params['columns'] as List<Map<String, dynamic>>,
                fontSize: command.params['fontSize'] as int? ?? 24,
              );
              break;
            case ReceiptCommandType.separator:
              await ThermalPrinter.printSeparator(
                width: command.params['width'] as int,
              );
              break;
          }
        } catch (e) {
          rethrow;
        }
      }

      await ThermalPrinter.endBatch();
    } catch (e) {
      try {
        await ThermalPrinter.endBatch();
      } catch (_) {}
      rethrow;
    }
  }
}

// ====================================================================
// CONFIGURATION PRESETS
// ====================================================================

class PrintConfig {
  // Fast printing (may cause stuck sound on slow printers)
  static const fast = (
    delayBetweenCommands: Duration(milliseconds: 30),
    delayAfterImage: Duration(milliseconds: 50),
  );

  // Normal printing (recommended for most printers)
  static const normal = (
    delayBetweenCommands: Duration(milliseconds: 50),
    delayAfterImage: Duration(milliseconds: 100),
  );

  // Slow printing (guaranteed smooth for all printers)
  static const slow = (
    delayBetweenCommands: Duration(milliseconds: 100),
    delayAfterImage: Duration(milliseconds: 200),
  );

  // Ultra slow (for very old/problematic printers)
  static const ultraSlow = (
    delayBetweenCommands: Duration(milliseconds: 150),
    delayAfterImage: Duration(milliseconds: 300),
  );
}
