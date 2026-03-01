// alert_dialog.dart

import 'package:flutter/material.dart';
import 'package:findmydorm/core/widgets/custom_button.dart';

enum DialogsAction { yes, cancel }

class AlertDialogs {
  static Future<DialogsAction> yesCancelDialog(
    BuildContext context,
    String title,
    String body,
  ) async {
    // Define the primary color
    final Color primaryColor = Colors.amber.shade700;

    final action = await showDialog(
      context: context,
      // Allow user to tap outside to dismiss (less restrictive)
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          // Apply padding inside the dialog
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),

          titleTextStyle: const TextStyle(
            // Slightly reduced size/weight for better balance
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black87, // Use dark neutral color
            fontFamily: 'Lato',
          ),
          contentTextStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: Colors.black54, // Lighter color for body
            fontFamily: 'Lato',
          ),

          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(16.0)), // Slightly smaller radius

          title: Text(title),
          content: Text(body),

          // -------------------------------------------------------------
          // Actions: Full-Width Stacked Buttons
          // -------------------------------------------------------------
          actions: <Widget>[
            Column(
              children: [
                // 1. Primary Action (CONFIRM/YES)
                CustomButton(
                  text: 'CONFIRM',
                  onPressed: () => Navigator.of(context).pop(DialogsAction.yes),
                  backgroundColor: primaryColor,
                  textColor: Colors.white,
                  borderRadius: 12,
                  elevation: 0,
                  height: 50.0,
                  width: double.infinity,
                ),

                const SizedBox(height: 10), // Spacing between buttons

                // 2. Secondary Action (CANCEL) - Subtle Background
                CustomButton(
                  text: 'CANCEL',
                  onPressed: () =>
                      Navigator.of(context).pop(DialogsAction.cancel),
                  backgroundColor: Colors.transparent,
                  textColor: Colors.black,
                  borderRadius: 12,
                  elevation: 0,
                  height: 50.0,
                  width: double.infinity,
                  border: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ],
            ),
          ],
        );
      },
    );
    // Handles case where user taps outside and action is null (if barrierDismissible: true)
    return action ?? DialogsAction.cancel;
  }
}
