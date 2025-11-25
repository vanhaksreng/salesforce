import 'package:flutter/material.dart';

class SelectOption {
  final String id;
  final String title;
  final String? subtitle;
  final IconData? icon;

  SelectOption({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon,
  });
}

// Main Select Option Widget
class SelectOptionWidget extends StatefulWidget {
  final List<SelectOption> options;
  final String? selectedValue;
  final Function(String)? onChanged;
  final String? groupLabel;

  const SelectOptionWidget({
    Key? key,
    required this.options,
    this.selectedValue,
    this.onChanged,
    this.groupLabel,
  }) : super(key: key);

  @override
  State<SelectOptionWidget> createState() => _SelectOptionWidgetState();
}

class _SelectOptionWidgetState extends State<SelectOptionWidget> {
  late String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.groupLabel != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.groupLabel!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ...widget.options.map((option) => _buildSelectOption(option)).toList(),
      ],
    );
  }

  Widget _buildSelectOption(SelectOption option) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedValue == option.id
              ? Colors.blue
              : Colors.grey.shade300,
          width: _selectedValue == option.id ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: RadioListTile<String>(
        value: option.id,
        groupValue: _selectedValue,
        onChanged: (String? value) {
          setState(() {
            _selectedValue = value;
          });
          if (value != null) {
            widget.onChanged?.call(value);
          }
        },
        title: Row(
          children: [
            if (option.icon != null) ...[
              Icon(
                option.icon,
                color: _selectedValue == option.id
                    ? Colors.blue
                    : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                option.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _selectedValue == option.id
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: _selectedValue == option.id
                      ? Colors.blue
                      : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        subtitle: option.subtitle != null
            ? Padding(
                padding: EdgeInsets.only(
                  left: option.icon != null ? 36 : 0,
                  top: 4,
                ),
                child: Text(
                  option.subtitle!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              )
            : null,
        activeColor: Colors.blue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
