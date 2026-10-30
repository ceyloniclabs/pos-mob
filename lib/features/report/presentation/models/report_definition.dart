import 'package:flutter/material.dart';

import '../../domain/entities/report_type.dart';

class ReportDefinition {
  final ReportType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final List<String> tags;

  const ReportDefinition({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.tags,
  });
}
