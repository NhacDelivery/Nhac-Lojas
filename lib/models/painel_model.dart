class FaturamentoDiaModel {
  final DateTime data;
  final double valor;

  FaturamentoDiaModel({
    required this.data,
    required this.valor,
  });

  factory FaturamentoDiaModel.fromJson(Map<String, dynamic> json) {
    return FaturamentoDiaModel(
      data: DateTime.parse(json['data'].toString()),
      valor: double.tryParse(json['valor'].toString()) ?? 0.0,
    );
  }
}

class PedidoResumoLojistaModel {
  final String id;
  final String clienteNome;
  final int quantidadeItens;
  final double valorTotal;
  final String status;
  final DateTime criadoEm;

  PedidoResumoLojistaModel({
    required this.id,
    required this.clienteNome,
    required this.quantidadeItens,
    required this.valorTotal,
    required this.status,
    required this.criadoEm,
  });

  factory PedidoResumoLojistaModel.fromJson(Map<String, dynamic> json) {
    return PedidoResumoLojistaModel(
      id: json['id']?.toString() ?? '',
      clienteNome: json['clienteNome']?.toString() ?? 'Cliente',
      quantidadeItens:
          (json['quantidadeItens'] as num?)?.toInt() ?? 0,
      valorTotal:
          double.tryParse(json['valorTotal'].toString()) ?? 0.0,
      status: json['status']?.toString() ?? '',
      criadoEm: DateTime.parse(json['criadoEm'].toString()),
    );
  }
}

class PainelResumoModel {
  final bool lojaAberta;
  final double faturamentoHoje;
  final int pedidosEmPreparo;
  final int pedidosACaminho;
  final int pedidosConcluidosHoje;
  final List<FaturamentoDiaModel> faturamentoUltimos7Dias;
  final List<PedidoResumoLojistaModel> pedidosRecentes;

  PainelResumoModel({
    required this.lojaAberta,
    required this.faturamentoHoje,
    required this.pedidosEmPreparo,
    required this.pedidosACaminho,
    required this.pedidosConcluidosHoje,
    required this.faturamentoUltimos7Dias,
    required this.pedidosRecentes,
  });

  factory PainelResumoModel.fromJson(Map<String, dynamic> json) {
    return PainelResumoModel(
      lojaAberta: json['lojaAberta'] == true,
      faturamentoHoje:
          double.tryParse(json['faturamentoHoje'].toString()) ?? 0.0,
      pedidosEmPreparo:
          (json['pedidosEmPreparo'] as num?)?.toInt() ?? 0,
      pedidosACaminho:
          (json['pedidosACaminho'] as num?)?.toInt() ?? 0,
      pedidosConcluidosHoje:
          (json['pedidosConcluidosHoje'] as num?)?.toInt() ?? 0,
      faturamentoUltimos7Dias:
          (json['faturamentoUltimos7Dias'] as List<dynamic>? ?? [])
              .map(
                (item) => FaturamentoDiaModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
      pedidosRecentes:
          (json['pedidosRecentes'] as List<dynamic>? ?? [])
              .map(
                (item) => PedidoResumoLojistaModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }
}