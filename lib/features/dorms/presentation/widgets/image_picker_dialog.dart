// image_picker_dialog.dart

import 'package:flutter/material.dart';
import 'package:findmydorm/core/constants/dorm_image_options.dart';
import 'package:findmydorm/core/widgets/custom_button.dart';
import 'package:findmydorm/core/theme/app_colors.dart';

/// A dialog widget allowing administrators to select a predefined dormitory image.
class ImagePickerDialog extends StatefulWidget {
  final String currentImagePath;

  const ImagePickerDialog({
    super.key,
    required this.currentImagePath,
  });

  @override
  State<ImagePickerDialog> createState() => _ImagePickerDialogState();
}

class _ImagePickerDialogState extends State<ImagePickerDialog> {
  late String selectedImagePath;

  @override
  void initState() {
    super.initState();
    selectedImagePath = widget.currentImagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'Select Dorm Image',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),

            // Grid
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemCount: DormImageOptions.availableImages.length,
                itemBuilder: (context, index) {
                  final imageData = DormImageOptions.availableImages[index];
                  final isSelected = selectedImagePath == imageData['path'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedImagePath = imageData['path']!;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryAmberShade700
                              : AppColors.grey300,
                          width: isSelected ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Image Preview with constrained height
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Image.asset(
                                imageData['path']!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.grey200,
                                    child: const Center(
                                      child: Icon(Icons.image_not_supported,
                                          size: 30),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Label with constrained height
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryAmberShade700
                                    : AppColors.backgroundLight,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    imageData['label']!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? AppColors.textWhite
                                          : AppColors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    imageData['category']!,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: isSelected
                                          ? AppColors.textWhite
                                              .withValues(alpha: 0.7)
                                          : AppColors.grey400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  text: 'CANCEL',
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: AppColors.transparent,
                  textColor: AppColors.grey400,
                  elevation: 0,
                  height: 40,
                  fontSize: 16,
                ),
                const SizedBox(width: 8),
                CustomButton(
                  text: 'SELECT',
                  onPressed: () => Navigator.pop(context, selectedImagePath),
                  backgroundColor: AppColors.primaryAmberShade700,
                  textColor: AppColors.textWhite,
                  borderRadius: 8,
                  height: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
