import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/container_nhac.dart';
import 'package:nhac_lojas/models/produto_lojista_model.dart';

class EditarProdutosPage extends StatefulWidget {
  final ProdutoLojistaModel produto;

  const EditarProdutosPage({
    super.key,
    required this.produto,
  });

  @override
  State<EditarProdutosPage> createState() =>
      _EditarProdutosPageState();
}

class _EditarProdutosPageState extends State<EditarProdutosPage> {
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController nomeController;
  late final TextEditingController descricaoController;
  late final TextEditingController precoController;
  late final TextEditingController descontoController;

  late String categoriaSelecionada;
  late bool produtoDisponivel;

  File? novaFoto;
  bool salvando = false;

  static const List<String> categorias = [
    'Lanches',
    'Bebidas',
    'Sobremesas',
    'Acompanhantes',
  ];

  @override
  void initState() {
    super.initState();

    nomeController = TextEditingController(
      text: widget.produto.nome,
    );

    // O modelo atual não possui descrição.
    descricaoController = TextEditingController();

    precoController = TextEditingController(
      text: widget.produto.preco
          .toStringAsFixed(2)
          .replaceAll('.', ','),
    );

    // O modelo atual não possui desconto.
    descontoController = TextEditingController();

    final categoria = widget.produto.categoria;

    categoriaSelecionada =
        categoria != null && categorias.contains(categoria)
            ? categoria
            : categorias.first;

    produtoDisponivel = widget.produto.ativo;
  }

  @override
  void dispose() {
    nomeController.dispose();
    descricaoController.dispose();
    precoController.dispose();
    descontoController.dispose();

    super.dispose();
  }

  // ============================================================
  // SELEÇÃO DE FOTO
  // ============================================================

  Future<void> selecionarFoto() async {
    try {
      final imagem = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (imagem == null || !mounted) return;

      final arquivo = File(imagem.path);
      final tamanho = await arquivo.length();

      if (tamanho > 5 * 1024 * 1024) {
        mostrarMensagem(
          'A imagem deve ter no máximo 5 MB.',
        );
        return;
      }

      setState(() {
        novaFoto = arquivo;
      });
    } catch (e) {
      if (mounted) {
        mostrarMensagem(
          'Não foi possível selecionar a foto.',
        );
      }
    }
  }

  ImageProvider? obterImagem() {
    if (novaFoto != null) {
      return FileImage(novaFoto!);
    }

    // O modelo atual não possui URL da foto.
    return null;
  }

  // ============================================================
  // MENSAGENS
  // ============================================================

  void mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
        ),
      );
  }

  // ============================================================
  // SALVAR ALTERAÇÕES
  // ============================================================

  Future<void> salvarAlteracoes() async {
    if (salvando) return;

    final nome = nomeController.text.trim();
    final descricao = descricaoController.text.trim();

    final precoTexto = precoController.text
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    final preco = double.tryParse(precoTexto);

    final descontoTexto = descontoController.text
        .replaceAll('%', '')
        .trim();

    final desconto = descontoTexto.isEmpty
        ? null
        : double.tryParse(descontoTexto);

    // Validação do nome.
    if (nome.isEmpty) {
      mostrarMensagem(
        'Informe o nome do produto.',
      );
      return;
    }

    // Validação do preço.
    if (preco == null || !preco.isFinite || preco < 0) {
      mostrarMensagem(
        'Informe um preço válido.',
      );
      return;
    }

    // Validação do desconto.
    if (descontoTexto.isNotEmpty &&
        (desconto == null ||
            !desconto.isFinite ||
            desconto < 0 ||
            desconto > 100)) {
      mostrarMensagem(
        'Informe um desconto entre 0% e 100%.',
      );
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      /*
       * A integração com o backend será feita aqui.
       *
       * ID do produto:
       * widget.produto.id
       *
       * Dados editados:
       * nome
       * descricao
       * preco
       * desconto
       * categoriaSelecionada
       * produtoDisponivel
       * novaFoto
       *
       * ATENÇÃO:
       * Este código ainda não envia os dados para a API.
       * O modelo atual também não possui descrição, desconto
       * nem URL da foto.
       */

      if (!mounted) return;

      mostrarMensagem(
        'Os dados foram validados, mas ainda não foram salvos no servidor.',
      );
    } catch (e) {
      if (mounted) {
        mostrarMensagem(
          'Não foi possível atualizar o produto.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  // ============================================================
  // EXCLUSÃO
  // ============================================================

  Future<void> excluirProduto() async {
    Navigator.pop(context);

    /*
     * TODO:
     * Implementar a chamada ao serviço da API.
     *
     * O identificador do produto é:
     * widget.produto.id
     *
     * Após a exclusão bem-sucedida, retornar ao cardápio
     * e atualizar a lista de produtos.
     */

    mostrarMensagem(
      'A exclusão ainda precisa ser conectada à API.',
    );
  }

  void confirmarExclusao() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 42.sp,
                ),

                SizedBox(height: 16.h),

                Text(
                  'Excluir produto?',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8.h),

                const Text(
                  'Essa ação não pode ser desfeita.',
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 24.h),

                ButtonNhac(
                  texto: 'Excluir produto',
                  onTap: () {
                    Navigator.pop(modalContext);

                    // Ainda não conectado à API.
                    mostrarMensagem(
                      'A exclusão ainda precisa ser conectada à API.',
                    );
                  },
                ),

                SizedBox(height: 12.h),

                ButtonNhac(
                  texto: 'Cancelar',
                  isSecundario: true,
                  onTap: () {
                    Navigator.pop(modalContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // FOTO
  // ============================================================

  Widget construirFoto() {
    final imagem = obterImagem();

    return GestureDetector(
      onTap: selecionarFoto,
      child: Container(
        width: double.infinity,
        height: 156.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.redAccent,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imagem != null)
                Image(
                  image: imagem,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return construirPlaceholderFoto();
                  },
                )
              else
                construirPlaceholderFoto(),

              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.redAccent,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.redAccent,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget construirPlaceholderFoto() {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            color: Colors.redAccent,
            size: 26.sp,
          ),

          SizedBox(height: 4.h),

          Text(
            novaFoto == null
                ? 'Adicionar foto do produto'
                : 'Foto selecionada',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
              fontSize: 14.sp,
            ),
          ),

          SizedBox(height: 4.h),

          Text(
            'PNG ou JPG, até 5 MB',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORIAS
  // ============================================================

  Widget construirCategorias() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: categorias.map((categoria) {
        final selecionada =
            categoriaSelecionada == categoria;

        return ChoiceChip(
          label: Text(categoria),
          selected: selecionada,
          onSelected: (selecionada) {
            if (!selecionada) return;

            setState(() {
              categoriaSelecionada = categoria;
            });
          },
        );
      }).toList(),
    );
  }

  // ============================================================
  // CAMPO DE TEXTO
  // ============================================================

  Widget construirCampo({
    required String titulo,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 4.h),

        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TELA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20.w,
              16.h,
              20.w,
              20.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho.
                Row(
                  children: [
                    const BackArrow(),

                    SizedBox(width: 16.w),

                    Expanded(
                      child: Text(
                        'Editar produto',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Foto.
                construirFoto(),

                SizedBox(height: 16.h),

                // Nome.
                construirCampo(
                  titulo: 'Nome do produto',
                  controller: nomeController,
                  hint: 'Ex: X-Burguer',
                ),

                SizedBox(height: 16.h),

                // Descrição.
                construirCampo(
                  titulo: 'Descrição',
                  controller: descricaoController,
                  hint: 'Descreva os ingredientes e detalhes',
                  maxLines: 3,
                ),

                SizedBox(height: 16.h),

                // Categoria.
                Text(
                  'Categoria',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8.h),

                construirCategorias(),

                SizedBox(height: 16.h),

                // Preço e desconto.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: construirCampo(
                        titulo: 'Preço',
                        controller: precoController,
                        hint: 'R\$ 0,00',
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),

                    SizedBox(width: 8.w),

                    Expanded(
                      child: construirCampo(
                        titulo: 'Desconto (opcional)',
                        controller: descontoController,
                        hint: '0%',
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Disponibilidade.
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: ContainerNhac(
                    informacao: 'Disponível',
                    complemento: 'Produto aparece no cardápio',
                    exibirSwitch: true,
                    ativoInicial: produtoDisponivel,
                    onSwitchChanged: (valor) {
                      setState(() {
                        produtoDisponivel = valor;
                      });
                    },
                  ),
                ),

                SizedBox(height: 24.h),

                // Botões.
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: salvando
                            ? null
                            : confirmarExclusao,
                        child: Container(
                          height: 49.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.redAccent.withValues(
                                alpha: 0.4,
                              ),
                              width: 1.2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      flex: 4,
                      child: ButtonNhac(
                        texto: salvando
                            ? 'Salvando...'
                            : 'Salvar alterações',
                        onTap: salvando
                            ? null
                            : salvarAlteracoes,
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