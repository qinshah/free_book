import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastType { success, info, warning, error }

extension ContextExtension on BuildContext {
  Future<void> showToast(
    String message, {
    Duration duration = const Duration(seconds: 1),
  }) => _showToast(message, type: ToastType.info, duration: duration);
  Future<void> showSuccessToast(
    String message, {
    Duration duration = const Duration(seconds: 1),
  }) => _showToast(message, type: ToastType.success, duration: duration);
  Future<void> showErrorToast(
    String message, {
    Duration duration = const Duration(seconds: 1),
  }) => _showToast(message, type: ToastType.error, duration: duration);
  Future<void> showWarningToast(
    String message, {
    Duration duration = const Duration(seconds: 1),
  }) => _showToast(message, type: ToastType.warning, duration: duration);

  Future<void> _showToast(
    String message, {
    required ToastType type,
    required Duration duration,
  }) async {
    final toast = FToast();
    toast.init(this);
    toast.removeCustomToast();
    toast.showToast(
      toastDuration: duration,
      child: Card(
        color: Theme.of(this).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                switch (type) {
                  ToastType.success => const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  ToastType.info =>  Icon(
                    Icons.info_outline,
                    color: Theme.of(this).primaryColor,
                  ),
                  ToastType.warning => const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.yellow,
                  ),
                  ToastType.error => const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                  ),
                },
                const SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
          ),
        ),
      ),
    );
    await Future.delayed(duration); // 用于等待toast消失
  }
}
