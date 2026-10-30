import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/theme/custome_drop_down_decoration.dart';
import 'package:pos/core/widgets/app_card.dart';
import 'package:pos/core/widgets/custom_button.dart';
import 'package:pos/core/widgets/custom_text_field.dart';

Widget buildSectionTitle(BuildContext context, String title) {
  final theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.xs),
    child: Text(
      title.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

Widget buildCard({required List<Widget> children, EdgeInsetsGeometry? padding}) {
  return AppCard(
    padding: padding ?? const EdgeInsets.all(AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

Widget buildTextField({
  required String label,
  required TextEditingController controller,
  String? hint,
  String? helperText,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
  bool isRequired = false,
  bool obscureText = false,
  bool readOnly = false,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FieldLabel(label, optional: !isRequired),
      AppSpacing.gapXs,
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        obscureText: obscureText,
        readOnly: readOnly,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          hintText: hint,
          helperText: helperText,
          helperMaxLines: 2,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    ],
  );
}

Widget buildDropdownField({
  required BuildContext context,
  required String label,
  required RxString rxValue,
  required List<String> items,
  String? hint,
  String? helperText,
  bool isRequired = false,
  Color? closedFillColor,
  Color? expandedFillColor,
}) {
  final theme = Theme.of(context);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FieldLabel(label, optional: !isRequired),
      AppSpacing.gapXs,
      Obx(
        () => CustomDropdown<String>(
          hintText: hint ?? 'Select $label',
          items: items,
          initialItem: (rxValue.value.isEmpty || !items.contains(rxValue.value))
              ? null
              : rxValue.value,
          onChanged: (value) {
            if (value != null) rxValue.value = value;
          },
          validator: isRequired
              ? (value) => value == null || value.isEmpty
                  ? '   $label is required'
                  : null
              : null,
          decoration: buildCustomDropdownDecoration(
            context,
            closedFillColor: closedFillColor,
            expandedFillColor: expandedFillColor,
          ),
        ),
      ),
      if (helperText != null)
        Padding(
          padding: const EdgeInsets.only(top: 6.0, left: 12.0),
          child: Text(
            helperText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
    ],
  );
}

Widget buildSaveButton({
  required BuildContext context,
  required RxBool isSaving,
  required VoidCallback onPressed,
  String text = 'Save',
}) {
  return Obx(
    () => AppButton(
      label: text,
      isLoading: isSaving.value,
      onPressed: onPressed,
      type: AppButtonType.primary,
      expand: true,
    ),
  );
}
