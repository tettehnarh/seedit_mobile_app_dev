import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final String? hintText;
  final Widget? prefixIcon;
  final String? helperText;

  const CustomDropdownField({
    super.key,
    required this.label,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.hintText,
    this.prefixIcon,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: enabled ? null : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText ?? 'Select $label',
            helperText: helperText,
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: enabled 
                ? theme.colorScheme.surface 
                : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: enabled ? Colors.grey[600] : Colors.grey[400],
          ),
          style: TextStyle(
            color: enabled ? Colors.black : Colors.grey,
            fontSize: 16,
          ),
          dropdownColor: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
      ],
    );
  }
}

class CustomMultiSelectField<T> extends StatefulWidget {
  final String label;
  final List<T> selectedValues;
  final List<MultiSelectItem<T>> items;
  final void Function(List<T>) onChanged;
  final String? Function(List<T>?)? validator;
  final bool enabled;
  final String? hintText;
  final Widget? prefixIcon;
  final int? maxSelections;

  const CustomMultiSelectField({
    super.key,
    required this.label,
    required this.selectedValues,
    required this.items,
    required this.onChanged,
    this.validator,
    this.enabled = true,
    this.hintText,
    this.prefixIcon,
    this.maxSelections,
  });

  @override
  State<CustomMultiSelectField<T>> createState() => _CustomMultiSelectFieldState<T>();
}

class _CustomMultiSelectFieldState<T> extends State<CustomMultiSelectField<T>> {
  void _showMultiSelectDialog() async {
    final List<T>? result = await showDialog<List<T>>(
      context: context,
      builder: (BuildContext context) {
        return _MultiSelectDialog<T>(
          title: widget.label,
          items: widget.items,
          selectedValues: widget.selectedValues,
          maxSelections: widget.maxSelections,
        );
      },
    );

    if (result != null) {
      widget.onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: widget.enabled ? null : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: widget.enabled ? _showMultiSelectDialog : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: widget.enabled 
                  ? theme.colorScheme.surface 
                  : Colors.grey[100],
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  widget.prefixIcon!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: widget.selectedValues.isEmpty
                      ? Text(
                          widget.hintText ?? 'Select ${widget.label}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        )
                      : Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: widget.selectedValues.map((value) {
                            final item = widget.items.firstWhere(
                              (item) => item.value == value,
                            );
                            return Chip(
                              label: Text(
                                item.label,
                                style: const TextStyle(fontSize: 12),
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: widget.enabled ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MultiSelectDialog<T> extends StatefulWidget {
  final String title;
  final List<MultiSelectItem<T>> items;
  final List<T> selectedValues;
  final int? maxSelections;

  const _MultiSelectDialog({
    required this.title,
    required this.items,
    required this.selectedValues,
    this.maxSelections,
  });

  @override
  State<_MultiSelectDialog<T>> createState() => _MultiSelectDialogState<T>();
}

class _MultiSelectDialogState<T> extends State<_MultiSelectDialog<T>> {
  late List<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = List.from(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final isSelected = _selectedValues.contains(item.value);
            final canSelect = widget.maxSelections == null ||
                _selectedValues.length < widget.maxSelections! ||
                isSelected;

            return CheckboxListTile(
              title: Text(item.label),
              subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
              value: isSelected,
              onChanged: canSelect
                  ? (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedValues.add(item.value);
                        } else {
                          _selectedValues.remove(item.value);
                        }
                      });
                    }
                  : null,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_selectedValues),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class MultiSelectItem<T> {
  final T value;
  final String label;
  final String? subtitle;

  MultiSelectItem({
    required this.value,
    required this.label,
    this.subtitle,
  });
}
