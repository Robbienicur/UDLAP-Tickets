import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/boleto.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  static const String baseUrl = 'http://localhost:8001/api';
  String? _token;

  // Singleton pattern
  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Cache-Control': 'no-cache, no-store, must-revalidate',
    'Pragma': 'no-cache',
    'Expires': '0',
    if (_token != null) 'Authorization': 'Token $_token',
  };

  Future<List<Boleto>> getBoletos() async {
    try {
      // Añadimos un timestamp para evitar cache del navegador
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await http.get(
        Uri.parse('$baseUrl/boletos/?t=$timestamp'),
        headers: _headers,
      );
      
      print('DEBUG API: GET boletos - Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Boleto.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar boletos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getBoletos: $e');
      return [];
    }
  }

  Future<bool> comprarBoletos(int cantidad) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/boletos/comprar/'),
        body: json.encode({'cantidad': cantidad}),
        headers: _headers,
      );
      print('DEBUG API: POST comprar - Status: ${response.statusCode}');
      return response.statusCode == 201;
    } catch (e) {
      print('Error en comprarBoletos: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        body: json.encode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('DEBUG API: POST login - Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        print('DEBUG API: Token recibido y guardado');
        return true;
      }
      return false;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  void logout() {
    print('DEBUG API: Logout - Limpiando token');
    _token = null;
  }
}
