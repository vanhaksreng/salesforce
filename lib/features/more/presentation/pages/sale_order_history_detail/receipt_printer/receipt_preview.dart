import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/receipt_builder.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/thermal_printer.dart';

class ReceiptPreview extends StatelessWidget {
  final List<ReceiptCommand> commands;
  final double paperWidth;

  const ReceiptPreview({
    super.key,
    required this.commands,
    this.paperWidth = 384,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: paperWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        spacing: scaleFontSize(6),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: commands.map((cmd) => _buildCommand(cmd)).toList(),
      ),
    );
  }

  Widget _buildCommand(ReceiptCommand command) {
    switch (command.type) {
      case ReceiptCommandType.row:
        return _buildTextRowCommand(command.params);
      case ReceiptCommandType.text:
        return _buildTextCommand(command.params);
      case ReceiptCommandType.image:
        return _buildImageCommand(command.params);
      case ReceiptCommandType.feedPaper:
        return _buildFeedPaperCommand(command.params);
      case ReceiptCommandType.cutPaper:
        return _buildCutPaperCommand();
      case ReceiptCommandType.separator:
        return _buildCutPaperCommand();
    }
  }

  Widget _buildTextRowCommand(Map<String, dynamic> params) {
    final columnMaps = params['columns'] as List<dynamic>;
    final fontSize = (params['fontSize'] as int? ?? 24).toDouble();

    final columns = columnMaps.map((colMap) {
      final map = colMap as Map<String, dynamic>;
      return {
        'text': map['text'] as String? ?? '',
        'width': map['width'] as int? ?? 1,
        'align': map['align'] as String? ?? 'left',
        'bold': map['bold'] as bool? ?? false,
      };
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns.map((column) {
          final flex = column['width'] as int;
          final text = column['text'] as String;
          final align = column['align'] as String;
          final bold = column['bold'] as bool;

          // Dynamic maxLines based on column width
          final maxLines = flex >= 4 ? 3 : 2;

          return Expanded(
            flex: flex,
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize * 0.7,
                fontFamily: 'NotoSansKhmer',
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: _getTextAlignFromString(align),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: maxLines,
            ),
          );
        }).toList(),
      ),
    );
  }

  TextAlign _getTextAlignFromString(String align) {
    switch (align.toLowerCase()) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  Widget _buildTextCommand(Map<String, dynamic> params) {
    final text = params['text'] as String? ?? '';
    final fontSize = (params['fontSize'] as int? ?? 24).toDouble();
    final bold = params['bold'] as bool? ?? false;
    final align = params['align'] as String? ?? 'left';
    final maxChars = params['maxCharsPerLine'] as int? ?? 48;

    // Check if it's a separator line (only special chars)
    final isSeparator = _isSeparatorLine(text);

    if (isSeparator) {
      // For separator lines, use responsive dash rendering
      return _buildSeparatorLine(text, fontSize);
    }

    // Regular text - wrap based on maxChars
    final wrappedLines = _wrapText(text, maxChars);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Column(
        crossAxisAlignment: _getAlignment(align),
        children: wrappedLines.map((line) {
          return Text(
            line,
            style: TextStyle(
              height: 1,
              fontSize: fontSize * 0.6, // Scale down for preview
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
              fontFamily: 'NotoSansKhmer',
            ),
            textAlign: _getTextAlign(align),
          );
        }).toList(),
      ),
    );
  }

  /// Check if text is a separator line (only contains -, =, ─, ═, or spaces)
  bool _isSeparatorLine(String text) {
    final cleaned = text
        .trim()
        .replaceAll('-', '')
        .replaceAll('═', '')
        .replaceAll('─', '')
        .replaceAll('=', '');
    return cleaned.isEmpty && text.trim().isNotEmpty;
  }

  /// Build a visual separator line using dashes that scales with container width
  Widget _buildSeparatorLine(String text, double fontSize) {
    // Determine separator character
    final char = text.trim().isNotEmpty ? text.trim()[0] : '-';

    return LayoutBuilder(
      builder: (context, constraints) {
        final displayFontSize = fontSize * 0.6;
        final charWidth = displayFontSize * 0.32;
        final availableWidth = constraints.maxWidth;
        final charCount = (availableWidth / charWidth).floor();

        // Build the separator string with calculated count
        final separator = char * charCount;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          child: Text(
            separator,
            style: TextStyle(
              fontSize: displayFontSize,
              fontFamily: 'NotoSansKhmer',
              height: 1.0,
              letterSpacing: 0,
            ),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        );
      },
    );
  }

  Widget _buildImageCommand(Map<String, dynamic> params) {
    final imageBytes = params['imageBytes'] as Uint8List?;
    final width = (params['width'] as int? ?? 75).toDouble();
    final align = params['align'] as int? ?? 1;

    if (imageBytes == null) {
      return const SizedBox.shrink();
    }

    final alignment = getAlignmentImage(align);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: alignment,
        child: Image.memory(imageBytes, width: width, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildFeedPaperCommand(Map<String, dynamic> params) {
    final lines = params['lines'] as int? ?? 1;
    return SizedBox(height: lines * 4.0); // 4 pixels per line
  }

  Widget _buildCutPaperCommand() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade400, thickness: 2)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.content_cut,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade400, thickness: 2)),
        ],
      ),
    );
  }

  CrossAxisAlignment _getAlignment(String align) {
    switch (align.toLowerCase()) {
      case 'left':
        return CrossAxisAlignment.start;
      case 'center':
        return CrossAxisAlignment.center;
      case 'right':
        return CrossAxisAlignment.end;
      default:
        return CrossAxisAlignment.start;
    }
  }

  TextAlign _getTextAlign(String align) {
    switch (align.toLowerCase()) {
      case 'left':
        return TextAlign.left;
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  List<String> _wrapText(String text, int maxChars) {
    if (maxChars <= 0) return [text];

    final lines = <String>[];
    final words = text.split(' ');
    String currentLine = '';

    for (final word in words) {
      if ((currentLine + word).length <= maxChars) {
        currentLine += (currentLine.isEmpty ? '' : ' ') + word;
      } else {
        if (currentLine.isNotEmpty) lines.add(currentLine);
        currentLine = word;
      }
    }
    if (currentLine.isNotEmpty) lines.add(currentLine);

    return lines.isEmpty ? [text] : lines;
  }
}
