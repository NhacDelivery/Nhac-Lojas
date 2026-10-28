import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/conversa_resumo_model.dart';
import '../models/mensagem_chat_model.dart';

class ChatService {
  static const String baseUrl =
      'https://backend-nhac.cloud.run/api/v1';

  Map<String, String> _headers(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<List<ConversaResumoModel>> listarConversas({
    required String token,
    String? tipo,
  }) async {
    final query = <String, String>{
      'page': '0',
      'size': '20',
    };

    if (tipo != null && tipo.isNotEmpty) {
      query['tipo'] = tipo;
    }

    final uri = Uri.parse(
      '$baseUrl/lojista/conversas',
    ).replace(queryParameters: query);

    final response = await http.get(
      uri,
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> content =
          json['content'] as List<dynamic>? ?? [];

      return content
          .map(
            (item) => ConversaResumoModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    if (response.statusCode == 403) {
      throw Exception('Você não tem permissão para ver as conversas.');
    }

    throw Exception(
      'Erro ao carregar conversas (${response.statusCode}).',
    );
  }

  Future<List<MensagemChatModel>> listarMensagens({
    required String token,
    required String conversaId,
    int page = 0,
    int size = 30,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/lojista/conversas/$conversaId/mensagens',
    ).replace(
      queryParameters: {
        'page': '$page',
        'size': '$size',
      },
    );

    final response = await http.get(
      uri,
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> content =
          json['content'] as List<dynamic>? ?? [];

      return content
          .map(
            (item) => MensagemChatModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    throw Exception(
      'Erro ao carregar mensagens (${response.statusCode}).',
    );
  }

  Future<void> marcarComoLida({
    required String token,
    required String conversaId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/lojista/conversas/$conversaId/lida',
    );

    final response = await http.patch(
      uri,
      headers: _headers(token),
    );

    if (response.statusCode == 204 ||
        response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 401) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    throw Exception(
      'Erro ao marcar conversa como lida (${response.statusCode}).',
    );
  }
}