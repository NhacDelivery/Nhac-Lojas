import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class LojistaService {
  static const String baseUrl = 'https://backend-nhac.cloud.run';

  static const String lojistaUrl = '$baseUrl/api/v1/lojista';

  final http.Client _client;

  LojistaService({http.Client? client})
      : _client = client ?? http.Client();

  /// Lista os produtos da loja do lojista autenticado.
  Future<Map<String, dynamic>> listarProdutos({
    required String token,
    String? categoriaMenu,
    String? nome,
    int pagina = 0,
    int tamanho = 20,
  }) async {
    final queryParams = <String, String>{
      'page': pagina.toString(),
      'size': tamanho.toString(),
    };

    if (categoriaMenu != null && categoriaMenu.trim().isNotEmpty) {
      queryParams['categoriaMenu'] = categoriaMenu.trim();
    }

    if (nome != null && nome.trim().isNotEmpty) {
      queryParams['nome'] = nome.trim();
    }

    final uri = Uri.parse('$lojistaUrl/produtos')
        .replace(queryParameters: queryParams);

    final response = await _get(uri, token);

    return _decodificarObjeto(response, 'listar produtos');
  }

  /// Busca um produto da loja pelo ID, incluindo inativos.
  Future<Map<String, dynamic>> buscarProdutoPorId({
    required String token,
    required String produtoId,
  }) async {
    final uri = Uri.parse(
      '$lojistaUrl/produtos/${Uri.encodeComponent(produtoId)}',
    );

    final response = await _get(uri, token);

    return _decodificarObjeto(response, 'buscar produto');
  }

  /// Lista os pedidos da loja do lojista autenticado.
  Future<Map<String, dynamic>> listarPedidos({
    required String token,
    String? status,
    int pagina = 0,
    int tamanho = 20,
  }) async {
    final queryParams = <String, String>{
      'page': pagina.toString(),
      'size': tamanho.toString(),
    };

    if (status != null && status.trim().isNotEmpty) {
      queryParams['status'] = status.trim();
    }

    final uri = Uri.parse('$lojistaUrl/pedidos')
        .replace(queryParameters: queryParams);

    final response = await _get(uri, token);

    return _decodificarObjeto(response, 'listar pedidos');
  }

  Future<http.Response> _get(Uri uri, String token) async {
    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        throw Exception(_mensagemErro(response));
      }

      return response;
    } on TimeoutException {
      throw Exception(
        'O servidor demorou para responder. Tente novamente em instantes.',
      );
    } on SocketException {
      throw Exception('Sem conexão com a internet.');
    }
  }

  Map<String, dynamic> _decodificarObjeto(
    http.Response response,
    String operacao,
  ) {
    if (response.body.isEmpty) {
      throw Exception('O servidor não retornou dados ao $operacao.');
    }

    try {
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        return body;
      }

      throw Exception('Formato de resposta inválido ao $operacao.');
    } on FormatException {
      throw Exception('O servidor retornou um JSON inválido.');
    }
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
      // A resposta não contém JSON válido.
    }

    return 'Erro ${response.statusCode}: ${response.body}';
  }

  void dispose() {
    _client.close();
  }
}
