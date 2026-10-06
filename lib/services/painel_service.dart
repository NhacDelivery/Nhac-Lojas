import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/painel_model.dart';

class PainelService {
  static const String baseUrl =
      'https://backend-nhac.onrender.com/api/v1';

  Future<PainelResumoModel> buscarResumo(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/lojista/painel'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      return PainelResumoModel.fromJson(json);
    }

    if (response.statusCode == 401) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    if (response.statusCode == 403) {
      throw Exception(
        'Você não possui permissão para acessar o painel do lojista.',
      );
    }

    throw Exception(
      'Erro ao carregar painel. '
      'Status: ${response.statusCode}',
    );
  }
}