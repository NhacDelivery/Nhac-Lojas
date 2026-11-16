class EnderecoEntregaLojistaModel {
  final String rua;
  final String numero;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;
  final String? complemento;

  const EnderecoEntregaLojistaModel({
    required this.rua,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.cep,
    this.complemento,
  });

  factory EnderecoEntregaLojistaModel.fromJson(Map<String, dynamic> json) =>
      EnderecoEntregaLojistaModel(
        rua: json['rua']?.toString() ?? '',
        numero: json['numero']?.toString() ?? '',
        bairro: json['bairro']?.toString() ?? '',
        cidade: json['cidade']?.toString() ?? '',
        estado: json['estado']?.toString() ?? '',
        cep: json['cep']?.toString() ?? '',
        complemento: json['complemento']?.toString(),
      );
}

class ItemPedidoLojistaModel {
  final String id;
  final String nome;
  final String? imagemUrl;
  final double preco;
  final int quantidade;
  final List<String> adicionais;

  const ItemPedidoLojistaModel({
    required this.id,
    required this.nome,
    this.imagemUrl,
    required this.preco,
    required this.quantidade,
    required this.adicionais,
  });

  factory ItemPedidoLojistaModel.fromJson(Map<String, dynamic> json) =>
      ItemPedidoLojistaModel(
        id: json['id']?.toString() ?? '',
        nome: json['nome']?.toString() ?? 'Produto',
        imagemUrl: json['imagemUrl']?.toString(),
        preco: _numero(json['preco']),
        quantidade: (json['quantidade'] as num?)?.toInt() ?? 0,
        adicionais: (json['adicionais'] as List<dynamic>? ?? [])
            .map((item) => item.toString())
            .toList(growable: false),
      );
}

class PedidoDetalheLojistaModel {
  final String id;
  final String clienteNome;
  final String? clienteTelefone;
  final double valorTotal;
  final double taxaFrete;
  final String formaPagamento;
  final double? trocoPara;
  final String? observacao;
  final String status;
  final DateTime criadoEm;
  final EnderecoEntregaLojistaModel? enderecoEntrega;
  final List<ItemPedidoLojistaModel> itens;

  const PedidoDetalheLojistaModel({
    required this.id,
    required this.clienteNome,
    this.clienteTelefone,
    required this.valorTotal,
    required this.taxaFrete,
    required this.formaPagamento,
    this.trocoPara,
    this.observacao,
    required this.status,
    required this.criadoEm,
    this.enderecoEntrega,
    required this.itens,
  });

  factory PedidoDetalheLojistaModel.fromJson(Map<String, dynamic> json) {
    final endereco = json['enderecoEntrega'];
    return PedidoDetalheLojistaModel(
      id: json['id']?.toString() ?? '',
      clienteNome: json['clienteNome']?.toString() ?? 'Cliente',
      clienteTelefone: json['clienteTelefone']?.toString(),
      valorTotal: _numero(json['valorTotal']),
      taxaFrete: _numero(json['taxaFrete']),
      formaPagamento: json['formaPagamento']?.toString() ?? 'Não informado',
      trocoPara: json['trocoPara'] == null ? null : _numero(json['trocoPara']),
      observacao: json['observacao']?.toString(),
      status: json['status']?.toString() ?? '',
      criadoEm: DateTime.tryParse(json['criadoEm']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      enderecoEntrega: endereco is Map<String, dynamic>
          ? EnderecoEntregaLojistaModel.fromJson(endereco)
          : null,
      itens: (json['itens'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ItemPedidoLojistaModel.fromJson)
          .toList(growable: false),
    );
  }
}

double _numero(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
