
class ProdutoLojistaModel {
  final String id;
  final String nome;
  final double preco;
  final String? categoria;
  final bool ativo;

  ProdutoLojistaModel({
    required this.id,
    required this.nome,
    required this.preco,
    this.categoria,
    required this.ativo,
  });

  factory ProdutoLojistaModel.fromJson(Map<String, dynamic> json) {
    return ProdutoLojistaModel(
      id: (json['id'] ?? json['produtoId'] ?? '').toString(),
      nome: (json['nome'] ?? json['nomeProduto'] ?? 'Produto').toString(),
      preco: _converterPreco(json['preco']),
      categoria: (json['categoriaMenu'] ?? json['categoria'] ?? '')
          .toString(),
      ativo: json['ativo'] == true || json['ativo'] == 1,
    );
  }

  static double _converterPreco(dynamic valor) {
    if (valor is num) {
      return valor.toDouble();
    }

    if (valor is String) {
      return double.tryParse(valor.replaceAll(',', '.')) ?? 0.0;
    }

    return 0.0;
  }
}
