// alert_dialog.dart

import 'package:flutter/material.dart';

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
                SizedBox(
                  // Forces button to take full width of the actions area
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50.0), // Taller
                      // Use the App's Primary Amber Color
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () =>
                        Navigator.of(context).pop(DialogsAction.yes),
                    child: const Text(
                      'CONFIRM',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Lato',
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                const SizedBox(height: 10), // Spacing between buttons

                // 2. Secondary Action (CANCEL) - Subtle Background
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50.0), // Taller
                      // Use transparent or very light background
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        // Add a subtle border for definition
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    onPressed: () =>
                        Navigator.of(context).pop(DialogsAction.cancel),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Lato',
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
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
