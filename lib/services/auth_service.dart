import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
      'https://backend-nhac.onrender.com';

  static const String authUrl =
      '$baseUrl/api/v1/auth';

  static const String _tokenKey = 'jwt_token';
  static const String _usuarioIdKey = 'usuario_id';

  // =========================
  // TOKEN
  // =========================

  static Future<void> salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    print('🔐 Token salvo com sucesso.');
  }

  static Future<String?> obterToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // =========================
  // ID DO USUÁRIO
  // =========================

  static Future<void> salvarUsuarioId(String usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usuarioIdKey, usuarioId);

    print('👤 ID do usuário salvo: $usuarioId');
  }

  static Future<String?> obterUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usuarioIdKey);
  }

  // =========================
  // REMOVER AUTENTICAÇÃO
  // =========================

  static Future<void> removerToken() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_usuarioIdKey);

    print('🔓 Token e ID removidos.');
  }

  static Future<bool> possuiToken() async {
    final token = await obterToken();
    return token != null && token.isNotEmpty;
  }

  // =========================
  // LOGIN
  // =========================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    print('➡️ Fazendo login: $email');

    final response = await http
        .post(
          Uri.parse('$authUrl/login'),
          headers: {
            'Content-Type': 'application/json',
            'X-App-Origin': 'loja',
          },
          body: jsonEncode({
            'email': email,
            'senha': senha,
          }),
        )
        .timeout(
          const Duration(seconds: 30),
        );

    print('⬅️ Status: ${response.statusCode}');
    print('⬅️ Resposta: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(_mensagemErro(response));
    }

    final body = jsonDecode(response.body);

    if (body is! Map<String, dynamic>) {
      throw Exception(
        'Resposta inválida da API de autenticação.',
      );
    }

    // =========================
    // TOKEN
    // =========================

    final token = body['token']?.toString();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Login realizado, mas a API não retornou o token JWT.',
      );
    }

    // =========================
    // ID DO USUÁRIO
    // =========================

    final usuarioId = body['usuarioId']?.toString();
    if (usuarioId == null || usuarioId.isEmpty) {
      throw Exception(
        'Login realizado, mas a API não retornou o ID do usuário.',
      );
    }

    // Salva os dois
    await salvarToken(token);
    await salvarUsuarioId(usuarioId);

    return body;
  }

  // =========================
  // LOGOUT
  // =========================

  static Future<void> logout() async {
    await removerToken();
  }

  // =========================
  // OUTROS MÉTODOS
  // =========================

  static Future<void> enviarCodigoCadastro(String email) async {
    print('➡️ Enviando código para: $email');

    final response = await http
        .post(
          Uri.parse('$authUrl/enviar-codigo-cadastro'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
          }),
        )
        .timeout(
          const Duration(seconds: 30),
        );

    print('⬅️ Status: ${response.statusCode}');
    print('⬅️ Resposta: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(_mensagemErro(response));
    }
  }

  static Future<void> confirmarEmailCadastro({
    required String email,
    required String codigo,
  }) async {
    print('➡️ Confirmando código do e-mail');

    final response = await http
        .post(
          Uri.parse('$authUrl/confirmar-email-cadastro'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'codigo': codigo,
          }),
        )
        .timeout(
          const Duration(seconds: 30),
        );

    print('⬅️ Status: ${response.statusCode}');
    print('⬅️ Resposta: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(_mensagemErro(response));
    }
  }

  static Future<Map<String, dynamic>> registrar({
    required String id,
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    print('➡️ Registrando usuário: $email');

    final response = await http
        .post(
          Uri.parse('$authUrl/registrar'),
          headers: {
            'Content-Type': 'application/json',
            'X-App-Origin': 'loja',
          },
          body: jsonEncode({
            'id': id,
            'nome': nome,
            'email': email,
            'telefone': telefone,
            'senha': senha,
          }),
        )
        .timeout(
          const Duration(seconds: 30),
        );

    print('⬅️ Status: ${response.statusCode}');
    print('⬅️ Resposta: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception(_mensagemErro(response));
    }

    final body = jsonDecode(response.body);

    if (body is! Map<String, dynamic>) {
      throw Exception(
        'Resposta inválida da API de autenticação.',
      );
    }

    final token = body['token']?.toString();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Usuário cadastrado, mas a API não retornou o token JWT.',
      );
    }

    await salvarToken(token);

    final usuarioId = body['id']?.toString();

    if (usuarioId != null && usuarioId.isNotEmpty) {
      await salvarUsuarioId(usuarioId);
    }

    return body;
  }

  static String _mensagemErro(http.Response response) {
    if (response.body.isEmpty) {
      return 'Erro ${response.statusCode}';
    }

    try {
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        return body['message']?.toString() ??
            body['erro']?.toString() ??
            body['error']?.toString() ??
            'Erro ${response.statusCode}';
      }
    } catch (_) {}

    return 'Erro ${response.statusCode}: ${response.body}';
  }
}
