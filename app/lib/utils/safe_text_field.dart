import 'package:flutter/material.dart';

class SafeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final bool enabled;
  final int? maxLines;
  final TextDirection? textDirection;
  final TextAlign? textAlign;

  const SafeTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onTap,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.textDirection,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onTap: onTap,
      enabled: enabled,
      maxLines: maxLines,
      textDirection: textDirection,
      textAlign: textAlign ?? (textDirection == TextDirection.rtl ? TextAlign.right : TextAlign.left),
      style: const TextStyle(
        fontFamily: 'Arial',
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
