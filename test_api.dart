import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true;

  // 1. Login dulu untuk dapat token
  print('=== LOGIN ===');
  final loginReq = await client.postUrl(
    Uri.parse('https://task.itprojects.web.id/api/auth/login'),
  );
  loginReq.headers.set('Content-Type', 'application/json');
  loginReq.headers.set('Accept', 'application/json');
  loginReq.write(jsonEncode({
    'username': '242410102068',
    'password': '242410102068',
  }));
  final loginRes = await loginReq.close();
  final loginBody = await loginRes.transform(utf8.decoder).join();
  print('Login Status: ${loginRes.statusCode}');
  print('Login Body: $loginBody');
  print('');

  // Parse token
  final loginData = jsonDecode(loginBody);
  String? token = loginData['token'] ?? loginData['access_token'] ?? loginData['data']?['token'];
  print('Extracted Token: $token');
  print('');

  if (token == null) {
    print('GAGAL: Token tidak ditemukan!');
    client.close();
    return;
  }

  // 2. Get Products
  print('=== GET PRODUCTS ===');
  final prodReq = await client.getUrl(
    Uri.parse('https://task.itprojects.web.id/api/products'),
  );
  prodReq.headers.set('Content-Type', 'application/json');
  prodReq.headers.set('Accept', 'application/json');
  prodReq.headers.set('Authorization', 'Bearer $token');
  final prodRes = await prodReq.close();
  final prodBody = await prodRes.transform(utf8.decoder).join();
  print('Products Status: ${prodRes.statusCode}');
  print('Products Body:');
  
  // Pretty print JSON
  try {
    final decoded = jsonDecode(prodBody);
    final prettyJson = const JsonEncoder.withIndent('  ').convert(decoded);
    print(prettyJson);
  } catch (e) {
    print(prodBody);
  }

  client.close();
}
