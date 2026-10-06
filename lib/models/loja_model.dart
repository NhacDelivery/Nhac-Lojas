class LojaModel {
  final String id;
  final String nome;
  final String? descricao;
  final String? categoria;
  final String? imagemUrl;
  final bool isAberto;

  final DadosOperacionaisModel? dadosOperacionais;
  final EnderecoLojaModel? endereco;
  final HorariosLojaModel? horarios;
  final FormasPagamentoModel? formasPagamento;

  final double? latitude;
  final double? longitude;

  LojaModel({
    required this.id,
    required this.nome,
    this.descricao,
    this.categoria,
    this.imagemUrl,
    required this.isAberto,
    this.dadosOperacionais,
    this.endereco,
    this.horarios,
    this.formasPagamento,
    this.latitude,
    this.longitude,
  });

  factory LojaModel.fromJson(Map<String, dynamic> json) {
    return LojaModel(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      descricao: json['descricao']?.toString(),
      categoria: json['categoria']?.toString(),
      imagemUrl: json['imagemUrl']?.toString(),
      isAberto: json['isAberto'] == true,
      dadosOperacionais: json['dadosOperacionais'] != null
          ? DadosOperacionaisModel.fromJson(
              Map<String, dynamic>.from(json['dadosOperacionais']),
            )
          : null,
      endereco: json['endereco'] != null
          ? EnderecoLojaModel.fromJson(
              Map<String, dynamic>.from(json['endereco']),
            )
          : null,
      horarios: json['horarios'] != null
          ? HorariosLojaModel.fromJson(
              Map<String, dynamic>.from(json['horarios']),
            )
          : null,
      formasPagamento: json['formasPagamento'] != null
          ? FormasPagamentoModel.fromJson(
              Map<String, dynamic>.from(json['formasPagamento']),
            )
          : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

class DadosOperacionaisModel {
  final double avaliacaoMedia;
  final double? taxaEntregaBase;
  final int tempoEntregaMin;
  final int tempoEntregaMax;
  final int totalAvaliacoes;
  final bool? entregaPropria;
  final bool? retiradaNoLocal;
  final double? raioEntregaKm;

  DadosOperacionaisModel({
    required this.avaliacaoMedia,
    this.taxaEntregaBase,
    required this.tempoEntregaMin,
    required this.tempoEntregaMax,
    required this.totalAvaliacoes,
    this.entregaPropria,
    this.retiradaNoLocal,
    this.raioEntregaKm,
  });

  factory DadosOperacionaisModel.fromJson(Map<String, dynamic> json) {
    return DadosOperacionaisModel(
      avaliacaoMedia:
          (json['avaliacaoMedia'] as num?)?.toDouble() ?? 0.0,
      taxaEntregaBase:
          (json['taxaEntregaBase'] as num?)?.toDouble(),
      tempoEntregaMin:
          (json['tempoEntregaMin'] as num?)?.toInt() ?? 0,
      tempoEntregaMax:
          (json['tempoEntregaMax'] as num?)?.toInt() ?? 0,
      totalAvaliacoes:
          (json['totalAvaliacoes'] as num?)?.toInt() ?? 0,
      entregaPropria: json['entregaPropria'] as bool?,
      retiradaNoLocal: json['retiradaNoLocal'] as bool?,
      raioEntregaKm:
          (json['raioEntregaKm'] as num?)?.toDouble(),
    );
  }
}

class EnderecoLojaModel {
  final String? rua;
  final String? numero;
  final String? cidade;
  final String? estado;
  final String? cep;
  final String? bairro;
  final String? complemento;

  EnderecoLojaModel({
    this.rua,
    this.numero,
    this.cidade,
    this.estado,
    this.cep,
    this.bairro,
    this.complemento,
  });

  factory EnderecoLojaModel.fromJson(Map<String, dynamic> json) {
    return EnderecoLojaModel(
      rua: json['rua']?.toString(),
      numero: json['numero']?.toString(),
      cidade: json['cidade']?.toString(),
      estado: json['estado']?.toString(),
      cep: json['cep']?.toString(),
      bairro: json['bairro']?.toString(),
      complemento: json['complemento']?.toString(),
    );
  }
}

class HorariosLojaModel {
  final String? domingo;
  final String? segunda;
  final String? terca;
  final String? quarta;
  final String? quinta;
  final String? sexta;
  final String? sabado;

  HorariosLojaModel({
    this.domingo,
    this.segunda,
    this.terca,
    this.quarta,
    this.quinta,
    this.sexta,
    this.sabado,
  });

  factory HorariosLojaModel.fromJson(Map<String, dynamic> json) {
    return HorariosLojaModel(
      domingo: json['domingo']?.toString(),
      segunda: json['segunda']?.toString(),
      terca: json['terca']?.toString(),
      quarta: json['quarta']?.toString(),
      quinta: json['quinta']?.toString(),
      sexta: json['sexta']?.toString(),
      sabado: json['sabado']?.toString(),
    );
  }
}

class FormasPagamentoModel {
  final bool? aceitaDinheiro;
  final bool? aceitaCredito;
  final bool? aceitaDebito;
  final bool? aceitaPix;
  final bool? aceitaValeRefeicao;
  final bool? aceitaValeAlimentacao;

  FormasPagamentoModel({
    this.aceitaDinheiro,
    this.aceitaCredito,
    this.aceitaDebito,
    this.aceitaPix,
    this.aceitaValeRefeicao,
    this.aceitaValeAlimentacao,
  });

  factory FormasPagamentoModel.fromJson(Map<String, dynamic> json) {
    return FormasPagamentoModel(
      aceitaDinheiro: json['aceitaDinheiro'] as bool?,
      aceitaCredito: json['aceitaCredito'] as bool?,
      aceitaDebito: json['aceitaDebito'] as bool?,
      aceitaPix: json['aceitaPix'] as bool?,
      aceitaValeRefeicao: json['aceitaValeRefeicao'] as bool?,
      aceitaValeAlimentacao: json['aceitaValeAlimentacao'] as bool?,
    );
  }
}