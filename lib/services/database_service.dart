import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DatabaseService {
  final String baseUrl = "http://192.168.1.7/MOVIZONE_API";

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/auth/login.php");

      final response = await http.post(
        url,
        body: {
          "email": email,
          "password": password,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Server Error: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {
        "status": "error",
        "message": "Failed to connect to server"
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/auth/register.php");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "username": username,
          "email": email,
          "password": password,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Server Error: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {
        "status": "error",
        "message": "Failed to connect to server"
      };
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final url = Uri.parse("$baseUrl/users/get_profile.php?user_id=$userId");

      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Server Error: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {
        "status": "error",
        "message": "Failed to connect to server"
      };
    }
  }

  Future<Map<String, dynamic>> addFavorite({
    required String userId,
    required int movieId,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/favorites/add_favorite.php");

      final response = await http.post(
        url,
        body: {
          "user_id": userId,
          "movie_id": movieId.toString(),
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Server Error: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {
        "status": "error",
        "message": "Failed to connect to server"
      };
    }
  }

  Future<List<dynamic>> getFavorites(String userId) async {
    try {
      final url = Uri.parse("$baseUrl/favorites/get_favorites.php?user_id=$userId");

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteFavorite({
    required String userId,
    required int movieId,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/favorites/delete_favorite.php");

      await http.post(
        url,
        body: {
          "user_id": userId,
          "movie_id": movieId.toString(),
        },
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint("Delete favorite error: $e");
    }
  }

  Future<List<dynamic>> getFavorites2(String userId) async {
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/favorites/get_favorites.php?user_id=$userId"))
          .timeout(const Duration(seconds: 10));

      return json.decode(res.body);
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getUserProfile2(String userId) async {
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/users/get_profile.php?user_id=$userId"))
          .timeout(const Duration(seconds: 10));

      return json.decode(res.body);
    } catch (e) {
      return {"status": "error", "message": "Failed to fetch profile"};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String username,
    File? imageFile,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/users/update_profile.php"),
      );

      request.fields['user_id'] = userId;
      request.fields['username'] = username;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            imageFile.path,
          ),
        );
      }

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      return json.decode(res.body);
    } catch (e) {
      return {"status": "error", "message": "Update failed"};
    }
  }

  Future<Map<String, dynamic>> deleteProfileImage(String userId) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/users/delete_profile_image.php"),
        body: {"user_id": userId},
      );

      return json.decode(res.body);
    } catch (e) {
      return {"status": "error", "message": "Delete failed"};
    }
  }
}