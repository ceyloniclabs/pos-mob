import 'package:flutter/material.dart';
import 'package:pos/core/theme/app_spacing.dart';

/// Label widget placed above form fields.
class FieldLabel extends StatelessWidget {
  const FieldLabel(
    this.label, {
    super.key,
    this.optional = false,
    this.isRequired = false,
  });

  final String label;
  final bool optional;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: label, style: t.textTheme.labelLarge),
          if (isRequired)
            TextSpan(
              text: ' *',
              style: t.textTheme.labelLarge?.copyWith(
                color: t.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (optional)
            TextSpan(
              text: '  (optional)',
              style: t.textTheme.bodySmall?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

/// Standard AppTextField following flutter-uiux-design skill.
/// Visible label above, clean M3 input decoration, inline validation, and focus handling.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helperText,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffix,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
    this.maxLines = 1,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.optional = false,
    this.isRequired = false,
  });

  final String label;
  final String? hint;
  final String? helperText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffix;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final int maxLines;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final bool optional;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FieldLabel(
          label,
          optional: optional,
          isRequired: isRequired,
        ),
        AppSpacing.gapXs,
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          readOnly: readOnly,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          autofillHints: autofillHints,
          maxLines: maxLines,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
