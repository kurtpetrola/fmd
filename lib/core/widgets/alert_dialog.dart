// alert_dialog.dart

import 'package:flutter/material.dart';
import 'package:findmydorm/core/widgets/custom_button.dart';
import 'package:findmydorm/core/theme/app_colors.dart';

enum DialogsAction { yes, cancel }

/// Utility class for displaying standard alert dialogs.
class AlertDialogs {
  static Future<DialogsAction> yesCancelDialog(
    BuildContext context,
    String title,
    String body,
  ) async {
    final theme = Theme.of(context);

    final action = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.textPrimary,
            fontFamily: theme.textTheme.titleLarge?.fontFamily ?? 'Lato',
          ),
          contentTextStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: AppColors.textSecondary,
            fontFamily: theme.textTheme.bodyMedium?.fontFamily ?? 'Lato',
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            Column(
              children: [
                CustomButton(
                  text: 'CONFIRM',
                  onPressed: () => Navigator.of(context).pop(DialogsAction.yes),
                  backgroundColor: theme.colorScheme.primary,
                  textColor: AppColors.textWhite,
                  borderRadius: 12,
                  elevation: 0,
                  height: 50.0,
                  width: double.infinity,
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'CANCEL',
                  onPressed: () =>
                      Navigator.of(context).pop(DialogsAction.cancel),
                  backgroundColor: Colors.transparent,
                  textColor: AppColors.textPrimary,
                  borderRadius: 12,
                  elevation: 0,
                  height: 50.0,
                  width: double.infinity,
                  border: const BorderSide(color: AppColors.borderLight, width: 1),
                ),
              ],
            ),
          ],
        );
      },
    );
    return action ?? DialogsAction.cancel;
  }
}
