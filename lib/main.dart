import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'dart:io';

import 'package:flutter/services.dart';

import 'package:pos/core/bindings/initial_binding.dart';
import 'package:pos/core/routes/app_pages.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:pos/core/theme/theme_controller.dart';
import 'package:pos/core/utils/device_utils.dart';
import 'package:pos/core/widgets/common_dialog.dart';
import 'package:pos/core/localization/app_translations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initial system overlay matches splash screen until navigation
  DeviceUtils.updateSystemOverlay(
    isDark: false,
    navBarColor: const Color(0xFF0B2A3C),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  GoogleFonts.config.allowRuntimeFetching = true;
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Uses fallback URLs if .env is missing
  }
  InitialBinding().dependencies();

  if (!kReleaseMode && !Platform.isAndroid) {
    DevicePreview.enable();
  }

  Widget appWidget;
  if (Platform.isAndroid) {
    appWidget = ScreenUtilInit(
      designSize: const Size(360.0, 696.0),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(
        title: "Ceylonic POS",
        useInheritedMediaQuery: true,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeController.to.themeMode,
        initialRoute: AppPages.initial,
        initialBinding: InitialBinding(),
        getPages: AppPages.routes,
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        fallbackLocale: const Locale('en', 'US'),
        builder: (context, child) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              statusBarBrightness:
                  isDark ? Brightness.dark : Brightness.light,
              systemNavigationBarColor: theme.scaffoldBackgroundColor,
              systemNavigationBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarDividerColor: Colors.transparent,
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  } else {
    appWidget = ScreenUtilInit(
      designSize: const Size(360.0, 696.0),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldPop = await CommonDialog.showExitDialog();
          if (shouldPop) {
            SystemNavigator.pop();
          }
        },
        child: GetMaterialApp(
          title: "Ceylonic POS",
          useInheritedMediaQuery: true,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeController.to.themeMode,
          initialRoute: AppPages.initial,
          initialBinding: InitialBinding(),
          getPages: AppPages.routes,
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
          builder: (context, child) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    isDark ? Brightness.light : Brightness.dark,
                statusBarBrightness:
                    isDark ? Brightness.dark : Brightness.light,
                systemNavigationBarColor: theme.scaffoldBackgroundColor,
                systemNavigationBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
                systemNavigationBarDividerColor: Colors.transparent,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }

  runApp(appWidget);
}
