import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UploadService {
  static const String uploadUrl =
      'https://backend-nhac.onrender.com/api/v1/uploads/imagem';

  Future<String> enviarImagem({
    required File arquivo,
    required String token,
    String pasta = 'lojas',
  }) async {
    final ext = arquivo.path.split('.').last.toLowerCase();
    final subtype = switch (ext) {
      'png' => 'png',
      'webp' => 'webp',
      _ => 'jpeg',
    };

    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json'
      ..fields['pasta'] = pasta
      ..files.add(
        await http.MultipartFile.fromPath(
          'arquivo', // mesmo nome do @RequestParam("arquivo")
          arquivo.path,
          contentType: MediaType('image', subtype),
        ),
      );

    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 201) {
      throw Exception(
        'Erro ao enviar imagem (${response.statusCode}): ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final url = body['url']?.toString();
    if (url == null || url.isEmpty) {
      throw Exception('Resposta do upload sem URL.');
    }
    return url;
  }
}