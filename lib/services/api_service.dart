import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';
  final storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<UserModel> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Cari token dengan sangat agresif
      String? extractedToken;
      
      if (data['token'] is String) extractedToken = data['token'];
      else if (data['access_token'] is String) extractedToken = data['access_token'];
      else if (data['data'] != null) {
        if (data['data'] is String) extractedToken = data['data']; // sometimes token is direct in data
        else if (data['data']['token'] is String) extractedToken = data['data']['token'];
        else if (data['data']['access_token'] is String) extractedToken = data['data']['access_token'];
      }
      
      // Jika token berbentuk object (misal Sanctum newAccessToken object)
      if (extractedToken == null) {
        final possibleTokenObj = data['token'] ?? (data['data'] != null ? data['data']['token'] : null);
        if (possibleTokenObj is Map && possibleTokenObj.containsKey('plainTextToken')) {
          extractedToken = possibleTokenObj['plainTextToken'];
        }
      }

      // Fallback terakhir ke user object
      final userData = data['user'] ?? (data['data'] != null ? data['data']['user'] : null) ?? data;
      if (extractedToken == null) {
        if (userData != null && userData is Map) {
          extractedToken = userData['token'] is String ? userData['token'] : userData['access_token'];
        }
      }

      if (extractedToken == null || extractedToken.isEmpty) {
        throw Exception('Token tidak ditemukan dalam respons server: ${response.body}');
      }

      final String finalToken = extractedToken.toString();
      await storage.write(key: 'token', value: finalToken);

      return UserModel.fromJson({
        'id': userData is Map ? userData['id'] : null,
        'name': userData is Map ? userData['name'] : username,
        'username': userData is Map ? userData['username'] : username,
        'token': finalToken,
      });
    } else {
      throw Exception('Login gagal: ${response.body}');
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
  }

  Future<List<ProductModel>> getProducts({String? customToken}) async {
    final token = customToken ?? await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      List items = [];
      if (data is List) {
        items = data;
      } else if (data['data'] is List) {
        items = data['data'];
      } else if (data['data'] != null && data['data']['data'] is List) {
        // Handle Laravel Pagination format
        items = data['data']['data'];
      } else if (data['products'] is List) {
        items = data['products'];
      } else if (data['items'] is List) {
        items = data['items'];
      } else if (data['results'] is List) {
        items = data['results'];
      }

      return items.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat produk: ${response.body}');
    }
  }

  Future<ProductModel> addProduct(String name, int price, String description) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final productData = data['data'] ?? data;
      return ProductModel.fromJson(productData);
    } else {
      throw Exception('Gagal menambah produk: ${response.body}');
    }
  }

  Future<void> deleteProduct(int id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus produk: ${response.body}');
    }
  }

  Future<void> submitTugas(String name, int price, String description, String githubUrl) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/products/submit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'github_url': githubUrl,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal mensubmit tugas: ${response.body}');
    }
  }
}