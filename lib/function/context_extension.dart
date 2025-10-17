import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastType { success, info, warn, error }

extension ContextExtension on BuildContext {
  void showToast(String message, [ToastType type = ToastType.success]) {
    final toast = FToast();
    toast.init(this);
    toast.removeCustomToast();
    toast.showToast(
      toastDuration: Duration(milliseconds: 1666),
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
                  ToastType.info => const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                  ),
                  ToastType.warn => const Icon(
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
  }
}
