class CadastroLoja {
  String? nome;
  String? descricao;
  String? categoria;
  String? imagemUrl;
  bool isAberto = false;

  String? rua;
  String? numero;
  String? cidade;
  String? estado;
  String? cep;
  String? bairro;
  String? complemento;

  double taxaEntregaBase = 0;
  int tempoEntregaMin = 30;
  int tempoEntregaMax = 45;
  bool entregaPropria = true;
  bool retiradaNoLocal = false;
  double? raioEntregaKm;

  String? domingo;
  String? segunda;
  String? terca;
  String? quarta;
  String? quinta;
  String? sexta;
  String? sabado;

  bool aceitaDinheiro = true;
  bool aceitaCredito = true;
  bool aceitaDebito = true;
  bool aceitaPix = true;
  bool aceitaValeRefeicao = false;
  bool aceitaValeAlimentacao = false;

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria,
      'imagemUrl': imagemUrl,
      'isAberto': isAberto,

      'dadosOperacionais': {
        'taxaEntregaBase': taxaEntregaBase,
        'tempoEntregaMin': tempoEntregaMin,
        'tempoEntregaMax': tempoEntregaMax,
        'entregaPropria': entregaPropria,
        'retiradaNoLocal': retiradaNoLocal,
        'raioEntregaKm': raioEntregaKm,
      },

      'endereco': {
        'rua': rua,
        'numero': numero,
        'cidade': cidade,
        'estado': estado,
        'cep': cep,
        'bairro': bairro,
        'complemento': complemento,
      },

      'horarios': {
        'domingo': domingo,
        'segunda': segunda,
        'terca': terca,
        'quarta': quarta,
        'quinta': quinta,
        'sexta': sexta,
        'sabado': sabado,
      },

      'formasPagamento': {
        'aceitaDinheiro': aceitaDinheiro,
        'aceitaCredito': aceitaCredito,
        'aceitaDebito': aceitaDebito,
        'aceitaPix': aceitaPix,
        'aceitaValeRefeicao': aceitaValeRefeicao,
        'aceitaValeAlimentacao': aceitaValeAlimentacao,
      },
    };
  }
}