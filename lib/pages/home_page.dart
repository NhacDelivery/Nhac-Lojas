import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nhac_lojas/components/container_nhac.dart';
import 'package:nhac_lojas/components/icon_container.dart';
import 'package:nhac_lojas/controllers/scroll_shell_controller.dart';

import '../models/usuario_model.dart';
import '../models/loja_model.dart';
import '../models/painel_model.dart';

import '../services/usuario_service.dart';
import '../services/loja_service.dart';
import '../services/painel_service.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UsuarioService _usuarioService = UsuarioService();
  final LojaService _lojaService = LojaService();
  final PainelService _painelService = PainelService();

  UsuarioModel? _usuario;
  LojaModel? _loja;
  PainelResumoModel? _painel;

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

      final painelFuture =
          _painelService.buscarResumo(token);

      final resultados = await Future.wait([
        usuarioFuture,
        lojaFuture,
        painelFuture,
      ]);

      if (!mounted) return;

      setState(() {
        _usuario = resultados[0] as UsuarioModel;
        _loja = resultados[1] as LojaModel;
        _painel = resultados[2] as PainelResumoModel;
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
      return _buildErro();
    }

    if (_usuario == null ||
        _loja == null ||
        _painel == null) {
      return _buildErro(
        mensagem: 'Dados do painel não disponíveis.',
      );
    }

    final usuario = _usuario!;
    final loja = _loja!;
    final painel = _painel!;

    final dadosOperacionais = loja.dadosOperacionais;

    final avaliacao =
        dadosOperacionais?.avaliacaoMedia ?? 0.0;

    final totalAvaliacoes =
        dadosOperacionais?.totalAvaliacoes ?? 0;

    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: SingleChildScrollView(
        controller: ScrollShellController.of(context),
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
              _buildCabecalho(
                usuario: usuario,
                loja: loja,
                painel: painel,
              ),

              SizedBox(height: 24.h),

              _buildTituloSecao(
                titulo: 'RESUMO DE HOJE',
                acao: 'Ver mais >',
              ),

              SizedBox(height: 4.h),

              _buildResumoPedidos(painel),

              SizedBox(height: 16.h),

              _buildFaturamento(painel),

              SizedBox(height: 16.h),

              _buildAvaliacao(
                avaliacao: avaliacao,
                totalAvaliacoes: totalAvaliacoes,
              ),

              SizedBox(height: 16.h),

              _buildTituloSecao(
                titulo: 'ÚLTIMOS PEDIDOS',
                acao: 'Ver todos >',
              ),

              SizedBox(height: 8.h),

              _buildPedidosRecentes(painel),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERRO
  // ============================================================

  Widget _buildErro({
    String? mensagem,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
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
              mensagem ?? _erro ?? 'Erro desconhecido.',
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

  // ============================================================
  // CABEÇALHO
  // ============================================================

  Widget _buildCabecalho({
    required UsuarioModel usuario,
    required LojaModel loja,
    required PainelResumoModel painel,
  }) {
    final lojaAberta = painel.lojaAberta;

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
                  lojaAberta
                      ? '• Loja aberta'
                      : '• Loja fechada',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: lojaAberta
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

  // ============================================================
  // RESUMO
  // ============================================================

  Widget _buildTituloSecao({
    required String titulo,
    required String acao,
  }) {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            acao,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoPedidos(
    PainelResumoModel painel,
  ) {
    final totalPedidos =
        painel.pedidosEmPreparo +
        painel.pedidosACaminho +
        painel.pedidosConcluidosHoje;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCardResumo(
                informacao: totalPedidos.toString(),
                complemento: 'Pedidos',
              ),
            ),

            SizedBox(width: 8.w),

            Expanded(
              child: _buildCardResumo(
                informacao:
                    painel.pedidosEmPreparo.toString(),
                complemento: 'Em preparo',
                corTitulo: Colors.orange,
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),

        Row(
          children: [
            Expanded(
              child: _buildCardResumo(
                informacao:
                    painel.pedidosACaminho.toString(),
                complemento: 'A caminho',
                corTitulo: Colors.redAccent,
              ),
            ),

            SizedBox(width: 8.w),

            Expanded(
              child: _buildCardResumo(
                informacao:
                    painel.pedidosConcluidosHoje.toString(),
                complemento: 'Concluídos',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardResumo({
    required String informacao,
    required String complemento,
    Color? corTitulo,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20.r),
      ),
      child: ContainerNhac(
        informacao: informacao,
        fontSize: 20,
        complemento: complemento,
        corTitulo: corTitulo,
      ),
    );
  }

  // ============================================================
  // FATURAMENTO
  // ============================================================

  Widget _buildFaturamento(
    PainelResumoModel painel,
  ) {
    final faturamentos =
        painel.faturamentoUltimos7Dias;

    final spots = faturamentos
        .asMap()
        .entries
        .map(
          (entry) => FlSpot(
            entry.key.toDouble(),
            entry.value.valor,
          ),
        )
        .toList();

    return Container(
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
            _formatarMoeda(
              painel.faturamentoHoje,
            ),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12.h),

          SizedBox(
            height: 80.h,
            child: spots.isEmpty
                ? Center(
                    child: Text(
                      'Sem dados de faturamento.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.sp,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: spots.length > 1
                          ? (spots.length - 1).toDouble()
                          : 1,

                      minY: _calcularMinY(spots),
                      maxY: _calcularMaxY(spots),

                      gridData:
                          const FlGridData(
                        show: false,
                      ),

                      titlesData:
                          const FlTitlesData(
                        show: false,
                      ),

                      borderData:
                          FlBorderData(
                        show: false,
                      ),

                      lineTouchData:
                          const LineTouchData(
                        enabled: false,
                      ),

                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
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

          if (faturamentos.isNotEmpty) ...[
            SizedBox(height: 8.h),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatarData(
                    faturamentos.first.data,
                  ),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10.sp,
                  ),
                ),

                Text(
                  _formatarData(
                    faturamentos.last.data,
                  ),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  double _calcularMinY(
    List<FlSpot> spots,
  ) {
    if (spots.isEmpty) {
      return 0;
    }

    final menor = spots
        .map((spot) => spot.y)
        .reduce(
          (a, b) => a < b ? a : b,
        );

    if (menor <= 0) {
      return 0;
    }

    return menor * 0.8;
  }

  double _calcularMaxY(
    List<FlSpot> spots,
  ) {
    if (spots.isEmpty) {
      return 10;
    }

    final maior = spots
        .map((spot) => spot.y)
        .reduce(
          (a, b) => a > b ? a : b,
        );

    if (maior <= 0) {
      return 10;
    }

    return maior * 1.2;
  }

  // ============================================================
  // AVALIAÇÃO
  // ============================================================

  Widget _buildAvaliacao({
    required double avaliacao,
    required int totalAvaliacoes,
  }) {
    return Container(
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
    );
  }

  // ============================================================
  // PEDIDOS RECENTES
  // ============================================================

  Widget _buildPedidosRecentes(
    PainelResumoModel painel,
  ) {
    final pedidos = painel.pedidosRecentes;

    if (pedidos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20.r),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 36.sp,
              color: Colors.grey,
            ),

            SizedBox(height: 8.h),

            Text(
              'Nenhum pedido recente.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          for (int i = 0; i < pedidos.length; i++) ...[
            _buildPedido(
              pedido: pedidos[i],
            ),

            if (i < pedidos.length - 1)
              const Divider(
                color: Color.fromARGB(
                  50,
                  158,
                  158,
                  158,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPedido({
    required PedidoResumoLojistaModel pedido,
  }) {
    return ContainerNhac(
      codigo: int.tryParse(pedido.id) ?? 0,
      informacao: pedido.clienteNome,
      quantidadeItens:
          pedido.quantidadeItens,
      preco: pedido.valorTotal,
      horario: _formatarHorario(
        pedido.criadoEm,
      ),
      situacao: _statusPedidoTexto(
        pedido.status,
      ),
      onTap: () {
        context.push('/order-details');
      },
    );
  }

  // ============================================================
  // IMAGEM DA LOJA
  // ============================================================

  Widget _buildImagemLoja(
    LojaModel loja,
  ) {
    final imagemUrl = loja.imagemUrl;

    if (imagemUrl == null ||
        imagemUrl.isEmpty) {
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

  // ============================================================
  // FORMATADORES
  // ============================================================

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarHorario(DateTime data) {
    final hora = data.hour
        .toString()
        .padLeft(2, '0');

    final minuto = data.minute
        .toString()
        .padLeft(2, '0');

    return '$hora:$minuto';
  }

  String _formatarData(DateTime data) {
    final dia = data.day
        .toString()
        .padLeft(2, '0');

    final mes = data.month
        .toString()
        .padLeft(2, '0');

    return '$dia/$mes';
  }

  String _statusPedidoTexto(
    String status,
  ) {
    switch (status) {
      case 'PENDENTE':
        return 'Pendente';

      case 'PAGO':
        return 'Pago';

      case 'PREPARANDO':
        return 'Em preparo';

      case 'SAIU_ENTREGA':
        return 'A caminho';

      case 'ENTREGUE':
        return 'Concluído';

      case 'CANCELADO':
        return 'Cancelado';

      default:
        return status;
    }
  }
}