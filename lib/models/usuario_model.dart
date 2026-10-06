class UsuarioModel {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final String? imagemUrl;
  final String papel;
  final String? cargo;

  UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    this.imagemUrl,
    required this.papel,
    this.cargo,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telefone: json['telefone']?.toString() ?? '',
      imagemUrl: json['imagemUrl']?.toString(),
      papel: json['papel']?.toString() ?? '',
      cargo: json['cargo']?.toString(),
    );
  }
}