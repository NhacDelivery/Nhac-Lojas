class ProdutoLojistaModel {
  final String id;
  final String nome;
  final double preco;
  final String? categoria;
  final bool ativo;
  final String? descricao;
  final double? desconto;
  final String? fotoUrl;

  ProdutoLojistaModel({
    required this.id,
    required this.nome,
    required this.preco,
    this.categoria,
    required this.ativo,
    this.descricao,
    this.desconto,
    this.fotoUrl,
  });

  factory ProdutoLojistaModel.fromJson(Map<String, dynamic> json) {
    return ProdutoLojistaModel(
      id: (json['id'] ?? json['produtoId'] ?? '').toString(),
      nome: (json['nome'] ?? json['nomeProduto'] ?? 'Produto').toString(),
      preco: _converterPreco(json['preco']),
      categoria: (json['categoriaMenu'] ?? json['categoria'])?.toString(),
      ativo: json['ativo'] == true || json['ativo'] == 1,
      descricao: (json['descricao'] ?? json['descricaoProduto'])?.toString(),
      desconto: _converterPrecoOpcional(
        json['desconto'] ?? json['percentualDesconto'],
      ),
      fotoUrl: (
        json['fotoUrl'] ??
        json['urlImagem'] ??
        json['imagemUrl'] ??
        json['imagem']
      )?.toString(),
    );
  }

  static double _converterPreco(dynamic valor) {
    return _converterPrecoOpcional(valor) ?? 0.0;
  }

  static double? _converterPrecoOpcional(dynamic valor) {
    if (valor == null) return null;

    if (valor is num) {
      return valor.toDouble();
    }

    if (valor is String) {
      var texto = valor.trim().replaceAll('R\$', '').replaceAll(' ', '');

      // Aceita formatos como 29,90 e 1.299,90.
      if (texto.contains(',')) {
        texto = texto.replaceAll('.', '').replaceAll(',', '.');
      }

      return double.tryParse(texto);
    }

    return null;
  }
}
