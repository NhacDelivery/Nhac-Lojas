import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nhac_lojas/models/cadastro_loja.dart';

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

    final payload = {
      'nome': cadastro.nome,
      'descricao': cadastro.descricao,
      'categoria': cadastro.categoria,
      'imagemUrl': cadastro.imagemUrl ?? '',

      'isAberto': cadastro.isAberto,

      'dadosOperacionais': {
        'taxaEntregaBase': cadastro.taxaEntregaBase,
        'tempoEntregaMin': cadastro.tempoEntregaMin,
        'tempoEntregaMax': cadastro.tempoEntregaMax,
        'entregaPropria': cadastro.entregaPropria,
        'retiradaNoLocal': cadastro.retiradaNoLocal,
        'raioEntregaKm': cadastro.raioEntregaKm,
      },

      'endereco': {
        'rua': cadastro.rua,
        'numero': cadastro.numero,
        'cidade': cadastro.cidade,
        'estado': cadastro.estado,
        'cep': cadastro.cep,
        'bairro': cadastro.bairro,
        'complemento': cadastro.complemento,
      },

      'horarios': {
        'domingo': cadastro.domingo,
        'segunda': cadastro.segunda,
        'terca': cadastro.terca,
        'quarta': cadastro.quarta,
        'quinta': cadastro.quinta,
        'sexta': cadastro.sexta,
        'sabado': cadastro.sabado,
      },

      'formasPagamento': {
        'aceitaDinheiro': cadastro.aceitaDinheiro,
        'aceitaCredito': cadastro.aceitaCredito,
        'aceitaDebito': cadastro.aceitaDebito,
        'aceitaPix': cadastro.aceitaPix,
        'aceitaValeRefeicao': cadastro.aceitaValeRefeicao,
        'aceitaValeAlimentacao': cadastro.aceitaValeAlimentacao,
      },
    };

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

  // ============================================================
  // ERROS
  // ============================================================

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

