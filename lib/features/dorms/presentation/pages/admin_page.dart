// admin_page.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:findmydorm/features/dorms/domain/models/dorm_model.dart';
import 'package:findmydorm/core/database/database_helper.dart';
import 'package:findmydorm/core/constants/dorm_categories.dart';
import 'package:findmydorm/core/constants/dorm_image_options.dart';
import 'package:findmydorm/features/dorms/presentation/widgets/image_picker_dialog.dart';
import 'package:findmydorm/features/maps/presentation/widgets/admin_location_picker.dart';
import 'package:findmydorm/features/dorms/presentation/viewmodels/dorm_viewmodel.dart';
import 'package:findmydorm/core/widgets/custom_text_field.dart';
import 'package:findmydorm/core/widgets/custom_button.dart';
import 'package:findmydorm/core/widgets/custom_dropdown_field.dart';
import 'package:findmydorm/core/theme/app_colors.dart';

// NOTE: You would typically import 'package:http/http.dart' as http; for real API calls

/// The administration dashboard for managing dormitories (CRUD operations).
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // ## STATE & INITIALIZATION
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // PRIMARY STYLING REFERENCE (Modified in build)
  Color get _appBarColor => Theme.of(context).colorScheme.primary;
  final Color _errorRed = AppColors.error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshDorms();
    });
  }

  // ## CORE DATA & BUSINESS LOGIC (CRUD + Sync)

  /// Fetches the latest list of dorms from the local database.
  void _refreshDorms() {
    context.read<DormViewModel>().loadDorms();
  }

  /// Simulates/Performs API calls to synchronize local changes with a server.
  Future<void> _syncDormToServer(Dorms dorm, String action) async {
    if (dorm.dormId == null && action != 'create') {
      debugPrint('Warning: Cannot sync dorm without an ID for action: $action');
      return;
    }

    // Simulate a network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // TO DO: IMPLEMENT YOUR ACTUAL SERVER API CALLS HERE
    final endpoint = 'YOUR_SERVER_API_ENDPOINT/dorms/${dorm.dormId}';

    switch (action) {
      case 'create':
        // http.post(Uri.parse('YOUR_SERVER_API_ENDPOINT/dorms'), body: dormsToJson(dorm), ...);
        debugPrint(
            'Dorm ID NEW added. Target endpoint (POST): YOUR_SERVER_API_ENDPOINT/dorms');
        break;
      case 'update':
        // http.put(Uri.parse(endpoint), body: dormsToJson(dorm), ...);
        debugPrint(
            'Dorm ID ${dorm.dormId} updated. Target endpoint (PUT/PATCH): $endpoint');
        break;
      case 'delete':
        // http.delete(Uri.parse(endpoint), ...);
        debugPrint(
            'Dorm ID ${dorm.dormId} deleted. Target endpoint (DELETE): $endpoint');
        break;
      default:
        throw Exception('Invalid sync action: $action');
    }
    // NOTE: You should check the HTTP response status code (e.g., 200 or 204)
    // and throw an exception if the sync fails.
  }

  /// Toggles the featured status of a dorm and updates DB/Server.
  Future<void> _toggleFeatured(Dorms dorm) async {
    if (dorm.dormId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Dormitory ID is missing.')),
      );
      return;
    }

    try {
      // Toggle the featured status
      final updatedDorm = dorm.copyWith(isFeatured: !dorm.isFeatured);

      // Update in database and sync to server
      await _dbHelper.updateDorm(updatedDorm);
      await _syncDormToServer(updatedDorm, 'update');

      if (!mounted) return;

      // Refresh UI and show feedback
      _refreshDorms();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedDorm.isFeatured
                ? '${dorm.dormName} marked as FEATURED!'
                : '${dorm.dormName} removed from featured.',
          ),
          backgroundColor:
              updatedDorm.isFeatured ? AppColors.success : AppColors.wazeOrange,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update featured status: $e')),
      );
    }
  }

  /// Deletes a dorm locally and remotely.
  void _deleteDorm(Dorms dorm) async {
    if (dorm.dormId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Dormitory ID is missing.')),
      );
      return;
    }

    try {
      // 1. Delete from local SQLite DB
      await _dbHelper.deleteDorm(dorm.dormId!);

      // 2. Delete from server
      await _syncDormToServer(dorm, 'delete');

      if (!mounted) return;

      // 3. Refresh UI and show success message
      _refreshDorms();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${dorm.dormName} deleted locally and synced to server!')),
      );
    } catch (e) {
      if (!mounted) return;
      // Handle potential sync errors
      _refreshDorms(); // Try to refresh even on error to see current local state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to delete or sync ${dorm.dormName}. Error: $e')),
      );
    }
  }

  // ## WIDGET BUILD METHODS (UI Layout)

  @override
  Widget build(BuildContext context) {
    final dormVM = context.watch<DormViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin: Dormitory CRUD',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
        backgroundColor: _appBarColor,
        foregroundColor: AppColors.textWhite,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh), // refresh for quick data update
            onPressed: _refreshDorms,
            tooltip: 'Refresh List',
          ),
          IconButton(
            // Changed to the standard 'add' icon
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDormDialog(context),
            tooltip: 'Add New Dorm',
          ),
        ],
      ),
      body: dormVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dormVM.errorMessage.isNotEmpty
              ? Center(
                  child: Text(dormVM.errorMessage,
                      style: const TextStyle(color: AppColors.error)))
              : dormVM.allDorms.isEmpty
                  ? const Center(
                      child: Text(
                          'No local dormitories found. Click + to add one.'))
                  : _buildDormList(dormVM.allDorms),
    );
  }

  Widget _buildDormList(List<Dorms> dorms) {
    return ListView.builder(
      itemCount: dorms.length,
      itemBuilder: (context, index) {
        final dorm = dorms[index];
        return _buildDormCard(dorm);
      },
    );
  }

  // ## CARD AND DIALOG UI HELPERS

  /// Builds a single Card UI for a Dormitory item in the list.
  Widget _buildDormCard(Dorms dorm) {
    final Color adminDeleteColor = _errorRed;
    final Color primaryAmber = _appBarColor;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            // DORM IMAGE PREVIEW
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                dorm.dormImageAsset,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: AppColors.grey300,
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dorm Name with Featured Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dorm.dormName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // NEW: Featured Badge
                      if (dorm.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAmber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star,
                                  size: 12, color: AppColors.textWhite),
                              SizedBox(width: 4),
                              Text(
                                'FEATURED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Location Details
                  _buildDetailRow(Icons.location_on_outlined, dorm.dormLocation,
                      primaryAmber),
                  const SizedBox(height: 4),

                  // Category Badges
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildSmallBadge(
                        DormCategories.getGenderIcon(dorm.genderCategory),
                        dorm.genderCategory,
                        DormCategories.getGenderColor(dorm.genderCategory),
                      ),
                      _buildSmallBadge(
                        DormCategories.getPriceIcon(dorm.priceCategory),
                        dorm.priceCategory,
                        DormCategories.getPriceColor(dorm.priceCategory),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons Column
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // NEW: Featured Toggle Button
                IconButton(
                  icon: Icon(
                    dorm.isFeatured ? Icons.star : Icons.star_border,
                    color: dorm.isFeatured
                        ? AppColors.primaryAmber
                        : AppColors.grey400,
                    size: 28,
                  ),
                  onPressed: () => _toggleFeatured(dorm),
                  tooltip: dorm.isFeatured
                      ? 'Remove from Featured'
                      : 'Add to Featured',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 4),
                // Edit and Delete buttons in a row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: primaryAmber, size: 22),
                      onPressed: () => _showEditDormDialog(context, dorm),
                      tooltip: 'Edit Dorm',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.delete_forever,
                          color: adminDeleteColor, size: 24),
                      onPressed: () => _deleteDorm(dorm),
                      tooltip: 'Delete Dorm',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the image selection dialog and returns the selected path.
  Future<String?> _showImagePickerDialog(String currentImagePath) async {
    return await showDialog<String>(
      context: context,
      builder: (context) =>
          ImagePickerDialog(currentImagePath: currentImagePath),
    );
  }

  // --- Common UI Helper Widgets ---

  /// Helper widget for cleaner data presentation.
  Widget _buildDetailRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style:
                const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Helper widget for small category badges in the card.
  Widget _buildSmallBadge(String icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            label.length > 10 ? label.substring(0, 10) : label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method for category dropdown menus in dialogs.
  Widget _buildCategoryDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: CustomDropdownField<String>(
        labelText: label,
        value: value,
        items: options.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // ## DIALOGS

  /// Shows the dialog for creating a new dorm entry.
  Future<void> _showAddDormDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController numberController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController latController = TextEditingController();
    final TextEditingController lngController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    // Track selected state
    String selectedImagePath = DormImageOptions.getDefaultImage();
    String selectedGenderCategory = 'Mixed/General';
    String selectedPriceCategory = 'Standard';
    bool isFeatured = false;

    String validationError = '';
    final Color errorRed = _errorRed; // Use the class variable

    await showDialog(
      context: context,
      builder: (dialogContext) {
        // Use StatefulBuilder to manage local state changes within the dialog
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Add New Dormitory',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // SIMPLE IMAGE SELECTOR BUTTON
                    InkWell(
                      onTap: () async {
                        final pickedImage =
                            await _showImagePickerDialog(selectedImagePath);
                        if (pickedImage != null) {
                          stfSetState(() {
                            selectedImagePath = pickedImage;
                          });
                        }
                      },
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.primaryAmberShade700, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.inputFill,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate,
                                size: 40, color: AppColors.primaryAmber),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap to Select Dorm Image',
                              style: TextStyle(
                                color: AppColors.grey700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedImagePath
                                  .split('/')
                                  .last
                                  .replaceAll('.png', '')
                                  .replaceAll('_', ' '),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryAmber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Input fields
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: CustomTextField(
                        controller: nameController,
                        labelText: 'Dorm Name',
                        hintText: '(Required)',
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: CustomTextField(
                        controller: numberController,
                        labelText: 'Dorm Number (Optional)',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: CustomTextField(
                        controller: locationController,
                        labelText: 'Location/Address Text',
                        hintText: '(Required)',
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                        minLines: 2,
                        maxLines: 3,
                        alignLabelWithHint: true,
                      ),
                    ),

                    // Gender Category Dropdown
                    _buildCategoryDropdown(
                      label: 'Gender Category',
                      value: selectedGenderCategory,
                      options: DormCategories.genderCategories,
                      onChanged: (value) {
                        if (value != null) {
                          stfSetState(() {
                            selectedGenderCategory = value;
                          });
                        }
                      },
                    ),

                    // Price Category Dropdown
                    _buildCategoryDropdown(
                      label: 'Price Category',
                      value: selectedPriceCategory,
                      options: DormCategories.priceCategories,
                      onChanged: (value) {
                        if (value != null) {
                          stfSetState(() {
                            selectedPriceCategory = value;
                          });
                        }
                      },
                    ),

                    // Featured Checkbox
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: AppColors.detailPurpleLight,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color:
                                AppColors.primaryAmber.withValues(alpha: 0.3),
                            width: 1),
                      ),
                      child: CheckboxListTile(
                        title: const Text(
                          'Mark as Featured',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        subtitle: const Text(
                          'Featured dorms appear on the home page',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.grey600),
                        ),
                        value: isFeatured,
                        activeColor: AppColors.primaryAmber,
                        onChanged: (value) {
                          stfSetState(() {
                            isFeatured = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: CustomTextField(
                        controller: descriptionController,
                        labelText: 'Dorm Description/Details',
                        keyboardType: TextInputType.multiline,
                        minLines: 4,
                        maxLines: 8,
                        alignLabelWithHint: true,
                      ),
                    ),

                    // Display validation error below fields
                    if (validationError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Text(
                          validationError,
                          style: TextStyle(
                              color: errorRed, fontWeight: FontWeight.bold),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Location Picker Button
                    CustomButton(
                      icon: Icons.location_on,
                      text: latController.text.isEmpty
                          ? 'SELECT LOCATION ON MAP'
                          : 'LOCATION SELECTED',
                      onPressed: () async {
                        final LatLng? pickedLocation = await Navigator.push(
                          stfContext,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AdminLocationPicker()),
                        );

                        if (pickedLocation != null) {
                          stfSetState(() {
                            // Call local setState to update the button text
                            latController.text =
                                pickedLocation.latitude.toStringAsFixed(6);
                            lngController.text =
                                pickedLocation.longitude.toStringAsFixed(6);
                          });
                        }
                      },
                      width: double.infinity,
                      height: 45,
                      backgroundColor: latController.text.isEmpty
                          ? AppColors.primaryAmber
                          : AppColors.success,
                      textColor: AppColors.textWhite,
                      borderRadius: 8,
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                            child: CustomTextField(
                                controller: latController,
                                labelText: 'Latitude',
                                readOnly: true,
                                fillColor: AppColors.grey200)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: CustomTextField(
                                controller: lngController,
                                labelText: 'Longitude',
                                readOnly: true,
                                fillColor: AppColors.grey200)),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                // CANCEL Button (Secondary action: TextButton with Red color)
                CustomButton(
                  text: 'CANCEL',
                  onPressed: () => Navigator.pop(stfContext),
                  backgroundColor: Colors.transparent,
                  textColor: AppColors.textSecondary,
                  elevation: 0,
                  height: 45,
                  fontSize: 16,
                ),
                CustomButton(
                  text: 'ADD DORM',
                  onPressed: () async {
                    // Basic validation check
                    if (nameController.text.isNotEmpty &&
                        locationController.text.isNotEmpty &&
                        latController.text.isNotEmpty &&
                        lngController.text.isNotEmpty) {
                      // Clear error on success attempt
                      if (validationError.isNotEmpty) {
                        stfSetState(() => validationError = '');
                      }
                      final newDorm = Dorms(
                        dormName: nameController.text,
                        dormNumber: numberController.text.isEmpty
                            ? 'N/A'
                            : numberController.text,
                        dormLocation: locationController.text,
                        // Pass the description
                        dormDescription: descriptionController.text.isEmpty
                            ? 'No description provided.'
                            : descriptionController.text,
                        dormImageAsset: selectedImagePath,
                        genderCategory: selectedGenderCategory,
                        priceCategory: selectedPriceCategory,
                        isFeatured: isFeatured,
                        latitude: double.tryParse(latController.text),
                        longitude: double.tryParse(lngController.text),
                        createdAt: DateTime.now().toIso8601String(),
                      );

                      try {
                        // Insert locally and get the new ID
                        final newId = await _dbHelper.insertDorm(newDorm);
                        final dormWithId =
                            newDorm.copyWith(dormId: newId); // Need ID for sync

                        // Sync to server (Action: 'create')
                        await _syncDormToServer(dormWithId, 'create');

                        if (context.mounted) {
                          Navigator.pop(stfContext);
                          _refreshDorms();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '${newDorm.dormName} added and synced!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to add dorm: $e')),
                          );
                        }
                      }
                    } else {
                      stfSetState(() {
                        validationError =
                            'Please fill all required text fields and pick a location.';
                      });
                    }
                  },
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  textColor: AppColors.textWhite,
                  borderRadius: 10,
                  height: 45,
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Shows the dialog for editing an existing dorm entry.
  Future<void> _showEditDormDialog(
      BuildContext context, Dorms dormToEdit) async {
    final TextEditingController nameController =
        TextEditingController(text: dormToEdit.dormName);
    final TextEditingController numberController =
        TextEditingController(text: dormToEdit.dormNumber);
    final TextEditingController locationController =
        TextEditingController(text: dormToEdit.dormLocation);
    final TextEditingController descriptionController =
        TextEditingController(text: dormToEdit.dormDescription);
    final TextEditingController latController = TextEditingController(
        text: dormToEdit.latitude?.toStringAsFixed(6) ?? '');
    final TextEditingController lngController = TextEditingController(
        text: dormToEdit.longitude?.toStringAsFixed(6) ?? '');

    String selectedImagePath = dormToEdit.dormImageAsset;
    String selectedGenderCategory = dormToEdit.genderCategory;
    String selectedPriceCategory = dormToEdit.priceCategory;
    bool isFeatured = dormToEdit.isFeatured;

    String validationError = '';
    final Color errorRed = _errorRed;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Edit Dormitory: ${dormToEdit.dormName}',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: _appBarColor),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // SIMPLE IMAGE SELECTOR BUTTON
                    InkWell(
                      onTap: () async {
                        final pickedImage =
                            await _showImagePickerDialog(selectedImagePath);
                        if (pickedImage != null) {
                          stfSetState(() {
                            selectedImagePath = pickedImage;
                          });
                        }
                      },
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.amber.shade700, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade100,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 40, color: Colors.amber.shade700),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to Change Image',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedImagePath
                                  .split('/')
                                  .last
                                  .replaceAll('.png', '')
                                  .replaceAll('_', ' '),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Rest of the fields
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: CustomTextField(
                          controller: nameController, labelText: 'Dorm Name'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: CustomTextField(
                          controller: numberController,
                          labelText: 'Dorm Number (Optional)',
                          keyboardType: TextInputType.number),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: CustomTextField(
                        controller: locationController,
                        labelText: 'Location/Address Text',
                        alignLabelWithHint: true,
                      ),
                    ),

                    // Gender Category Dropdown
                    _buildCategoryDropdown(
                      label: 'Gender Category',
                      value: selectedGenderCategory,
                      options: DormCategories.genderCategories,
                      onChanged: (value) {
                        if (value != null) {
                          stfSetState(() {
                            selectedGenderCategory = value;
                          });
                        }
                      },
                    ),

                    // Price Category Dropdown
                    _buildCategoryDropdown(
                      label: 'Price Category',
                      value: selectedPriceCategory,
                      options: DormCategories.priceCategories,
                      onChanged: (value) {
                        if (value != null) {
                          stfSetState(() {
                            selectedPriceCategory = value;
                          });
                        }
                      },
                    ),

                    // Featured Checkbox
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: AppColors.detailPurpleLight,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color:
                                AppColors.primaryAmber.withValues(alpha: 0.3),
                            width: 1),
                      ),
                      child: CheckboxListTile(
                        title: const Text(
                          'Mark as Featured',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        subtitle: const Text(
                          'Featured dorms appear on the home page',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        value: isFeatured,
                        activeColor: AppColors.primaryAmber,
                        onChanged: (value) {
                          stfSetState(() {
                            isFeatured = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: CustomTextField(
                        controller: descriptionController,
                        labelText: 'Dorm Description/Details',
                        keyboardType: TextInputType.multiline,
                        minLines: 4,
                        maxLines: 8,
                        alignLabelWithHint: true,
                      ),
                    ),

                    if (validationError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Text(validationError,
                            style: TextStyle(
                                color: errorRed, fontWeight: FontWeight.bold)),
                      ),

                    const SizedBox(height: 20),

                    CustomButton(
                      icon: Icons.location_on,
                      text: latController.text.isEmpty
                          ? 'SELECT LOCATION ON MAP'
                          : 'LOCATION SELECTED',
                      onPressed: () async {
                        final LatLng? pickedLocation = await Navigator.push(
                          stfContext,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AdminLocationPicker()),
                        );
                        if (pickedLocation != null) {
                          stfSetState(() {
                            latController.text =
                                pickedLocation.latitude.toStringAsFixed(6);
                            lngController.text =
                                pickedLocation.longitude.toStringAsFixed(6);
                          });
                        }
                      },
                      width: double.infinity,
                      height: 45,
                      backgroundColor: latController.text.isEmpty
                          ? Colors.amber.shade700
                          : Colors.green.shade600,
                      textColor: Colors.white,
                      borderRadius: 8,
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                            child: CustomTextField(
                                controller: latController,
                                labelText: 'Latitude',
                                readOnly: true,
                                fillColor: Colors.grey.shade200)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: CustomTextField(
                                controller: lngController,
                                labelText: 'Longitude',
                                readOnly: true,
                                fillColor: Colors.grey.shade200)),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                CustomButton(
                  text: 'CANCEL',
                  onPressed: () => Navigator.pop(stfContext),
                  backgroundColor: Colors.transparent,
                  textColor: Colors.grey,
                  elevation: 0,
                  height: 45,
                  fontSize: 16,
                ),
                CustomButton(
                  text: 'UPDATE DORM',
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        locationController.text.isNotEmpty &&
                        latController.text.isNotEmpty &&
                        lngController.text.isNotEmpty) {
                      final updatedDorm = Dorms(
                        dormId: dormToEdit.dormId,
                        dormName: nameController.text,
                        dormNumber: numberController.text.isEmpty
                            ? 'N/A'
                            : numberController.text,
                        dormDescription: descriptionController.text.isEmpty
                            ? 'No description provided.'
                            : descriptionController.text,
                        dormImageAsset: selectedImagePath,
                        genderCategory: selectedGenderCategory,
                        priceCategory: selectedPriceCategory,
                        isFeatured: isFeatured,
                        dormLocation: locationController.text,
                        latitude: double.tryParse(latController.text),
                        longitude: double.tryParse(lngController.text),
                        createdAt: dormToEdit.createdAt,
                      );

                      try {
                        await _dbHelper.updateDorm(updatedDorm);
                        await _syncDormToServer(updatedDorm, 'update');

                        if (context.mounted) {
                          Navigator.pop(stfContext);
                          _refreshDorms();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '${updatedDorm.dormName} updated locally and server synced!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Failed to update dorm and sync server: $e')),
                          );
                        }
                      }
                    } else {
                      stfSetState(() {
                        validationError =
                            'Please fill all required text fields and pick a location.';
                      });
                    }
                  },
                  backgroundColor: Colors.blue.shade700,
                  textColor: Colors.white,
                  borderRadius: 10,
                  height: 45,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
