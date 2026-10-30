import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pos/features/manage_sales/presentation/controllers/sale_create_controller.dart';

class SaleStepperHeader extends GetView<SaleCreateController> {
  const SaleStepperHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.currentStep.value;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
            ),
          ),
        ),
        child: Row(
          children: [
            _buildStepItem(
              context: context,
              stepIndex: 0,
              title: 'Customer & Info',
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              isActive: current == 0,
              isCompleted: current > 0,
            ),
            _buildStepDivider(context, isCompleted: current > 0),
            _buildStepItem(
              context: context,
              stepIndex: 1,
              title: 'Cart Items',
              icon: Icons.shopping_bag_outlined,
              activeIcon: Icons.shopping_bag,
              isActive: current == 1,
              isCompleted: current > 1,
              badgeCount: controller.addedItems.length,
            ),
            _buildStepDivider(context, isCompleted: current > 1),
            _buildStepItem(
              context: context,
              stepIndex: 2,
              title: 'Checkout',
              icon: Icons.receipt_long_outlined,
              activeIcon: Icons.receipt_long,
              isActive: current == 2,
              isCompleted: false,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStepItem({
    required BuildContext context,
    required int stepIndex,
    required String title,
    required IconData icon,
    required IconData activeIcon,
    required bool isActive,
    required bool isCompleted,
    int? badgeCount,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final inactiveColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);

    final color = (isActive || isCompleted) ? primaryColor : inactiveColor;
    final bgColor = isActive
        ? primaryColor.withValues(alpha: 0.15)
        : isCompleted
            ? primaryColor
            : Theme.of(context).dividerColor.withValues(alpha: 0.1);
    final iconColor = isCompleted
        ? Colors.white
        : isActive
            ? primaryColor
            : inactiveColor;

    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: () => controller.goToStep(stepIndex),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? primaryColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isCompleted ? Icons.check : (isActive ? activeIcon : icon),
                    size: 18.w,
                    color: iconColor,
                  ),
                ),
              ),
              if (badgeCount != null && badgeCount > 0)
                Positioned(
                  right: -4.w,
                  top: -4.h,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    constraints: BoxConstraints(minWidth: 16.w),
                    child: Text(
                      badgeCount.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider(BuildContext context, {required bool isCompleted}) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Container(
          height: 2.h,
          color: isCompleted
              ? primaryColor
              : Theme.of(context).dividerColor.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}
