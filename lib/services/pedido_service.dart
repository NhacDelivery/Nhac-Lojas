import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pedido_detalhe_lojista_model.dart';
import '../models/pedido_resumo_model.dart';

class PedidoService {
  static const String baseUrl =
      'https://backend-nhac.cloud.run/api/v1';

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<PedidoDetalheLojistaModel> buscarDetalhe({
    required String token,
    required String pedidoId,
  }) async {
    final uri = Uri.parse('$baseUrl/lojista/pedidos/$pedidoId');
    final response = await http.get(uri, headers: _headers(token))
        .timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) {
        throw Exception('A API retornou os detalhes do pedido em formato inválido.');
      }
      return PedidoDetalheLojistaModel.fromJson(body);
    }
    if (response.statusCode == 401) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }
    if (response.statusCode == 403) {
      throw Exception('Você não tem permissão para visualizar este pedido.');
    }
    if (response.statusCode == 404) {
      throw Exception('Pedido não encontrado ou não pertence à sua loja.');
    }
    throw Exception('Erro ao carregar detalhes do pedido. Código: ${response.statusCode}.');
  }

  Future<void> atualizarStatus({
    required String token,
    required String pedidoId,
    required String status,
  }) async {
    final uri = Uri.parse('$baseUrl/pedidos/$pedidoId/status');
    final response = await http.patch(
      uri,
      headers: _headers(token),
      body: jsonEncode({'status': status}),
    ).timeout(const Duration(seconds: 25));

    if (response.statusCode == 204 || response.statusCode == 200) return;
    if (response.statusCode == 400) {
      throw Exception('Status inválido ou atualização não permitida.');
    }
    if (response.statusCode == 401) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }
    if (response.statusCode == 403) {
      throw Exception('Você não tem permissão para atualizar este pedido.');
    }
    if (response.statusCode == 404) throw Exception('Pedido não encontrado.');
    throw Exception('Erro ao atualizar status. Código: ${response.statusCode}.');
  }

  Future<List<PedidoResumoLojistaModel>> buscarPedidos({
    required String token,
    String? status,
  }) async {
    final queryParameters = <String, String>{'page': '0', 'size': '20'};
    if (status != null && status.isNotEmpty) queryParameters['status'] = status;

    final uri = Uri.parse('$baseUrl/lojista/pedidos')
        .replace(queryParameters: queryParameters);
    final response = await http.get(uri, headers: _headers(token))
        .timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) {
        throw Exception('A API retornou a lista de pedidos em formato inválido.');
      }
      final content = body['content'] as List<dynamic>? ?? [];
      return content
          .whereType<Map<String, dynamic>>()
          .map(PedidoResumoLojistaModel.fromJson)
          .toList(growable: false);
    }
    if (response.statusCode == 401) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }
    if (response.statusCode == 403) {
      throw Exception('Você não possui permissão para visualizar os pedidos.');
    }
    if (response.statusCode == 400) throw Exception('Filtro de status inválido.');
    throw Exception('Erro ao carregar pedidos. Status: ${response.statusCode}');
  }
}
