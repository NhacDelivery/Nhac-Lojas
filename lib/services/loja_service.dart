import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nhac_lojas/models/cadastro_loja.dart';
import 'package:nhac_lojas/services/upload_service.dart';

class LojaService {
  static const String baseUrl =
      'https://backend-nhac.onrender.com';

  static const String lojasUrl =
      '$baseUrl/api/v1/lojas';

  Future<Map<String, dynamic>> criarLoja({
    required CadastroLoja cadastro,
    required String token,
  }) async {
    print('➡️ Criando loja: ${cadastro.nome}');

    // 1. Envia a foto (se houver) e guarda a URL retornada
    if (cadastro.imagemArquivo != null) {
      print('🖼️ Enviando imagem da loja...');
      cadastro.imagemUrl = await UploadService().enviarImagem(
        arquivo: cadastro.imagemArquivo!,
        token: token,
      );
      print('🖼️ Imagem enviada: ${cadastro.imagemUrl}');
    }

    // 2. Monta o payload a partir do model
    final payload = cadastro.toJson();
    payload['imagemUrl'] = cadastro.imagemUrl ?? '';

    print('📦 Payload da loja:');
    print(jsonEncode(payload));

    final response = await http
        .post(
          Uri.parse(lojasUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',

            // JWT
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        )
        .timeout(
          const Duration(seconds: 30),
        );

    print('⬅️ Status criação loja: ${response.statusCode}');
    print('⬅️ Resposta criação loja: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception(_mensagemErro(response));
    }

    if (response.body.isEmpty) {
      return {};
    }

    final body = jsonDecode(response.body);

    if (body is! Map<String, dynamic>) {
      throw Exception(
        'Resposta inválida ao criar a loja.',
      );
    }

    return body;
  }


  String _mensagemErro(http.Response response) {
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
      // Resposta não é JSON.
    }

    return 'Erro ${response.statusCode}: ${response.body}';
  }
}