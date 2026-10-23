

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/container_nhac.dart';
import 'package:nhac_lojas/components/filter_tag.dart';
import 'package:nhac_lojas/components/search_container.dart';

import 'package:nhac_lojas/models/produto_lojista_model.dart';
import 'package:nhac_lojas/services/auth_service.dart';
import 'package:nhac_lojas/services/lojista_service.dart';

class CardapioCheioPage extends StatefulWidget {
  const CardapioCheioPage({super.key});

  @override
  State<CardapioCheioPage> createState() => _CardapioCheioPageState();
}

class _CardapioCheioPageState extends State<CardapioCheioPage> {
  final LojistaService _lojistaService = LojistaService();
  final TextEditingController _buscaController = TextEditingController();

  List<ProdutoLojistaModel> _produtos = [];

  bool _carregando = true;
  String? _erro;

  String _categoriaSelecionada = 'Todos';
  String _termoBusca = '';

  final List<String> _categorias = [
    'Todos',
    'Combos',
    'Prato Principal',
    'Acompanhamentos',
    'Sobremesas',
    'Bebidas',
  ];

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    _lojistaService.dispose();
    super.dispose();
  }

  Future<void> _carregarProdutos() async {
    if (!mounted) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final token = await AuthService.obterToken();

      if (token == null || token.isEmpty) {
        throw Exception('Sessão expirada. Faça login novamente.');
      }

      final resposta = await _lojistaService.listarProdutos(
        token: token,
        pagina: 0,
        tamanho: 100,
      );

      final dynamic conteudo = resposta['content'];

      if (conteudo is! List) {
        throw Exception(
          'A resposta da API não contém uma lista válida de produtos.',
        );
      }

      final produtos = conteudo
          .whereType<Map<String, dynamic>>()
          .map(ProdutoLojistaModel.fromJson)
          .toList();

      if (!mounted) return;

      setState(() {
        _produtos = produtos;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
        _carregando = false;
      });
    }
  }

  List<ProdutoLojistaModel> get _produtosFiltrados {
    return _produtos.where((produto) {
      final correspondeNome = produto.nome
          .toLowerCase()
          .contains(_termoBusca.toLowerCase());

      final correspondeCategoria =
          _categoriaSelecionada == 'Todos' ||
          (produto.categoria ?? '').toLowerCase() ==
              _categoriaSelecionada.toLowerCase();

      return correspondeNome && correspondeCategoria;
    }).toList();
  }

  String _formatarPreco(double preco) {
    return 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.go('/mais');
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
            child: Column(
              children: [
                Row(
                  children: [
                    const BackArrow(targetRoute: '/mais'),
                    SizedBox(width: 16.w),
                    Text(
                      'Cardápio',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                TextField(
                  controller: _buscaController,
                  onChanged: (valor) {
                    setState(() {
                      _termoBusca = valor.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar produto...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _termoBusca.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _buscaController.clear();
                              setState(() {
                                _termoBusca = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                SizedBox(
                  height: 36.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categorias.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      final categoria = _categorias[index];
                      final selecionada =
                          _categoriaSelecionada == categoria;

                      return ChoiceChip(
                        label: Text(categoria),
                        selected: selecionada,
                        onSelected: (_) {
                          setState(() {
                            _categoriaSelecionada = categoria;
                          });
                        },
                      );
                    },
                  ),
                ),

                SizedBox(height: 20.h),

                Expanded(
                  child: _construirConteudo(),
                ),

                SizedBox(height: 12.h),

                ButtonNhac(
                  texto: '+ Adicionar produto',
                  onTap: () async {
                    await context.push('/cadastrar-produtos');

                    if (mounted) {
                      _carregarProdutos();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirConteudo() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              SizedBox(height: 12.h),
              Text(
                _erro!,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: _carregarProdutos,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final produtos = _produtosFiltrados;

    if (_produtos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 60.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 12.h),
            const Text('Seu cardápio está vazio.'),
            SizedBox(height: 8.h),
            const Text(
              'Adicione seu primeiro produto para começar.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (produtos.isEmpty) {
      return const Center(
        child: Text('Nenhum produto encontrado para esse filtro.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarProdutos,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: produtos.length,
        itemBuilder: (context, index) {
          final produto = produtos[index];

          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: ContainerNhac(
              icon: Icons.food_bank,
              informacao: produto.nome,
              preco: produto.preco,
              complemento: produto.ativo ? null : 'Indisponível',
              exibirSwitch: true,
              ativoInicial: produto.ativo,
              onSwitchChanged: (valor) {
                // A alteração é apenas visual por enquanto.
                // Precisamos de um endpoint no backend para persistir
                // a ativação ou desativação do produto.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'A alteração de disponibilidade ainda não está conectada à API.',
                    ),
                  ),
                );
              },
              onTap: () {
                context.push(
                  '/cadastrar-produtos',
                  extra: {
                    'editar': true,
                    'produtoId': produto.id,
                  },
                );
              },
              exibirSeta: true,
            ),
          );
        },
      ),
    );
  }
}
