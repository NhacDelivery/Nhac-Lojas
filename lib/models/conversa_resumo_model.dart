class ConversaResumoModel {
  final String id;
  final String clienteId;
  final String clienteNome;
  final String participanteTipo;
  final String? ultimaMensagemPreview;
  final DateTime? ultimaMensagemEm;
  final int naoLidas;

  ConversaResumoModel({
    required this.id,
    required this.clienteId,
    required this.clienteNome,
    required this.participanteTipo,
    this.ultimaMensagemPreview,
    this.ultimaMensagemEm,
    required this.naoLidas,
  });

  factory ConversaResumoModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConversaResumoModel(
      id: json['id']?.toString() ?? '',
      clienteId: json['clienteId']?.toString() ?? '',
      clienteNome: json['clienteNome']?.toString() ?? 'Contato',
      participanteTipo:
          json['participanteTipo']?.toString() ?? 'CLIENTE',
      ultimaMensagemPreview:
          json['ultimaMensagemPreview']?.toString(),
      ultimaMensagemEm: json['ultimaMensagemEm'] != null
          ? DateTime.tryParse(
              json['ultimaMensagemEm'].toString(),
            )
          : null,
      naoLidas: (json['naoLidas'] as num?)?.toInt() ?? 0,
    );
  }
}