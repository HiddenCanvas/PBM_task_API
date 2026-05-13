import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';
  final storage = const FlutterSecureStorage();

  // Header dasar yang WAJIB untuk Laravel + Inertia
  Map<String, String> _baseHeaders() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Header dengan token autentikasi
  Future<Map<String, String>> _authHeaders({String? customToken}) async {
    final token = customToken ?? await getToken();
    return {..._baseHeaders(), 'Authorization': 'Bearer $token'};
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  // ==================== LOGIN ====================
  Future<UserModel> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: _baseHeaders(),
      body: jsonEncode({'username': username, 'password': password}),
    );

    print('LOGIN STATUS: ${response.statusCode}');
    print('LOGIN BODY: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Cari token dari berbagai kemungkinan lokasi
      String? token;
      if (data['token'] is String) {
        token = data['token'];
      } else if (data['access_token'] is String) {
        token = data['access_token'];
      } else if (data['data'] != null) {
        final d = data['data'];
        if (d is String)
          token = d;
        else if (d is Map) {
          token = d['token'] ?? d['access_token'];
        }
      }

      // Cek format Sanctum plainTextToken
      if (token == null) {
        final obj = data['token'] ?? data['data']?['token'];
        if (obj is Map && obj.containsKey('plainTextToken')) {
          token = obj['plainTextToken'];
        }
      }

      // Fallback ke user object
      final userData = data['user'] ?? data['data']?['user'] ?? data;
      if (token == null && userData is Map) {
        token = userData['token'] ?? userData['access_token'];
      }

      if (token == null || token.toString().isEmpty) {
        throw Exception('Token tidak ditemukan. Response: ${response.body}');
      }

      await storage.write(key: 'token', value: token.toString());

      return UserModel.fromJson({
        'id': userData is Map ? userData['id'] : null,
        'name': userData is Map ? (userData['name'] ?? username) : username,
        'username': userData is Map
            ? (userData['username'] ?? username)
            : username,
        'token': token.toString(),
      });
    } else {
      throw Exception('Login gagal: ${response.body}');
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    await storage.delete(key: 'token');
  }

  // ==================== GET PRODUCTS ====================
  Future<List<ProductModel>> getProducts({String? customToken}) async {
    final headers = await _authHeaders(customToken: customToken);

    final response = await http.get(
      Uri.parse('$baseUrl/api/products'),
      headers: headers,
    );

    print('GET PRODUCTS STATUS: ${response.statusCode}');
    print('GET PRODUCTS BODY: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List items = [];
      if (data is List) {
        items = data;
      } else if (data is Map) {
        // Format aktual API: {"success":true,"data":{"products":[...]}}
        if (data['data'] is Map && data['data']['products'] is List) {
          items = data['data']['products'];
        } else if (data['data'] is List) {
          items = data['data'];
        } else if (data['data'] is Map && data['data']['data'] is List) {
          items = data['data']['data'];
        } else if (data['products'] is List) {
          items = data['products'];
        }
      }

      print('PARSED ITEMS COUNT: ${items.length}');
      return items
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      throw Exception('Gagal memuat produk: ${response.body}');
    }
  }

  // ==================== ADD PRODUCT ====================
  Future<ProductModel> addProduct(
    String name,
    int price,
    String description,
  ) async {
    final headers = await _authHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/api/products'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
      }),
    );

    print('ADD PRODUCT STATUS: ${response.statusCode}');
    print('ADD PRODUCT BODY: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      Map<String, dynamic> productData;
      if (data['data'] != null && data['data'] is Map) {
        productData = Map<String, dynamic>.from(data['data']);
      } else if (data['product'] != null && data['product'] is Map) {
        productData = Map<String, dynamic>.from(data['product']);
      } else {
        productData = Map<String, dynamic>.from(data);
      }

      return ProductModel.fromJson(productData);
    } else {
      throw Exception('Gagal menambah produk: ${response.body}');
    }
  }

  // ==================== DELETE PRODUCT ====================
  Future<void> deleteProduct(int id) async {
    final headers = await _authHeaders();

    final response = await http.delete(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: headers,
    );

    print('DELETE STATUS: ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus produk: ${response.body}');
    }
  }

  // ==================== SUBMIT TUGAS ====================
  Future<void> submitTugas(
    String name,
    int price,
    String description,
    String githubUrl,
  ) async {
    final headers = await _authHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/api/products/submit'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'github_url': githubUrl,
      }),
    );

    print('SUBMIT STATUS: ${response.statusCode}');
    print('SUBMIT BODY: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Gagal mensubmit tugas: ${response.body}');
    }
  }
}
