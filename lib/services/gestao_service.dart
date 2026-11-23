import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class GestaoService {
  static Future<dynamic> requisitar(
    String metodo,
    String caminho, [
    Map<String, dynamic>? dados,
  ]) async {
    final token = await AuthService.obterToken();
    if (token == null || token.isEmpty)
      throw Exception('Entre novamente na sua conta.');
    final req = http.Request(
      metodo,
      Uri.parse('${AuthService.baseUrl}/api/v1/$caminho'),
    );
    req.headers.addAll({
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (dados != null) req.body = jsonEncode(dados);
    final resposta = await req
        .send()
        .then(http.Response.fromStream)
        .timeout(const Duration(seconds: 45));
    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw Exception(AuthService.mensagemErro(resposta));
    }
    return resposta.bodyBytes.isEmpty
        ? null
        : jsonDecode(utf8.decode(resposta.bodyBytes));
  }
}
