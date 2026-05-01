import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/boleto.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  static const String baseUrl = 'http://localhost:8001/api';
  String? _token;
  String? _userEmail;
  double _saldo = 0.0;

  // Singleton pattern
  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  String? get token => _token;
  String? get userEmail => _userEmail;
  double get saldo => _saldo;

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
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['nuevo_saldo'] != null) {
          _saldo = (data['nuevo_saldo'] as num).toDouble();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setDouble('saldo', _saldo);
        }
        return true;
      }
      return false;
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
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveSession(data);
        return true;
      }
      return false;
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        body: json.encode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        await _saveSession(data);
        return true;
      }
      return false;
    } catch (e) {
      print('Error en register: $e');
      return false;
    }
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    _token = data['token'];
    _userEmail = data['email'];
    _saldo = (data['saldo'] as num).toDouble();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
    await prefs.setString('email', _userEmail!);
    await prefs.setDouble('saldo', _saldo);
  }

  Future<bool> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userEmail = prefs.getString('email');
    _saldo = prefs.getDouble('saldo') ?? 0.0;
    return _token != null;
  }

  Future<bool> resetPassword(String email, {String? newPassword, bool checkOnly = false}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password/'),
        body: json.encode({
          'email': email,
          'new_password': newPassword,
          'check_only': checkOnly,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error en resetPassword: $e');
      return false;
    }
  }

  Future<bool> consumirBoleto(String codigo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/boletos/consumir/'),
        body: json.encode({'codigo': codigo}),
        headers: _headers,
      );
      print('DEBUG API: POST consumir - Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error en consumirBoleto: $e');
      return false;
    }
  }

  Future<void> logout() async {
    print('DEBUG API: Logout - Limpiando token');
    _token = null;
    _userEmail = null;
    _saldo = 0.0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
