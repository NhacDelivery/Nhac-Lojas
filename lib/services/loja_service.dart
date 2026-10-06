import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nhac_lojas/models/cadastro_loja.dart';
import 'package:nhac_lojas/services/upload_service.dart';
import 'package:nhac_lojas/models/loja_model.dart';
class LojaService {
  static const String baseUrl = 'https://backend-nhac.onrender.com';

  static const String lojasUrl = '$baseUrl/api/v1/lojas';

  Future<Map<String, dynamic>> criarLoja({
    required CadastroLoja cadastro,
    required String token,
  }) async {
    print('➡️ Criando loja: ${cadastro.nome}');

    try {
      // 1. Envia a foto só se ainda não foi enviada.
      // Em um retry (ex.: falha ao criar a loja) o imagemUrl já existe e
      // não precisa subir o arquivo de novo.
      if (cadastro.imagemArquivo != null &&
          (cadastro.imagemUrl == null || cadastro.imagemUrl!.isEmpty)) {
        print('🖼️ Enviando imagem da loja...');
        cadastro.imagemUrl = await UploadService().enviarImagem(
          arquivo: cadastro.imagemArquivo!,
          token: token,
        );
        print('🖼️ Imagem enviada: ${cadastro.imagemUrl}');
      }

      // 2. Monta o payload sem campos nulos ou vazios
      // (antes imagemUrl ia como '' quando não havia foto).
      final payload = _semVazios(cadastro.toJson());

      print('📦 Payload da loja:');
      print(jsonEncode(payload));

      final response = await http
          .post(
            Uri.parse(lojasUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          // 60s: o Render pode estar "dormindo" e demorar para acordar.
          .timeout(const Duration(seconds: 60));

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
        throw Exception('Resposta inválida ao criar a loja.');
      }

      return body;
    } on TimeoutException {
      throw Exception(
        'O servidor demorou para responder. Tente novamente em instantes.',
      );
    } on SocketException {
      throw Exception('Sem conexão com a internet.');
    }
  }

  /// Remove recursivamente valores nulos e strings vazias.
  Map<String, dynamic> _semVazios(Map<String, dynamic> origem) {
    final resultado = <String, dynamic>{};

    origem.forEach((chave, valor) {
      if (valor == null) return;

      if (valor is String) {
        if (valor.trim().isEmpty) return;
        resultado[chave] = valor.trim();
        return;
      }

      if (valor is Map<String, dynamic>) {
        resultado[chave] = _semVazios(valor);
        return;
      }

      resultado[chave] = valor;
    });

    return resultado;
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

  Future<LojaModel> buscarMinhaLoja(String token) async {
  print('➡️ Buscando minha loja...');

  try {
    final response = await http
        .get(
          Uri.parse('$lojasUrl/minha-loja'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 60));

    print('⬅️ Status minha loja: ${response.statusCode}');
    print('⬅️ Resposta minha loja: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(_mensagemErro(response));
    }

    if (response.body.isEmpty) {
      throw Exception('O servidor não retornou os dados da loja.');
    }

    final body = jsonDecode(response.body);

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao buscar a loja.');
    }

    return LojaModel.fromJson(body);
  } on TimeoutException {
    throw Exception(
      'O servidor demorou para responder. Tente novamente em instantes.',
    );
  } on SocketException {
    throw Exception('Sem conexão com a internet.');
  }
}
}

