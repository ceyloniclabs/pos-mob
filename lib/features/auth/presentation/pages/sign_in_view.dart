import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_radius.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/app_version_label.dart';
import 'package:pos/core/widgets/custom_button.dart';
import 'package:pos/core/widgets/custom_text_field.dart';

import '../../domain/validators/auth_validator.dart';
import '../controllers/sign_in_controller.dart';

/// Compact Sign In screen adhering to Senior Flutter UI/UX guidelines.
/// - Unboxed direct form layout (no outer container)
/// - Single-screen viewport fit with no unnecessary scrolling
/// - Dedicated Shop QR scan button and clear backend switcher (Self-Hosted vs. Cloud)
class SignInView extends GetView<SignInController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: ResponsiveCenter(
            maxWidth: 420,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 640;

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: isCompact ? AppSpacing.xs : AppSpacing.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(),

                            // Compact Brand Hero
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: isCompact ? 52 : 58,
                                    height: isCompact ? 52 : 58,
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      borderRadius: AppRadius.lgAll,
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.primary.withValues(
                                            alpha: 0.12,
                                          ),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: colorScheme.outlineVariant
                                            .withValues(alpha: 0.8),
                                        width: 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: AppRadius.lgAll,
                                      child: Image.asset(
                                        'assets/appstore.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  AppSpacing.gapSm,
                                  Text(
                                    'SurfDesk',
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  AppSpacing.gapXxs,
                                  Text(
                                    'Shop management & rental system',
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            isCompact ? AppSpacing.gapSm : AppSpacing.gapMd,

                            // Direct Form (No outer bounding container)
                            Form(
                              key: formKey,
                              child: AutofillGroup(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Email Field
                                    AppTextField(
                                      label: 'Email',
                                      hint: 'staff@surfshop.com',
                                      controller: controller.emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.email,
                                        AutofillHints.username,
                                      ],
                                      prefixIcon: Iconsax.sms,
                                      validator: (value) =>
                                          AuthValidator.validateEmail(value)
                                              ?.tr,
                                    ),
                                    AppSpacing.gapSm,

                                    // Password Field
                                    Obx(
                                      () => AppTextField(
                                        label: 'Password',
                                        hint: 'Enter your password',
                                        controller:
                                            controller.passwordController,
                                        obscureText:
                                            controller.obscurePassword.value,
                                        textInputAction: TextInputAction.done,
                                        autofillHints: const [
                                          AutofillHints.password,
                                        ],
                                        prefixIcon: Iconsax.lock,
                                        validator: (value) =>
                                            AuthValidator.validatePassword(
                                              value,
                                            )?.tr,
                                        onSubmitted: (_) {
                                          if (formKey.currentState!
                                              .validate()) {
                                            controller.login();
                                          }
                                        },
                                        suffix: IconButton(
                                          tooltip:
                                              controller.obscurePassword.value
                                              ? 'Show password'
                                              : 'Hide password',
                                          onPressed: controller
                                              .togglePasswordVisibility,
                                          icon: Icon(
                                            controller.obscurePassword.value
                                                ? Iconsax.eye_slash
                                                : Iconsax.eye,
                                            size: 19,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Forgot Password Action
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () =>
                                            _showForgotPasswordSheet(context),
                                        style: TextButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.xs,
                                            vertical: AppSpacing.xxs,
                                          ),
                                        ),
                                        child: Text(
                                          'Forgot password?',
                                          style: textTheme.labelMedium
                                              ?.copyWith(
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                    AppSpacing.gapXl,

                                    // Primary Sign In Button
                                    Obx(
                                      () => AppButton(
                                        label: 'Sign In',
                                        icon: Iconsax.login,
                                        isLoading: controller.isLoading.value,
                                        onPressed: () {
                                          if (formKey.currentState!
                                              .validate()) {
                                            controller.login();
                                          }
                                        },
                                        type: AppButtonType.primary,
                                        expand: true,
                                      ),
                                    ),
                                    AppSpacing.gapSm,

                                    // Secondary Scan Shop QR action
                                    AppButton(
                                      label: 'Scan Shop QR Code',
                                      icon: Iconsax.scan_barcode,
                                      type: AppButtonType.secondary,
                                      expand: true,
                                      onPressed: () =>
                                          Get.toNamed(Routes.SCAN_SHOP),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AppSpacing.gapXs,

                            // Link text instead of back button
                            Center(
                              child: TextButton(
                                onPressed: () =>
                                    Get.offNamed(Routes.CONNECTION_MODE),
                                style: TextButton.styleFrom(
                                  foregroundColor: colorScheme.onSurfaceVariant,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                ),
                                child: Text(
                                  'Back to Setup Selection',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),

                            // App Version Footer
                            Center(
                              child: AppVersionLabel(
                                prefix: 'SurfDesk v',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            AppSpacing.gapXs,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      backgroundColor: colorScheme.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: AppRadius.fullAll,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.key,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  AppSpacing.gapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Forgot Password',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Staff account recovery guide',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.gapLg,
              Text(
                'Staff and terminal accounts are managed by your store administrator. To regain access:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.gapMd,
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                  ),
                ),
                child: const Column(
                  children: [
                    _RecoveryStep(
                      number: '1',
                      text: 'Contact your shop owner or manager on the web dashboard.',
                    ),
                    AppSpacing.gapSm,
                    _RecoveryStep(
                      number: '2',
                      text: 'Ask them to regenerate or update your staff login password.',
                    ),
                    AppSpacing.gapSm,
                    _RecoveryStep(
                      number: '3',
                      text: 'Or scan the Shop QR code to reconnect this device to your register.',
                    ),
                  ],
                ),
              ),
              AppSpacing.gapLg,
              AppButton(
                label: 'Got It',
                type: AppButtonType.primary,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecoveryStep extends StatelessWidget {
  const _RecoveryStep({required this.number, required this.text});
  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        AppSpacing.gapSm,
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
