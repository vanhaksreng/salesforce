import 'package:flutter/material.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'dart:typed_data';

import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/receipt_builder.dart';

class ReceiptPreview extends StatelessWidget {
  final List<ReceiptCommand> commands;
  final int paperWidth;
  final Color paperColor;
  final Color textColor;

  const ReceiptPreview({
    super.key,
    required this.commands,
    this.paperWidth = 300,
    this.paperColor = Colors.white,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Helpers.toDouble(paperWidth == 384 ? 300 : 576),
      decoration: BoxDecoration(
        color: paperColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: commands.map((command) => _buildCommand(command)).toList(),
        ),
      ),
    );
  }

  Widget _buildCommand(ReceiptCommand command) {
    switch (command.type) {
      case ReceiptCommandType.text:
        return _buildText(command.params);

      case ReceiptCommandType.image:
        return _buildImage(command.params);

      case ReceiptCommandType.feedPaper:
        return _buildFeedPaper(command.params);

      case ReceiptCommandType.row:
        return _buildRow(command.params);

      case ReceiptCommandType.separator:
        return _buildSeparator(command.params);

      case ReceiptCommandType.cutPaper:
        return _buildCutPaper();
    }
  }

  Widget _buildText(Map<String, dynamic> params) {
    String text = params['text'] as String? ?? '';
    final fontSize = params['fontSize'] as int? ?? 24;
    final bold = params['bold'] as bool? ?? false;
    final align = params['align'] as String? ?? 'left';
    final maxCharsPerLine = params['maxCharsPerLine'] as int? ?? 32;

    if (text == "-" * 31) {
      text = List.filled(2, "-" * 18).join(); // repeat "-" 20 times
    }
    double displayFontSize;
    if (fontSize <= 20) {
      displayFontSize = 12.0;
    } else if (fontSize <= 24) {
      displayFontSize = 12.0;
    } else if (fontSize <= 28) {
      displayFontSize = 14.0;
    } else if (fontSize <= 32) {
      displayFontSize = 16.0;
    } else {
      displayFontSize = 18.0;
    }

    // Handle text wrapping based on maxCharsPerLine
    String displayText = text;
    if (maxCharsPerLine > 0 && text.length > maxCharsPerLine) {
      final words = text.split(' ');
      final lines = <String>[];
      String currentLine = '';

      for (final word in words) {
        if (('$currentLine $word').trim().length <= maxCharsPerLine) {
          currentLine = ('$currentLine $word').trim();
        } else {
          if (currentLine.isNotEmpty) lines.add(currentLine);
          currentLine = word;
        }
      }
      if (currentLine.isNotEmpty) lines.add(currentLine);
      displayText = lines.join('\n');
    }

    TextAlign textAlign;
    switch (align) {
      case 'center':
        textAlign = TextAlign.center;
        break;
      case 'right':
        textAlign = TextAlign.right;
        break;
      default:
        textAlign = TextAlign.left;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Text(
        displayText,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: displayFontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.bold,
          color: textColor,
          fontFamily: 'Courier',
          letterSpacing: 0,
          height: 0,
          fontFamilyFallback: const ['Courier', 'monospace'],
        ),
      ),
    );
  }

  Widget _buildImage(Map<String, dynamic> params) {
    final imageBytes = params['imageBytes'] as Uint8List?;
    // final width = (params['width'] as int? ?? 384).toDouble();

    if (imageBytes == null) {
      return Container(
        width: paperWidth - 24,
        height: 80,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image, size: 32, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Center(
        child: Image.memory(
          imageBytes,
          width: paperWidth - 400,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildFeedPaper(Map<String, dynamic> params) {
    final lines = params['lines'] as int? ?? 1;
    return SizedBox(height: lines * 16.0);
  }

  Widget _buildRow(Map<String, dynamic> params) {
    final columns = params['columns'] as List<dynamic>? ?? [];
    final fontSize = params['fontSize'] as int? ?? 22;

    // Map font size to display size
    double displayFontSize;
    if (fontSize <= 20) {
      displayFontSize = 7;
    } else if (fontSize <= 24) {
      displayFontSize = 11.0;
    } else if (fontSize <= 28) {
      displayFontSize = 13.0;
    } else {
      displayFontSize = 15.0;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns.map((col) {
          final colMap = col as Map<String, dynamic>;
          final text = colMap['text'] as String? ?? '';
          final width = colMap['width'] as int? ?? 4;
          final align = colMap['align'] as String? ?? 'left';
          final bold = colMap['bold'] as bool? ?? false;

          TextAlign textAlign;
          switch (align) {
            case 'center':
              textAlign = TextAlign.center;
              break;
            case 'right':
              textAlign = TextAlign.right;
              break;
            default:
              textAlign = TextAlign.left;
          }
          bool isEnglish(String text) {
            // Check if all characters are ASCII (English + numbers + symbols)
            return text.codeUnits.every((unit) => unit < 128);
          }

          return Expanded(
            flex: width,
            child: Text(
              text,
              textAlign: textAlign,
              maxLines: 10,
              style: TextStyle(
                fontSize: displayFontSize * 1.5,
                fontWeight: bold
                    ? FontWeight.bold
                    : isEnglish(text)
                    ? FontWeight.bold
                    : FontWeight.w500,
                color: textColor,
                fontFamily: isEnglish(text) ? 'Courier' : "monospace",
                letterSpacing: 0,
                height: 0,
                fontFamilyFallback: const ['Courier', 'monospace'],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSeparator(Map<String, dynamic> params) {
    final width = params['width'] as int? ?? 48;

    // Use dashes to simulate thermal printer separator
    final dashCount = (width * 0.65).round();
    final separator = '-' * dashCount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        separator,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11.0,
          color: textColor,
          fontFamily: 'Courier New',
          fontFamilyFallback: const ['Courier', 'monospace'],
          height: 1.0,
          letterSpacing: 0.0,
        ),
      ),
    );
  }

  Widget _buildCutPaper() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.grey[400]!,
                    Colors.grey[400]!,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.content_cut, size: 14, color: Colors.grey[600]),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.grey[400]!,
                    Colors.grey[400]!,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
