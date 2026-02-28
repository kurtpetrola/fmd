import 'package:flutter/material.dart';
import 'package:findmydorm/domain/models/dorm_model.dart';
import 'package:findmydorm/data/local/database_helper.dart';
import 'package:findmydorm/core/constants/dorm_categories.dart';

class DormViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Dorms> _allDorms = [];
  List<Dorms> _femaleDorms = [];
  List<Dorms> _maleDorms = [];
  List<Dorms> _mixedDorms = [];

  bool _isLoading = true;
  String _errorMessage = '';

  List<Dorms> get allDorms => _allDorms;
  List<Dorms> get femaleDorms => _femaleDorms;
  List<Dorms> get maleDorms => _maleDorms;
  List<Dorms> get mixedDorms => _mixedDorms;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  DormViewModel() {
    loadDorms();
  }

  void clearError() {
    if (_errorMessage.isNotEmpty) {
      _errorMessage = '';
      notifyListeners();
    }
  }

  Future<void> loadDorms() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final fetchedDorms = await _dbHelper.getDorms();

      _femaleDorms = fetchedDorms
          .where((d) => d.genderCategory == DormCategories.genderCategories[0])
          .where((d) => d.isFeatured)
          .toList();

      _maleDorms = fetchedDorms
          .where((d) => d.genderCategory == DormCategories.genderCategories[1])
          .where((d) => d.isFeatured)
          .toList();

      _mixedDorms = fetchedDorms
          .where((d) => d.genderCategory == DormCategories.genderCategories[2])
          .where((d) => d.isFeatured)
          .toList();

      _allDorms = fetchedDorms;
    } catch (e) {
      _errorMessage = 'Failed to load dorms: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refreshes dorm data (useful after a new dorm is added/edited by admin)
  Future<void> refreshDorms() async {
    await loadDorms();
  }
}
