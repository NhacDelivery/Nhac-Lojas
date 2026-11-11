import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/usuario_model.dart';
import 'auth_service.dart';

class UsuarioService {
  static const String baseUrl = 'https://backend-nhac.cloud.run';
  static const String usuariosUrl = '$baseUrl/api/v1/usuarios';

  Future<Map<String, String>> _headers() async {
    final token = await AuthService.obterToken();
    if (token == null || token.isEmpty) {
      throw Exception('Usuário não autenticado.');
    }
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<UsuarioModel> buscarUsuario(String usuarioId) async {
    final response = await http.get(
      Uri.parse('$usuariosUrl/$usuarioId'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar os dados da conta.');
    }
    return UsuarioModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Map<String, bool>> buscarPreferenciasNotificacao(String usuarioId) async {
    final response = await http.get(
      Uri.parse('$usuariosUrl/$usuarioId/preferencias-notificacao'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar as preferências de notificação.');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return {
      'notificarNovoPedido': json['notificarNovoPedido'] == true,
      'notificarMensagens': json['notificarMensagens'] == true,
      'notificarAvaliacoes': json['notificarAvaliacoes'] == true,
      'notificarNovidades': json['notificarNovidades'] == true,
    };
  }

  Future<Map<String, bool>> atualizarPreferenciasNotificacao({
    required String usuarioId,
    required Map<String, bool> preferencias,
  }) async {
    final response = await http.put(
      Uri.parse('$usuariosUrl/$usuarioId/preferencias-notificacao'),
      headers: await _headers(),
      body: jsonEncode(preferencias),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Não foi possível salvar as preferências de notificação.');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return {
      'notificarNovoPedido': json['notificarNovoPedido'] == true,
      'notificarMensagens': json['notificarMensagens'] == true,
      'notificarAvaliacoes': json['notificarAvaliacoes'] == true,
      'notificarNovidades': json['notificarNovidades'] == true,
    };
  }
}
