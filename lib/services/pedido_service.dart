import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pedido_resumo_model.dart';
class PedidoService {
  static const String baseUrl =
      'https://backend-nhac.cloud.run/api/v1';



  Future<void> atualizarStatus({
    required String token,
    required String pedidoId,
    required String status,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/pedidos/$pedidoId/status',
    );

    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'status': status,
      }),
    );

    if (response.statusCode == 204 ||
        response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 400) {
      throw Exception(
        'Status inválido ou atualização não permitida.',
      );
    }

    if (response.statusCode == 401) {
      throw Exception(
        'Sessão expirada. Faça login novamente.',
      );
    }

    if (response.statusCode == 403) {
      throw Exception(
        'Você não tem permissão para atualizar este pedido.',
      );
    }

    if (response.statusCode == 404) {
      throw Exception(
        'Pedido não encontrado.',
      );
    }

    throw Exception(
      'Erro ao atualizar status. '
      'Código: ${response.statusCode}. '
      '${response.body}',
    );
  }


  Future<List<PedidoResumoLojistaModel>> buscarPedidos({
    required String token,
    String? status,
  }) async {
    final queryParameters = <String, String>{
      'page': '0',
      'size': '20',
    };

    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }

    final uri = Uri.parse(
      '$baseUrl/lojista/pedidos',
    ).replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json =
          jsonDecode(response.body);

      final List<dynamic> content =
          json['content'] as List<dynamic>? ?? [];

      return content
          .map(
            (item) => PedidoResumoLojistaModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    if (response.statusCode == 401) {
      throw Exception(
        'Sessão expirada. Faça login novamente.',
      );
    }

    if (response.statusCode == 403) {
      throw Exception(
        'Você não possui permissão para visualizar os pedidos.',
      );
    }

    if (response.statusCode == 400) {
      throw Exception(
        'Filtro de status inválido.',
      );
    }

    throw Exception(
      'Erro ao carregar pedidos. '
      'Status: ${response.statusCode}',
    );
  }
}