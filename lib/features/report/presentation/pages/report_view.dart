import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:pos/core/widgets/custome_app_bar.dart';
import '../controllers/report_controller.dart';
import '../models/report_definition.dart';
import '../widgets/report_filter_sheet.dart';
import '../widgets/report_grid.dart';
import '../widgets/report_hero_card.dart';
import '../widgets/report_tips_card.dart';

class ReportView extends GetView<ReportController> {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomeAppBar(
        title: 'Reports',
        showbackArrow: true,
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: true,
        child: Obx(
          () => Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 30.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReportHeroCard(
                      totalReports: controller.reportDefinitions.length,
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'Select a report',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Each report exports a PDF directly from the API with the filters you choose.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withValues(alpha: 0.8),
                          ),
                    ),
                    SizedBox(height: 16.h),
                    ReportGrid(
                      definitions: controller.reportDefinitions,
                      onTap: (definition) =>
                          _openFilterSheet(context, definition),
                    ),
                    SizedBox(height: 20.h),
                    const ReportTipsCard(),
                  ],
                ),
              ),
              if (controller.isGenerating.value)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 32.w),
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            SizedBox(height: 16.h),
                            Text(
                              controller.activeStatus.value,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context, ReportDefinition definition) {
    ReportFilterSheet.show(
      context,
      definition: definition,
      controller: controller,
    );
  }
}
