class MensagemChatModel {
  final String id;
  final String conversaId;
  final String remetenteTipo;
  final String remetenteUsuarioId;
  final String conteudo;
  final DateTime? enviadaEm;

  MensagemChatModel({
    required this.id,
    required this.conversaId,
    required this.remetenteTipo,
    required this.remetenteUsuarioId,
    required this.conteudo,
    this.enviadaEm,
  });

  factory MensagemChatModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MensagemChatModel(
      id: json['id']?.toString() ?? '',
      conversaId: json['conversaId']?.toString() ?? '',
      remetenteTipo: json['remetenteTipo']?.toString() ?? '',
      remetenteUsuarioId:
          json['remetenteUsuarioId']?.toString() ?? '',
      conteudo: json['conteudo']?.toString() ?? '',
      enviadaEm: json['enviadaEm'] != null
          ? DateTime.tryParse(json['enviadaEm'].toString())
          : null,
    );
  }
}