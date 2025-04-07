import 'package:flutter/material.dart';
import '../../../data/services/user_service.dart';
import '../../../domain/models/user.dart';

class UserViewModel extends ChangeNotifier {
  final _service = UserService();
  List<User> users = [];
  bool isLoading = false;

  Future<void> fetchUsers() async {
    isLoading = true;
    notifyListeners();
    users = await _service.fetchUsers();
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteUser(int userId) async {
    final success = await _service.deleteUser(userId);
    if (success) {
      fetchUsers();
    }
  }
}
