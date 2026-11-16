import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac_lojas/controllers/scroll_shell_controller.dart';
import 'package:nhac_lojas/models/painel_model.dart';
import 'package:nhac_lojas/models/pedido_resumo_model.dart';
import 'package:nhac_lojas/services/auth_service.dart';
import 'package:nhac_lojas/services/painel_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PainelService _service = PainelService();
  PainelResumoModel? _painel;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() { super.initState(); _carregar(); }

  Future<void> _carregar() async {
    if (mounted) setState(() { _carregando = true; _erro = null; });
    try {
      final token = await AuthService.obterToken();
      if (token == null || token.isEmpty) throw Exception('Sua sessão expirou. Entre novamente.');
      final dados = await _service.buscarResumo(token);
      if (!mounted) return;
      setState(() { _painel = dados; _carregando = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _erro = e.toString().replaceFirst('Exception: ', ''); _carregando = false; });
    }
  }

  String _moeda(double v) => 'R\$ ' + v.toStringAsFixed(2).replaceAll('.', ',');
  String _hora(DateTime d) {
    final x = d.toLocal();
    return x.hour.toString().padLeft(2, '0') + ':' + x.minute.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: _carregar,
    child: SingleChildScrollView(
      controller: ScrollShellController.of(context),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 120.h),
        child: _carregando
          ? const SizedBox(height: 420, child: Center(child: CircularProgressIndicator()))
          : _erro != null
            ? _estadoErro()
            : _conteudo(_painel!),
      ),
    ),
  );

  Widget _estadoErro() => SizedBox(
    height: 420,
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.cloud_off_outlined, size: 44, color: Color(0xFF8B4944)),
      SizedBox(height: 12.h),
      Text(_erro!, textAlign: TextAlign.center),
      SizedBox(height: 12.h),
      FilledButton(onPressed: _carregar, child: const Text('Tentar novamente')),
    ])),
  );

  Widget _conteudo(PainelResumoModel p) {
    final total = p.pedidosEmPreparo + p.pedidosACaminho + p.pedidosConcluidosHoje;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 48.r, height: 48.r, padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(color: const Color(0xFFFFF3F2), borderRadius: BorderRadius.circular(15.r)),
          child: Image.asset('assets/images/nhac-logo.png', fit: BoxFit.contain)),
        SizedBox(width: 12.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Painel da loja', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800)),
          Text('Acompanhe a operação de hoje', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF8B4944))),
        ])),
        IconButton(onPressed: _carregar, icon: const Icon(Icons.refresh_rounded)),
      ]),
      SizedBox(height: 20.h),
      _statusLoja(p.lojaAberta),
      SizedBox(height: 22.h),
      _titulo('Resumo de hoje', 'Ver pedidos', () => context.go('/orders')),
      SizedBox(height: 10.h),
      Row(children: [
        Expanded(child: _indicador('Em preparo', p.pedidosEmPreparo.toString(), Icons.restaurant, const Color(0xFFC77700))),
        SizedBox(width: 10.w),
        Expanded(child: _indicador('A caminho', p.pedidosACaminho.toString(), Icons.delivery_dining, const Color(0xFF4E6E9E))),
      ]),
      SizedBox(height: 10.h),
      Row(children: [
        Expanded(child: _indicador('Concluídos', p.pedidosConcluidosHoje.toString(), Icons.check_circle_outline, const Color(0xFF2F8F4E))),
        SizedBox(width: 10.w),
        Expanded(child: _indicador('No resumo', total.toString(), Icons.receipt_long, const Color(0xFF5D201C))),
      ]),
      SizedBox(height: 18.h),
      _faturamento(p),
      SizedBox(height: 22.h),
      _titulo('Fila de operação', 'Todos', () => context.go('/orders')),
      SizedBox(height: 10.h),
      if (p.pedidosRecentes.isEmpty)
        _vazio('Nenhum pedido recente para exibir.')
      else
        ...p.pedidosRecentes.take(5).map(_pedido),
    ]);
  }

  Widget _statusLoja(bool aberta) => Container(
    width: double.infinity, padding: EdgeInsets.all(18.r),
    decoration: BoxDecoration(color: aberta ? const Color(0xFF2F8F4E) : const Color(0xFF5D201C), borderRadius: BorderRadius.circular(16.r)),
    child: Row(children: [
      Icon(aberta ? Icons.storefront : Icons.store_outlined, color: Colors.white, size: 28),
      SizedBox(width: 12.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(aberta ? 'LOJA ABERTA' : 'LOJA FECHADA', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const Text('Status informado pelo painel da loja', style: TextStyle(color: Colors.white70, fontSize: 11)),
      ])),
      const Icon(Icons.circle, color: Colors.white, size: 10),
    ]),
  );

  Widget _titulo(String titulo, String acao, VoidCallback onTap) => Row(children: [
    Expanded(child: Text(titulo, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800))),
    TextButton(onPressed: onTap, child: Text(acao, style: const TextStyle(color: Color(0xFFE85D56), fontWeight: FontWeight.w700))),
  ]);

  Widget _indicador(String titulo, String valor, IconData icone, Color cor) => Container(
    padding: EdgeInsets.all(14.r),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
    child: Row(children: [
      Container(width: 36.r, height: 36.r, decoration: BoxDecoration(color: cor.withValues(alpha: .12), borderRadius: BorderRadius.circular(11.r)), child: Icon(icone, color: cor, size: 19)),
      SizedBox(width: 9.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(valor, style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w800, fontFeatures: const [FontFeature.tabularFigures()])),
        Text(titulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF8B4944))),
      ])),
    ]),
  );

  Widget _faturamento(PainelResumoModel p) => Container(
    width: double.infinity, padding: EdgeInsets.all(18.r),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('FATURAMENTO DE HOJE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
      SizedBox(height: 5.h),
      Text(_moeda(p.faturamentoHoje), style: TextStyle(fontSize: 27.sp, fontWeight: FontWeight.w800, fontFeatures: const [FontFeature.tabularFigures()])),
      SizedBox(height: 12.h),
      SizedBox(height: 90.h, child: p.faturamentoUltimos7Dias.isEmpty
        ? const Center(child: Text('Sem histórico disponível', style: TextStyle(color: Color(0xFF8B4944))))
        : LineChart(LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: const LineTouchData(enabled: false),
            minY: 0,
            lineBarsData: [LineChartBarData(
              spots: p.faturamentoUltimos7Dias.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.valor)).toList(),
              isCurved: true, color: const Color(0xFFFF6961), barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: const Color(0xFFFF6961).withValues(alpha: .10)),
            )],
          ))),
    ]),
  );

  Widget _pedido(PedidoResumoLojistaModel p) => Padding(
    padding: EdgeInsets.only(bottom: 10.h),
    child: Material(color: Colors.white, borderRadius: BorderRadius.circular(16.r),
      child: InkWell(borderRadius: BorderRadius.circular(16.r), onTap: () => context.push('/order-details', extra: p),
        child: Padding(padding: EdgeInsets.all(15.r), child: Row(children: [
          Container(width: 42.r, height: 42.r, decoration: BoxDecoration(color: const Color(0xFFFFF0EF), borderRadius: BorderRadius.circular(12.r)), child: const Icon(Icons.receipt_long, color: Color(0xFFFF6961))),
          SizedBox(width: 12.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Pedido #' + p.id, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(p.clienteNome + ' · ' + p.quantidadeItens.toString() + ' itens', style: const TextStyle(fontSize: 12, color: Color(0xFF8B4944))),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_moeda(p.valorTotal), style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(_hora(p.criadoEm), style: const TextStyle(fontSize: 11, color: Color(0xFF8B4944))),
          ]),
        ])),
      ),
    ),
  );

  Widget _vazio(String mensagem) => Container(
    width: double.infinity, padding: EdgeInsets.all(24.r),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
    child: Text(mensagem, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF8B4944))),
  );
}
