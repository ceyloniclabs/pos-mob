import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/access/access_policy.dart';
import 'package:pos/features/auth/presentation/controllers/auth_controller.dart';

class PermissionGate extends StatelessWidget {
  final AppPermission permission;
  final Widget child;

  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final role = Get.isRegistered<AuthController>()
          ? AuthController.to.user.value?.role
          : null;
      if (AccessPolicy.allows(role, permission)) return child;
      return const _AccessDeniedView();
    });
  }
}

class _AccessDeniedView extends StatelessWidget {
  const _AccessDeniedView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access unavailable')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'You don’t have access to this page.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Contact your shop administrator if you need access.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: Get.back, child: const Text('Go back')),
            ],
          ),
        ),
      ),
    );
  }
}
