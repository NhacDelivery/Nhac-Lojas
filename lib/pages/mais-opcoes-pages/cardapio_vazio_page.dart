import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac_lojas/services/auth_service.dart';
import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/services/lojista_service.dart';

// IMPORTANTE:
// Ajuste o import do serviço de autenticação conforme
// a estrutura real do seu projeto.

class CardapioVazioPage extends StatefulWidget {
  const CardapioVazioPage({super.key});

  @override
  State<CardapioVazioPage> createState() => _CardapioVazioPageState();
}

class _CardapioVazioPageState extends State<CardapioVazioPage> {
  final LojistaService _lojistaService = LojistaService();

  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarProdutos();
    });
  }

Future<void> _carregarProdutos() async {
  if (!mounted) return;

  setState(() {
    _carregando = true;
    _erro = null;
  });

  try {
    // Recupera o JWT salvo durante o login.
    final String? token = await AuthService.obterToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Sua sessão expirou. Faça login novamente.',
      );
    }

    // Consulta os produtos da loja do usuário autenticado.
    final resposta = await _lojistaService.listarProdutos(
      token: token,
      pagina: 0,
      tamanho: 20,
    );

    if (!mounted) return;

    final dynamic conteudo = resposta['content'];

    if (conteudo is! List) {
      throw Exception(
        'Formato de resposta inválido ao consultar os produtos.',
      );
    }

    if (conteudo.isNotEmpty) {
      // Ajuste para a rota real da sua tela de produtos.
      context.go('/cardapio-cheio');
      return;
    }

    setState(() {
      _carregando = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _carregando = false;
      _erro = e.toString().replaceFirst('Exception: ', '');
    });
  }
}


  @override
  void dispose() {
    _lojistaService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Expanded(
                child: Center(
                  child: _construirConteudo(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirConteudo() {
    if (_carregando) {
      return const CircularProgressIndicator();
    }

    if (_erro != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off,
            size: 60.sp,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'Não foi possível carregar seu cardápio.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _erro!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 24.h),
          ButtonNhac(
            texto: 'Tentar novamente',
            onTap: _carregarProdutos,
          ),
        ],
      );
    }

    return _construirCardapioVazio();
  }

  Widget _construirCardapioVazio() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 140.w,
          height: 140.w,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 213, 213),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.flatware_outlined,
            size: 60.sp,
            color: Colors.redAccent,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Seu cardápio está vazio',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Adicione produtos com fotos, preços\n'
          'e descrição para seus clientes\n'
          'verem na loja.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 24.h),
        ButtonNhac(
          texto: 'Adicionar produto',
          onTap: () => context.push('/cadastrar-produtos'),
        ),
      ],
    );
  }
}
