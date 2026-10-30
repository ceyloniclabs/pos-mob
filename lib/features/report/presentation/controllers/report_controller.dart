import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/routes/app_pages.dart';
import '../../../../core/utils/scaffold_message_utils.dart';
import '../../../../core/widgets/pdf_viewer/app_pdf_viewer_screen.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/entities/report_type.dart';
import '../../domain/usecases/get_customer_list_report_use_case.dart';
import '../../domain/usecases/get_sales_inventory_report_use_case.dart';
import '../../domain/usecases/get_sales_report_use_case.dart';
import '../models/report_definition.dart';

class ReportController extends GetxController {
  final GetCustomerListReportUseCase getCustomerListReportUseCase;
  final GetSalesReportUseCase getSalesReportUseCase;
  final GetSalesInventoryReportUseCase getSalesInventoryReportUseCase;

  ReportController({
    required this.getCustomerListReportUseCase,
    required this.getSalesReportUseCase,
    required this.getSalesInventoryReportUseCase,
  });

  final RxBool isGenerating = false.obs;
  final RxString activeStatus = 'Ready to export PDFs'.obs;

  final List<ReportDefinition> reportDefinitions = const [
    ReportDefinition(
      type: ReportType.sales,
      title: 'Sales Report',
      subtitle: 'Track sales performance, receipts and revenue by date range.',
      icon: Icons.point_of_sale_outlined,
      gradient: LinearGradient(
        colors: [Color(0xFFB45309), Color(0xFFF59E0B), Color(0xFFFBBF24)],
      ),
      tags: ['Sales', 'Date Range', 'PDF'],
    ),
    ReportDefinition(
      type: ReportType.salesInventory,
      title: 'Sales Inventory',
      subtitle: 'Review item catalog, categories, brands, and stock levels.',
      icon: Icons.inventory_2_outlined,
      gradient: LinearGradient(
        colors: [Color(0xFF5B21B6), Color(0xFF7C3AED), Color(0xFFA855F7)],
      ),
      tags: ['Category', 'Brand', 'Stock'],
    ),
    ReportDefinition(
      type: ReportType.customerList,
      title: 'Customer Directory',
      subtitle: 'Export complete customer roster and contacts as a PDF.',
      icon: Icons.people_alt_outlined,
      gradient: LinearGradient(
        colors: [Color(0xFF0F4C81), Color(0xFF1E88E5), Color(0xFF4FC3F7)],
      ),
      tags: ['Search', 'Customer Type', 'PDF'],
    ),
  ];

  Future<File?> generateReport(
    ReportType reportType,
    ReportFilter request,
  ) async {
    try {
      isGenerating.value = true;
      activeStatus.value = 'Preparing ${titleFor(reportType)}...';

      final file = await _downloadReport(reportType, request);
      activeStatus.value = 'Report ready';
      return file;
    } catch (e) {
      activeStatus.value = 'Export failed';
      ScaffoldMessageUtils.showError(
        'Failed to generate report: ${e.toString()}',
      );
      return null;
    } finally {
      isGenerating.value = false;
    }
  }

  void openPdfPreview(File file, ReportType reportType) {
    Get.to(
      () => AppPdfViewerScreen(
        args: AppPdfViewerArgs(
          filePath: file.path,
          title: titleFor(reportType),
          fileName: fileNameFor(reportType),
        ),
      ),
      routeName: Routes.PDF_PREVIEW,
    );
  }

  Future<bool> generateAndPreview(
    ReportType reportType,
    ReportFilter request,
  ) async {
    final file = await generateReport(reportType, request);
    if (file != null) {
      openPdfPreview(file, reportType);
      return true;
    }
    return false;
  }

  Future<File> _downloadReport(
    ReportType reportType,
    ReportFilter request,
  ) async {
    switch (reportType) {
      case ReportType.customerList:
        return getCustomerListReportUseCase.execute(
          search: _trimmedOrNull(request.search),
          customerType: _trimmedOrNull(request.customerType),
        );
      case ReportType.sales:
        return getSalesReportUseCase.execute(
          saleStatus: _trimmedOrNull(request.saleStatus),
          fromDate: request.fromDate,
          toDate: request.toDate,
        );
      case ReportType.salesInventory:
        return getSalesInventoryReportUseCase.execute(
          category: _trimmedOrNull(request.category),
          brand: _trimmedOrNull(request.brand),
          stockStatus: _trimmedOrNull(request.stockStatus),
        );
    }
  }

  String? _trimmedOrNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty || trimmed.toLowerCase() == 'all') {
      return null;
    }
    return trimmed;
  }

  String titleFor(ReportType reportType) {
    switch (reportType) {
      case ReportType.customerList:
        return 'Customer List Report';
      case ReportType.sales:
        return 'Sales Report';
      case ReportType.salesInventory:
        return 'Sales Inventory Report';
    }
  }

  String fileNameFor(ReportType reportType) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    switch (reportType) {
      case ReportType.customerList:
        return 'customer_list_$timestamp.pdf';
      case ReportType.sales:
        return 'sales_report_$timestamp.pdf';
      case ReportType.salesInventory:
        return 'sales_inventory_report_$timestamp.pdf';
    }
  }

  String formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
}
