import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
 static const String baseUrl =
     'https://backend-nhac.onrender.com';


  static const String authUrl =
      '$baseUrl/api/v1/auth';

  /// Envia o código de confirmação para o e-mail.
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

  /// Confirma o código enviado para o e-mail.
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

  /// Finaliza o cadastro.
  ///
  /// Retorna os dados devolvidos pelo backend,
  /// incluindo o token JWT.
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

    return body as Map<String, dynamic>;
  }

  /// Extrai uma mensagem amigável da resposta da API.
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
      // A API retornou algo que não é JSON.
    }

    return 'Erro ${response.statusCode}: ${response.body}';
  }

  /// Faz login com e-mail e senha.
///
/// Retorna os dados devolvidos pelo backend, incluindo o token JWT.
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
            // Identifica que a chamada vem do app da loja.
            // O backend só bloqueia quem manda 'motoboy', então
            // aqui não é obrigatório, mas ajuda a documentar a origem.
            'X-App-Origin': 'loja',
          },
          body: jsonEncode({
            'email': email,
            'senha': senha,
          }),
        )
        .timeout(const Duration(seconds: 30));

    print('⬅️ Status: ${response.statusCode}');
    print('⬅️ Resposta: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(_mensagemErro(response));
    }

    final body = jsonDecode(response.body);
    return body as Map<String, dynamic>;
  }
}