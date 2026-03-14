import 'package:flutter/material.dart';

class OTPInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback? onChanged;
  final String? Function(String?)? validator;

  const OTPInputField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.validator,
  });

  @override
  State<OTPInputField> createState() => _OTPInputFieldState();
}

class _OTPInputFieldState extends State<OTPInputField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 64,
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        validator: widget.validator,
        onChanged: (value) {
          if (value.isNotEmpty && widget.focusNode != null) {
            FocusScope.of(context).nextFocus();
          }
          widget.onChanged?.call();
        },
        decoration: InputDecoration(
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFFE2E8F0)
                  : const Color(0xFF334155),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFFE2E8F0)
                  : const Color(0xFF334155),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF4F46E5),
              width: 2,
            ),
          ),
        ),
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
