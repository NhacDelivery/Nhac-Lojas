class CadastroUsuario {
  static String? id;
  static String? nome;
  static String? email;
  static String? telefone;
  static String? senha;

  static bool get completo =>
      [id, nome, email, telefone, senha].every((v) => v != null && v.isNotEmpty);

  static void limpar() {
    id = nome = email = telefone = senha = null;
  }
}