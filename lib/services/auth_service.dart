import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
      'https://backend-nhac.onrender.com';

  static const String authUrl =
      '$baseUrl/api/v1/auth';

  static const String _tokenKey = 'jwt_token';

  static Future<void> salvarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    print('🔐 Token salvo com sucesso.');
  }

  /// Recupera o JWT salvo.
  static Future<String?> obterToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Remove o JWT.
  static Future<void> removerToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);

    print('🔓 Token removido.');
  }

  static Future<bool> possuiToken() async {
    final token = await obterToken();
    return token != null && token.isNotEmpty;
  }

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
final response = await http.post(
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
      throw Exception('Resposta inválida da API de autenticação.');
    }

    final token = body['token']?.toString();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Usuário cadastrado, mas a API não retornou o token JWT.',
      );
    }

    await salvarToken(token);

    return body;
  }

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
      throw Exception('Resposta inválida da API de autenticação.');
    }

    final token = body['token']?.toString();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Login realizado, mas a API não retornou o token JWT.',
      );
    }

    await salvarToken(token);

    return body;
  }

  static Future<void> logout() async {
    await removerToken();
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
    } catch (_) {
    }

    return 'Erro ${response.statusCode}: ${response.body}';
  }
}