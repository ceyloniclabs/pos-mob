import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pos/core/widgets/app_version_label.dart';

import '../controllers/splash_controller.dart';

/// Redesigned Splash Screen incorporating the wave Lottie animation
/// while preserving brand identity, status messages, and version info.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final SplashController _controller;

  // Colors matching the Lottie canvas (sky background and bottom wave)
  static const Color _splashBgColor = Color(0xFFEAF7FB);
  static const Color _bottomWaveColor = Color(0xFF0B2A3C);

  @override
  void initState() {
    super.initState();
    _controller = Get.find<SplashController>();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: _bottomWaveColor,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _splashBgColor,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _controller.skipAnimation(),
          child: Stack(
            children: [
              // 1. Full-screen Lottie wave animation
              Positioned.fill(
                child: Lottie.asset(
                  'assets/lottie/splash_wave.json',
                  controller: _animationController,
                  fit: BoxFit.cover,
                  onLoaded: (comp) {
                    _animationController.duration = comp.duration;
                    _animationController.forward().whenComplete(() {
                      _controller.onAnimationCompleted();
                    });
                  },
                ),
              ),

              // 2. App Name, Subtitle, Status Message & Loading Indicator
              // Positioned gracefully in the deep blue ocean area below the landing logo
              Align(
                alignment: const Alignment(0, 0.40),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    // Smoothly fade-in & slide-up once the logo lands (frames ~60 to 95)
                    final curved = CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.38, 0.65, curve: Curves.easeOut),
                    );
                    final v = curved.value;
                    return Opacity(
                      opacity: v,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - v)),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Title
                        const Text(
                          'SurfDesk',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle
                        Text(
                          'Surfboard Rental & Shop Management System',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.90),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Status message with smooth animated switcher
                        Obx(
                          () => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              _controller.statusMessage.value,
                              key: ValueKey<String>(
                                _controller.statusMessage.value,
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Elegant Three-In-Out Loading Indicator
                        SpinKitThreeInOut(
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Security & Version Footer
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final curved = CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(
                          0.45,
                          0.72,
                          curve: Curves.easeOut,
                        ),
                      );
                      return Opacity(
                        opacity: curved.value,
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.paddingOf(context).bottom > 0 ? 2 : 10,
                      ),
                      child: AppVersionLabel(
                        prefix: 'SurfDesk v',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.70),
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
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
}
