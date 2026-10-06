import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nhac_lojas/components/container_nhac.dart';
import 'package:nhac_lojas/components/icon_container.dart';
import 'package:nhac_lojas/controllers/scroll_shell_controller.dart';

import '../models/usuario_model.dart';
import '../models/loja_model.dart';
import '../services/usuario_service.dart';
import '../services/loja_service.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UsuarioService _usuarioService = UsuarioService();
  final LojaService _lojaService = LojaService();

  UsuarioModel? _usuario;
  LojaModel? _loja;

  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      setState(() {
        _carregando = true;
        _erro = null;
      });

      final token = await AuthService.obterToken();

      if (token == null || token.isEmpty) {
        throw Exception('Usuário não autenticado.');
      }

      /*
       * IMPORTANTE:
       * Aqui precisamos do ID do usuário.
       *
       * Se o seu CadastroUsuario ainda estiver disponível depois
       * do login/cadastro, podemos usar:
       *
       * final usuarioId = CadastroUsuario.id;
       *
       * Neste código estou deixando a origem explícita para você
       * conectar ao seu mecanismo atual de usuário logado.
       */

  
    final usuarioId = await AuthService.obterUsuarioId();

    if (usuarioId == null || usuarioId.isEmpty) {
      throw Exception(
        'ID do usuário não disponível. Faça login novamente.',
      );
    }



      final usuarioFuture =
          _usuarioService.buscarUsuario(usuarioId);

      final lojaFuture =
          _lojaService.buscarMinhaLoja(token);

      final resultados = await Future.wait([
        usuarioFuture,
        lojaFuture,
      ]);

      final usuario = resultados[0] as UsuarioModel;
      final loja = resultados[1] as LojaModel;

      if (!mounted) return;

      setState(() {
        _usuario = usuario;
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

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              SizedBox(height: 12.h),
              Text(
                'Não foi possível carregar os dados.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: _carregarDados,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final usuario = _usuario!;
    final loja = _loja!;

    final dadosOperacionais = loja.dadosOperacionais;

    final avaliacao =
        dadosOperacionais?.avaliacaoMedia ?? 0.0;

    final totalAvaliacoes =
        dadosOperacionais?.totalAvaliacoes ?? 0;

    return SingleChildScrollView(
      controller: ScrollShellController.of(context),
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
            _buildCabecalho(
              usuario: usuario,
              loja: loja,
            ),

            SizedBox(height: 24.h),

            Padding(
              padding: EdgeInsets.all(8.0.r),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RESUMO DE HOJE',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Ver mais >',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            Row(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20.r),
                    ),
                    child: const ContainerNhac(
                      informacao: '34',
                      fontSize: 20,
                      complemento: 'Pedidos',
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20.r),
                    ),
                    child: const ContainerNhac(
                      informacao: '5',
                      fontSize: 20,
                      complemento: 'Em preparo',
                      corTitulo: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            Row(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20.r),
                    ),
                    child: const ContainerNhac(
                      informacao: '4',
                      fontSize: 20,
                      complemento: 'A caminho',
                      corTitulo: Colors.redAccent,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20.r),
                    ),
                    child: const ContainerNhac(
                      informacao: '25',
                      fontSize: 20,
                      complemento: 'Concluídos',
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20.r),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'FATURAMENTO',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'R\$ 1.284,90',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '↑ +12,5% em relação a ontem',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 60.h,
                    child: LineChart(
                      LineChartData(
                        gridData:
                            const FlGridData(show: false),
                        titlesData:
                            const FlTitlesData(show: false),
                        borderData:
                            FlBorderData(show: false),
                        lineTouchData:
                            const LineTouchData(
                          enabled: false,
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 1.0),
                              FlSpot(1, 1.2),
                              FlSpot(2, 1.1),
                              FlSpot(3, 1.8),
                              FlSpot(4, 1.5),
                              FlSpot(5, 2.1),
                              FlSpot(6, 1.8),
                              FlSpot(7, 2.0),
                            ],
                            isCurved: false,
                            color: Colors.redAccent,
                            barWidth: 2.5,
                            isStrokeCapRound: true,
                            dotData:
                                const FlDotData(
                              show: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20.r),
              ),
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'AVALIAÇÃO DA LOJA',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        avaliacao.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            '★★★★★',
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            '$totalAvaliacoes avaliações',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.sp,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            Padding(
              padding: EdgeInsets.all(8.0.r),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ÚLTIMOS PEDIDOS',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Ver todos >',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  ContainerNhac(
                    codigo: 1250,
                    informacao: 'Maria Silva',
                    quantidadeItens: 2,
                    preco: 49.90,
                    horario: '12:30',
                    situacao: 'Em preparo',
                    onTap: () =>
                        context.push('/order-details'),
                  ),
                  const Divider(
                    color:
                        Color.fromARGB(50, 158, 158, 158),
                  ),
                  ContainerNhac(
                    codigo: 1249,
                    informacao: 'João Pedro',
                    quantidadeItens: 3,
                    preco: 62.50,
                    horario: '12:10',
                    situacao: 'A caminho',
                    onTap: () =>
                        context.push('/order-details'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCabecalho({
    required UsuarioModel usuario,
    required LojaModel loja,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            _buildImagemLoja(loja),

            SizedBox(width: 12.w),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loja.nome,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  loja.isAberto
                      ? '• Loja aberta'
                      : '• Loja fechada',
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

        IconContainer(
          icon: Icons.notifications_none_rounded,
        ),
      ],
    );
  }

  Widget _buildImagemLoja(LojaModel loja) {
    final imagemUrl = loja.imagemUrl;

    if (imagemUrl == null || imagemUrl.isEmpty) {
      return Container(
        width: 48.w,
        height: 48.w,
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: const Color.fromARGB(
            255,
            255,
            242,
            230,
          ),
          borderRadius:
              BorderRadius.circular(20.r),
        ),
        child: Image.asset(
          'assets/images/nhac-logo.png',
          fit: BoxFit.contain,
        ),
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(20.r),
      child: Image.network(
        imagemUrl,
        width: 48.w,
        height: 48.w,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) {
          return Container(
            width: 48.w,
            height: 48.w,
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: const Color.fromARGB(
                255,
                255,
                242,
                230,
              ),
              borderRadius:
                  BorderRadius.circular(20.r),
            ),
            child: Image.asset(
              'assets/images/nhac-logo.png',
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}