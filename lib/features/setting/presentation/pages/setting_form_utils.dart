import 'package:flutter/material.dart';

export 'package:pos/core/widgets/app_form_elements.dart';

Widget buildValidationNote() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, color: Colors.blue, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Validation Note',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              SizedBox(height: 4),
              Text(
                'These values define the maximum grace period that can be assigned to individual rental rates. When adding or updating rates, the system will ensure the grace period does not exceed these thresholds.',
                style: TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildMenuDivider() {
  return Divider(
    height: 1,
    color: Colors.grey.withValues(alpha: 0.2),
  );
}
