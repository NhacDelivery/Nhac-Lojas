class CadastroLoja {
  String? nome;
  String? descricao;
  String? categoria;
  String? imagemUrl;

  bool isAberto;

  String? cep;
  String? rua;
  String? numero;
  String? complemento;
  String? bairro;
  String? cidade;
  String? estado;

  bool entregaPropria;
  bool retiradaNoLocal;

  double? taxaEntregaBase;
  int? tempoEntregaMin;
  int? tempoEntregaMax;
  double? raioEntregaKm;

  String? domingo;
  String? segunda;
  String? terca;
  String? quarta;
  String? quinta;
  String? sexta;
  String? sabado;

  bool aceitaDinheiro;
  bool aceitaCredito;
  bool aceitaDebito;
  bool aceitaPix;
  bool aceitaValeRefeicao;
  bool aceitaValeAlimentacao;

  CadastroLoja({
    this.nome,
    this.descricao,
    this.categoria,
    this.imagemUrl,
    this.isAberto = true,
    this.cep,
    this.rua,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.estado,
    this.entregaPropria = true,
    this.retiradaNoLocal = false,
    this.taxaEntregaBase,
    this.tempoEntregaMin,
    this.tempoEntregaMax,
    this.raioEntregaKm,
    this.domingo,
    this.segunda,
    this.terca,
    this.quarta,
    this.quinta,
    this.sexta,
    this.sabado,
    this.aceitaDinheiro = true,
    this.aceitaCredito = true,
    this.aceitaDebito = true,
    this.aceitaPix = true,
    this.aceitaValeRefeicao = false,
    this.aceitaValeAlimentacao = false,
  });

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