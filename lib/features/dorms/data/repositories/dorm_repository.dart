import 'package:findmydorm/core/database/database_helper.dart';
import 'package:findmydorm/features/dorms/domain/models/dorm_model.dart';

/// Abstracts all dormitory-related database operations.
///
/// This repository acts as a single point of access for dorm data,
/// decoupling ViewModels and pages from the [DatabaseHelper] implementation.
class DormRepository {
  final DatabaseHelper _dbHelper;

  DormRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Fetches all dorms from the database, ordered by name.
  Future<List<Dorms>> getDorms() => _dbHelper.getDorms();

  /// Inserts a new dorm into the database. Returns the new row ID.
  Future<int> insertDorm(Dorms dorm) => _dbHelper.insertDorm(dorm);

  /// Updates an existing dorm's record. Returns rows affected.
  Future<int> updateDorm(Dorms dorm) => _dbHelper.updateDorm(dorm);

  /// Deletes a dorm record by its ID. Returns rows affected.
  Future<int> deleteDorm(int dormId) => _dbHelper.deleteDorm(dormId);

  /// Adds a dorm to the user's favorites list.
  Future<int> addFavorite(int usrId, int dormId) =>
      _dbHelper.addFavorite(usrId, dormId);

  /// Removes a dorm from the user's favorites list.
  Future<int> removeFavorite(int usrId, int dormId) =>
      _dbHelper.removeFavorite(usrId, dormId);

  /// Checks if a specific dorm is marked as a favorite by the user.
  Future<bool> isDormFavorite(int usrId, int dormId) =>
      _dbHelper.isDormFavorite(usrId, dormId);

  /// Retrieves the list of all dorms favorited by a given user.
  Future<List<Dorms>> getFavoriteDorms(int usrId) =>
      _dbHelper.getFavoriteDorms(usrId);

  /// Retrieves the total count of dorms marked as favorite by a user.
  Future<int> getFavoriteDormsCount(int usrId) =>
      _dbHelper.getFavoriteDormsCount(usrId);
}
