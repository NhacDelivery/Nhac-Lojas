import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nhac_lojas/components/app_notification.dart';
import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/filter_tag.dart';
import 'package:nhac_lojas/components/nhac_input_field.dart';

// Ajuste os caminhos conforme a estrutura do seu projeto.
import 'package:nhac_lojas/models/loja_model.dart';
import 'package:nhac_lojas/services/loja_service.dart';

class EditarInfoLoja extends StatefulWidget {
  const EditarInfoLoja({super.key});

  @override
  State<EditarInfoLoja> createState() => _EditarInfoLojaState();
}

class _EditarInfoLojaState extends State<EditarInfoLoja> {
  final ImagePicker picker = ImagePicker();
  final LojaService lojaService = LojaService();

  File? fotoPerfil;
  LojaModel? loja;

  bool carregando = true;
  bool salvando = false;

  String? categoriaSelecionada;
  String? imagemUrl;

  final TextEditingController nomeLojaController =
      TextEditingController();

  final TextEditingController descricaoLojaController =
      TextEditingController();

  final List<String> categorias = [
    'Hamburgueria',
    'Pizzaria',
    'Japonesa',
    'Doces',
    'Marmitas',
    'Bebidas',
  ];

  @override
  void initState() {
    super.initState();
    _carregarDadosLoja();
  }

  @override
  void dispose() {
    nomeLojaController.dispose();
    descricaoLojaController.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosLoja() async {
    try {
      // TODO: recuperar o token JWT do mecanismo de autenticação
      // já utilizado no seu projeto.
      final token = await obterToken();

      final resultado = await lojaService.buscarMinhaLoja(token);

      if (!mounted) return;

      setState(() {
        loja = resultado;
        nomeLojaController.text = resultado.nome;
        descricaoLojaController.text = resultado.descricao ?? '';
        categoriaSelecionada = resultado.categoria;
        imagemUrl = resultado.imagemUrl;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
      });

      showAppNotification(
        context,
        type: NotificationType.error,
        message: 'Não foi possível carregar os dados da loja.',
      );
    }
  }

  Future<String> obterToken() async {
    // Substitua pelo método real que recupera o token JWT
    // do seu projeto.
    throw UnimplementedError(
      'Configure aqui a recuperação do token de autenticação.',
    );
  }

  Future<void> _selecionarFoto() async {
    final XFile? imagem = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (imagem == null) return;

    setState(() {
      fotoPerfil = File(imagem.path);
    });
  }

  Future<void> _salvar() async {
    final nome = nomeLojaController.text.trim();
    final descricao = descricaoLojaController.text.trim();

    if (nome.isEmpty) {
      showAppNotification(
        context,
        type: NotificationType.error,
        message: 'Informe o nome da loja.',
      );
      return;
    }

    if (categoriaSelecionada == null ||
        categoriaSelecionada!.isEmpty) {
      showAppNotification(
        context,
        type: NotificationType.error,
        message: 'Selecione uma categoria.',
      );
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      final token = await obterToken();

      // TODO: chamar aqui o método PUT/PATCH do LojaService.
      // Exemplo da intenção:
      //
      // await lojaService.atualizarMinhaLoja(
      //   token: token,
      //   nome: nome,
      //   descricao: descricao,
      //   categoria: categoriaSelecionada!,
      // );

      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      context.pop(true);

      showAppNotification(
        context,
        type: NotificationType.success,
        message: 'Informações alteradas!',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        salvando = false;
      });

      showAppNotification(
        context,
        type: NotificationType.error,
        message: 'Não foi possível salvar as informações.',
      );
    }
  }

  Widget _construirImagem() {
    if (fotoPerfil != null) {
      return Image.file(
        fotoPerfil!,
        fit: BoxFit.cover,
      );
    }

    if (imagemUrl != null && imagemUrl!.isNotEmpty) {
      return Image.network(
        imagemUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Image.asset(
            'assets/images/nhac-logo.png',
            fit: BoxFit.contain,
          );
        },
      );
    }

    return Image.asset(
      'assets/images/nhac-logo.png',
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const BackArrow(),
                    SizedBox(width: 12.w),
                    Text(
                      'Editar informações',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                Row(
                  children: [
                    CircleAvatar(
                      radius: 34.r,
                      backgroundColor:
                          const Color.fromARGB(255, 255, 242, 230),
                      child: ClipOval(
                        child: SizedBox(
                          width: 68.w,
                          height: 68.w,
                          child: _construirImagem(),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: _selecionarFoto,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Foto ou logo da loja',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Alterar foto',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                Text(
                  'Nome da loja',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                NhacInputField(
                  controller: nomeLojaController,
                ),

                SizedBox(height: 16.h),

                Text(
                  'Categoria',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),

                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    ListaFilterTags(
                      filtros: categorias,
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                Text(
                  'Descrição',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                NhacInputField(
                  controller: descricaoLojaController,
                  maxLines: 3,
                ),

                SizedBox(height: 32.h),

                Row(
                  children: [
                    Expanded(
                      child: ButtonNhac(
                        texto: 'Cancelar',
                        onTap: () => context.pop(),
                        isSecundario: true,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: ButtonNhac(
                        texto: salvando ? 'Salvando...' : 'Salvar',
                        onTap: salvando ? null : _salvar,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}