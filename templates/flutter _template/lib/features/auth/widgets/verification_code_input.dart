import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A custom widget for entering verification codes with individual digit boxes
class VerificationCodeInput extends StatefulWidget {
  final int length;
  final double itemSize;
  final Color borderColor;
  final Color focusedBorderColor;
  final double borderWidth;
  final double borderRadius;
  final TextStyle textStyle;
  final Function(String) onCompleted;
  final Function(String)? onChanged;

  const VerificationCodeInput({
    super.key,
    this.length = 6,
    this.itemSize = 55,
    this.borderColor = Colors.grey,
    this.focusedBorderColor = Colors.grey,
    this.borderWidth = 1.5,
    this.borderRadius = 8.0,
    required this.textStyle,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<VerificationCodeInput> createState() => _VerificationCodeInputState();
}

class _VerificationCodeInputState extends State<VerificationCodeInput> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  late List<String> _verificationCode;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _verificationCode = List.filled(widget.length, '');

    // Add listeners to focus nodes for UI updates
    for (int i = 0; i < widget.length; i++) {
      _focusNodes[i].addListener(() {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  /// Check if all fields are filled
  bool _isCompleted() {
    for (var code in _verificationCode) {
      if (code.isEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Get the complete verification code
  String _getVerificationCode() {
    return _verificationCode.join();
  }

  /// Handle text changes in digit boxes
  void _onTextChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Update the verification code
      _verificationCode[index] = value;

      // Call onChanged callback if provided
      widget.onChanged?.call(_getVerificationCode());

      // Move to next field if not the last one
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // If last field, unfocus and call onCompleted if all filled
        _focusNodes[index].unfocus();
        if (_isCompleted()) {
          widget.onCompleted(_getVerificationCode());
        }
      }
    }
  }

  /// Clear all fields
  void clearAll() {
    for (int i = 0; i < widget.length; i++) {
      _controllers[i].clear();
      _verificationCode[i] = '';
    }
    _focusNodes[0].requestFocus();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.length,
        (index) => Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.0),
            child: _buildDigitBox(index),
          ),
        ),
      ),
    );
  }

  Widget _buildDigitBox(int index) {
    return Container(
      width: widget.itemSize,
      height: widget.itemSize,
      constraints: const BoxConstraints(maxWidth: 50, maxHeight: 50),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: (index < _focusNodes.length && _focusNodes[index].hasFocus)
            ? widget.focusedBorderColor.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
      ),
      child: Center(
        child: TextField(
          controller: index < _controllers.length ? _controllers[index] : null,
          focusNode: index < _focusNodes.length ? _focusNodes[index] : null,
          textAlign: TextAlign.center,
          style: widget.textStyle,
          keyboardType: TextInputType.number,
          textAlignVertical: TextAlignVertical.center,
          expands: false,
          maxLines: 1,
          minLines: 1,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            if (index < _verificationCode.length) {
              if (value.isNotEmpty) {
                _onTextChanged(value, index);
              } else if (value.isEmpty) {
                // Handle backspace
                _verificationCode[index] = '';
                widget.onChanged?.call(_getVerificationCode());
              }
            }
          },
          onTap: () {
            // Clear the field when tapped for better UX
            if (index < _controllers.length) {
              _controllers[index].selection = TextSelection.fromPosition(
                TextPosition(offset: _controllers[index].text.length),
              );
            }
          },
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            counterText: '',
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
