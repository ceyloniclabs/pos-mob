import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/report_definition.dart';
import 'report_card.dart';

class ReportGrid extends StatelessWidget {
  const ReportGrid({
    super.key,
    required this.definitions,
    required this.onTap,
  });

  final List<ReportDefinition> definitions;
  final ValueChanged<ReportDefinition> onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 1100
        ? 3
        : width >= 700
            ? 2
            : 1;
    final cardWidth = (width - 32.w - (16.w * (columns - 1))) / columns;

    return Wrap(
      spacing: 16.w,
      runSpacing: 16.h,
      children: definitions
          .map(
            (definition) => SizedBox(
              width: cardWidth,
              child: ReportCard(
                definition: definition,
                onTap: () => onTap(definition),
              ),
            ),
          )
          .toList(),
    );
  }
}
