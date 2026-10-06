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

  factory PedidoResumoLojistaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PedidoResumoLojistaModel(
      id: json['id']?.toString() ?? '',
      clienteNome: json['clienteNome']?.toString() ?? 'Cliente',
      quantidadeItens:
          (json['quantidadeItens'] as num?)?.toInt() ?? 0,
      valorTotal:
          double.tryParse(json['valorTotal']?.toString() ?? '') ?? 0.0,
      status: json['status']?.toString() ?? '',
      criadoEm: DateTime.parse(
        json['criadoEm'].toString(),
      ),
    );
  }
}