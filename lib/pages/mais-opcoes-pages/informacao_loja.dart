
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/container_nhac.dart';

import 'package:nhac_lojas/models/loja_model.dart';
import 'package:nhac_lojas/services/loja_service.dart';
import 'package:nhac_lojas/services/auth_service.dart';

class InformacaoLoja extends StatefulWidget {
  const InformacaoLoja({super.key});

  @override
  State<InformacaoLoja> createState() => _InformacaoLojaState();
}

class _InformacaoLojaState extends State<InformacaoLoja> {
  final LojaService _lojaService = LojaService();

  LojaModel? _loja;

  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarLoja();
  }

  // ============================================================
  // CARREGAR DADOS DA LOJA
  // ============================================================

  Future<void> _carregarLoja() async {
    try {
      if (mounted) {
        setState(() {
          _carregando = true;
          _erro = null;
        });
      }

      final token = await AuthService.obterToken();

      if (token == null || token.isEmpty) {
        throw Exception('Usuário não autenticado.');
      }

      final loja = await _lojaService.buscarMinhaLoja(token);

      if (!mounted) return;

      setState(() {
        _loja = loja;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = e.toString();
        _carregando = false;
      });
    }
  }

  // ============================================================
  // ABRIR EDIÇÃO E ATUALIZAR DADOS AO VOLTAR
  // ============================================================

  Future<void> _abrirTelaEdicao(String rota) async {
    await context.push(rota);

    if (!mounted) return;

    await _carregarLoja();
  }

  // ============================================================
  // MODAL SAIR
  // ============================================================

  void _mostrarModalSair(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.r, 0, 20.r, 20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 36.r,
                  backgroundColor:
                      const Color.fromARGB(255, 255, 242, 230),
                  child: Icon(
                    Icons.logout_outlined,
                    color: Colors.redAccent,
                    size: 32.sp,
                  ),
                ),

                SizedBox(height: 16.h),

                Text(
                  'Sair da conta?',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  textAlign: TextAlign.center,
                  'Você precisará entrar novamente com seu e-mail e\nsenha para acessar o painel da loja.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.sp,
                  ),
                ),

                SizedBox(height: 24.h),

                ButtonNhac(
                  texto: 'Sair da conta',
                  onTap: () {
                    Navigator.pop(modalContext);
                    context.go('/bem-vindo');
                  },
                ),

                SizedBox(height: 12.h),

                ButtonNhac(
                  texto: 'Cancelar',
                  isSecundario: true,
                  onTap: () => Navigator.pop(modalContext),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // IMAGEM DA LOJA
  // ============================================================

  Widget _buildImagemLoja() {
    final imagemUrl = _loja!.imagemUrl;

    if (imagemUrl == null || imagemUrl.isEmpty) {
      return _imagemPadrao();
    }

    return ClipOval(
      child: Image.network(
        imagemUrl,
        width: 128.w,
        height: 128.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imagemPadrao();
        },
      ),
    );
  }

  Widget _imagemPadrao() {
    return Container(
      width: 128.w,
      height: 128.w,
      padding: EdgeInsets.all(20.r),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 242, 230),
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        'assets/images/nhac-logo.png',
        fit: BoxFit.contain,
      ),
    );
  }

  // ============================================================
  // ERRO
  // ============================================================

  Widget _buildErro() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48.sp,
                color: Colors.redAccent,
              ),

              SizedBox(height: 12.h),

              Text(
                'Não foi possível carregar a loja.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                _erro ?? 'Erro desconhecido.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),

              SizedBox(height: 16.h),

              ElevatedButton(
                onPressed: _carregarLoja,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_erro != null || _loja == null) {
      return _buildErro();
    }

    final loja = _loja!;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _carregarLoja,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20.w,
              46.h,
              20.w,
              110.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // CABEÇALHO

                Row(
                  children: [
                    const BackArrow(),

                    SizedBox(width: 12.w),

                    Text(
                      'Informações da loja',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32.h),

                // PERFIL DA LOJA

                Center(
                  child: Column(
                    children: [
                      _buildImagemLoja(),

                      SizedBox(height: 12.h),

                      Text(
                        loja.nome,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        loja.categoria ?? 'Categoria não informada',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.sp,
                        ),
                      ),

                      if (loja.descricao != null &&
                          loja.descricao!.isNotEmpty) ...[
                        SizedBox(height: 8.h),

                        Text(
                          loja.descricao!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12.sp,
                          ),
                        ),
                      ],

                      SizedBox(height: 8.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 9.sp,
                            color: loja.isAberto
                                ? Colors.green
                                : Colors.redAccent,
                          ),

                          SizedBox(width: 6.w),

                          Text(
                            loja.isAberto
                                ? 'Loja aberta'
                                : 'Loja fechada',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: loja.isAberto
                                  ? Colors.green
                                  : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // OPÇÕES DA LOJA

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [

                      ContainerNhac(
                        icon: Icons.store_outlined,
                        informacao: 'Nome, categoria e descrição',
                        fontSize: 14,
                        exibirSeta: true,
                        onTap: () => _abrirTelaEdicao(
                          '/editar-info-loja',
                        ),
                      ),

                      SizedBox(height: 8.h),
                      const Divider(),
                      SizedBox(height: 8.h),

                      ContainerNhac(
                        icon: Icons.credit_card_outlined,
                        informacao: 'Formas de pagamento',
                        fontSize: 14,
                        exibirSeta: true,
                        onTap: () => _abrirTelaEdicao(
                          '/formas-pagamento-edicao',
                        ),
                      ),

                      SizedBox(height: 8.h),
                      const Divider(),
                      SizedBox(height: 8.h),

                      ContainerNhac(
                        icon: Icons.location_on_outlined,
                        informacao: 'Endereço da loja',
                        fontSize: 14,
                        exibirSeta: true,
                        onTap: () => _abrirTelaEdicao(
                          '/endereco-edicao',
                        ),
                      ),

                      SizedBox(height: 8.h),
                      const Divider(),
                      SizedBox(height: 8.h),

                      ContainerNhac(
                        icon: Icons.settings_outlined,
                        informacao: 'Configurações da conta',
                        fontSize: 14,
                        exibirSeta: true,
                        onTap: () => _abrirTelaEdicao(
                          '/configuracoes-conta',
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // SAIR DA CONTA

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      ContainerNhac(
                        icon: Icons.logout_outlined,
                        informacao: 'Sair da conta',
                        fontSize: 14,
                        exibirSeta: true,
                        onTap: () => _mostrarModalSair(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
