import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:findmydorm/core/theme/app_colors.dart';

/// Sets up global error handlers for the entire application.
///
/// Catches both synchronous Flutter framework errors and
/// asynchronous platform-level errors, logging them in debug mode
/// and showing a user-friendly fallback in release mode.
class AppErrorHandler {
  AppErrorHandler._();

  /// Call once in [main] before [runApp].
  static void init() {
    // 1. Framework errors (layout, rendering, widget build)
    FlutterError.onError = (FlutterErrorDetails details) {
      // In debug mode, print the full error to the console.
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
      // In release mode, you could send to a crash-reporting service here.
    };

    // 2. Asynchronous / platform errors (uncaught Future errors, isolate errors)
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      if (kDebugMode) {
        debugPrint('=== Uncaught async error ===');
        debugPrint('$error');
        debugPrint('$stack');
      }
      // Return true to indicate the error was handled.
      return true;
    };

    // 3. Replace the default red error screen with a friendlier widget.
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return _AppErrorWidget(details: details);
    };
  }
}

/// A user-friendly error widget shown when a widget fails to build.
///
/// In debug mode it displays the actual error message for easy debugging.
/// In release mode it shows a generic "something went wrong" message.
class _AppErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const _AppErrorWidget({required this.details});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceLight,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lato',
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                kDebugMode
                    ? details.exceptionAsString()
                    : 'An unexpected error occurred.\nPlease restart the app.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
