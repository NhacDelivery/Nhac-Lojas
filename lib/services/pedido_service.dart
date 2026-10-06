import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pedido_resumo_model.dart';
class PedidoService {
  static const String baseUrl =
      'https://backend-nhac.onrender.com/api/v1';

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