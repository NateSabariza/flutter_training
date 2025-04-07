import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../domain/models/user.dart';

class UserService {
  final String baseUrl = 'http://192.168.1.20:8080';

  Future<List<User>> fetchUsers() async {
    try{
      final response = await http.get(Uri.parse('$baseUrl/api/users?page=0'));
      final List data = json.decode(response.body)['data'];

      return data.map((e) => User(
        id: e['id'],
        email: e['email'],
        firstName: e['firstName'],
        lastName: e['lastName'],
        avatar: e['avatar'],
      )).toList();
    } catch(e) {
      print('Error Fetching Users: $e');
      return [];
    }  
  }

  Future<Map<String, dynamic>?> createUser({
    required String email,
    required String firstName,
    required String lastName,
    required String avatar,
  }) async {
    try {
        final response = await http.post(
        Uri.parse('$baseUrl/api/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'avatar': avatar,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e){
      print('Error Creating User: $e');
      return null;
    }

  }

  Future<Map<String, dynamic>?> updateUser(
    int userId,
    Map<String, dynamic> userData
  ) async {
    try {
      print('$baseUrl/api/users/$userId');
      final response = await http.put(
        Uri.parse('http://192.168.1.20:8080/api/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e){
      print('Error Updating User: $e');
      return null;
    }
  }

  Future<bool> deleteUser(int userId) async {
  try {
    final response = await http.delete(Uri.parse('$baseUrl/api/users/$userId'));
    return response.statusCode == 200;
  } catch (e) {
    print('Delete user error: $e');
    return false;
  }
}

}