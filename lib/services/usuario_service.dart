import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/usuario_model.dart';
import 'auth_service.dart';

class UsuarioService {
  static const String baseUrl =
      'https://backend-nhac.onrender.com';

  static const String usuariosUrl =
      '$baseUrl/api/v1/usuarios';

  Future<UsuarioModel> buscarUsuario(String usuarioId) async {
    final token = await AuthService.obterToken();

    if (token == null || token.isEmpty) {
      throw Exception('Usuário não autenticado.');
    }

    final response = await http.get(
      Uri.parse('$usuariosUrl/$usuarioId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar usuário '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final body =
        jsonDecode(response.body) as Map<String, dynamic>;

    return UsuarioModel.fromJson(body);
  }
}