import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_spacing.dart';
import 'package:pos/core/utils/responsive.dart';
import 'package:pos/core/widgets/custom_button.dart';
import 'package:pos/core/widgets/custom_text_field.dart';
import 'package:pos/core/widgets/custome_app_bar.dart';

import '../../domain/validators/auth_validator.dart';
import '../controllers/sign_up_controller.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: const CustomeAppBar(
        title: 'Create Account',
        showbackArrow: true,
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 480,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get started with SurfDesk',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppSpacing.gapXxs,
                  Text(
                    'Create an account to manage rentals and store operations.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.gapLg,

                  // Full Name
                  AppTextField(
                    label: 'Full Name',
                    hint: 'e.g. John Doe',
                    controller: controller.nameController,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Iconsax.user,
                    validator: (val) => AuthValidator.validateName(val)?.tr,
                  ),
                  AppSpacing.gapMd,

                  // Email
                  AppTextField(
                    label: 'Email',
                    hint: 'you@example.com',
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    prefixIcon: Iconsax.sms,
                    validator: (val) => AuthValidator.validateEmail(val)?.tr,
                  ),
                  AppSpacing.gapMd,

                  // Password
                  Obx(
                    () => AppTextField(
                      label: 'Password',
                      hint: 'Create a strong password',
                      controller: controller.passwordController,
                      obscureText: controller.obscurePassword.value,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      prefixIcon: Iconsax.lock,
                      validator: (val) => AuthValidator.validatePassword(val)?.tr,
                      suffix: IconButton(
                        tooltip: controller.obscurePassword.value
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Iconsax.eye_slash
                              : Iconsax.eye,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                  ),
                  AppSpacing.gapLg,

                  // Submit button
                  Obx(
                    () => AppButton(
                      label: 'Create Account',
                      isLoading: controller.isLoading.value,
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          controller.signUp();
                        }
                      },
                      type: AppButtonType.primary,
                      expand: true,
                    ),
                  ),
                  AppSpacing.gapMd,

                  // Back to Sign In
                  Center(
                    child: TextButton(
                      onPressed: () => Get.offNamed(Routes.SIGN_IN),
                      child: const Text('Already have an account? Sign In'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
