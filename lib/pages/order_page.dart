import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac_lojas/controllers/scroll_shell_controller.dart';
import 'package:nhac_lojas/models/pedido_resumo_model.dart';
import 'package:nhac_lojas/services/auth_service.dart';
import 'package:nhac_lojas/services/pedido_service.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final PedidoService _service = PedidoService();
  final TextEditingController _busca = TextEditingController();
  List<PedidoResumoLojistaModel> _pedidos = [];
  bool _carregando = true;
  String? _erro;
  String _filtro = 'Todos';

  static const Map<String, String> _status = {
    'Todos': '',
    'Novos': 'PENDENTE',
    'Em preparo': 'PREPARANDO',
    'A caminho': 'A_CAMINHO',
    'Entregues': 'ENTREGUE',
  };

  @override
  void initState() { super.initState(); _carregar(); }
  @override
  void dispose() { _busca.dispose(); super.dispose(); }

  Future<void> _carregar() async {
    if (mounted) setState(() { _carregando = true; _erro = null; });
    try {
      final token = await AuthService.obterToken();
      if (token == null || token.isEmpty) throw Exception('Sua sessão expirou. Entre novamente.');
      final pedidos = await _service.buscarPedidos(token: token);
      if (!mounted) return;
      setState(() { _pedidos = pedidos; _carregando = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _erro = e.toString().replaceFirst('Exception: ', ''); _carregando = false; });
    }
  }

  List<PedidoResumoLojistaModel> get _filtrados {
    final status = _status[_filtro] ?? '';
    final termo = _busca.text.trim().toLowerCase();
    return _pedidos.where((p) {
      final s = p.status.toUpperCase();
      final okStatus = status.isEmpty || s == status ||
          (status == 'PENDENTE' && s == 'AGUARDANDO_CONFIRMACAO') ||
          (status == 'A_CAMINHO' && s == 'EM_ROTA');
      final okBusca = termo.isEmpty || p.clienteNome.toLowerCase().contains(termo) || p.id.toLowerCase().contains(termo);
      return okStatus && okBusca;
    }).toList();
  }

  String _moeda(double v) => 'R$ ' + v.toStringAsFixed(2).replaceAll('.', ',');
  String _hora(DateTime d) {
    final x = d.toLocal();
    return x.hour.toString().padLeft(2, '0') + ':' + x.minute.toString().padLeft(2, '0');
  }
  String _rotulo(String s) => switch (s.toUpperCase()) {
    'PENDENTE' || 'AGUARDANDO_CONFIRMACAO' => 'Novo',
    'PREPARANDO' => 'Em preparo',
    'PRONTO' => 'Pronto',
    'A_CAMINHO' || 'EM_ROTA' => 'A caminho',
    'ENTREGUE' => 'Entregue',
    'CANCELADO' => 'Cancelado',
    _ => s.replaceAll('_', ' '),
  };
  Color _cor(String s) => switch (s.toUpperCase()) {
    'PENDENTE' || 'AGUARDANDO_CONFIRMACAO' => const Color(0xFFC77700),
    'PREPARANDO' => const Color(0xFF4E6E9E),
    'PRONTO' || 'ENTREGUE' => const Color(0xFF2F8F4E),
    'A_CAMINHO' || 'EM_ROTA' => const Color(0xFF4E6E9E),
    'CANCELADO' => const Color(0xFFC63F35),
    _ => const Color(0xFF8B4944),
  };

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: _carregar,
    child: SingleChildScrollView(
      controller: ScrollShellController.of(context),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 120.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Pedidos', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800))),
            IconButton(onPressed: _carregar, icon: const Icon(Icons.refresh_rounded)),
          ]),
          Text(_pedidos.length.toString() + ' pedidos carregados', style: const TextStyle(color: Color(0xFF8B4944), fontSize: 12)),
          SizedBox(height: 18.h),
          TextField(
            controller: _busca,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: 'Buscar por cliente ou código', prefixIcon: Icon(Icons.search)),
          ),
          SizedBox(height: 14.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: _status.keys.map((f) => Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: ChoiceChip(
                label: Text(f),
                selected: _filtro == f,
                selectedColor: const Color(0xFFFFD9D6),
                labelStyle: TextStyle(color: const Color(0xFF5D201C), fontWeight: _filtro == f ? FontWeight.w800 : FontWeight.w500),
                onSelected: (_) => setState(() => _filtro = f),
                side: BorderSide(color: _filtro == f ? const Color(0xFFFF6961) : const Color(0xFFF5C4C1)),
              ),
            )).toList()),
          ),
          SizedBox(height: 18.h),
          if (_carregando)
            const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator()))
          else if (_erro != null)
            _estado(_erro!, 'Tentar novamente', _carregar)
          else if (_filtrados.isEmpty)
            _estado('Nenhum pedido encontrado com esse filtro.', null, null)
          else
            ..._filtrados.map(_cartaoPedido),
        ]),
      ),
    ),
  );

  Widget _cartaoPedido(PedidoResumoLojistaModel p) => Padding(
    padding: EdgeInsets.only(bottom: 10.h),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () async {
          final atualizado = await context.push<bool>('/order-details', extra: p);
          if (atualizado == true && mounted) _carregar();
        },
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('#' + p.id, style: const TextStyle(fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()])),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(color: _cor(p.status).withValues(alpha: .12), borderRadius: BorderRadius.circular(30)),
                child: Text(_rotulo(p.status), style: TextStyle(color: _cor(p.status), fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ]),
            SizedBox(height: 12.h),
            Text(p.clienteNome, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 5.h),
            Row(children: [
              Expanded(child: Text(p.quantidadeItens.toString() + (p.quantidadeItens == 1 ? ' item · ' : ' itens · ') + _hora(p.criadoEm), style: const TextStyle(color: Color(0xFF8B4944), fontSize: 12))),
              Text(_moeda(p.valorTotal), style: const TextStyle(fontWeight: FontWeight.w800)),
              SizedBox(width: 4.w),
              const Icon(Icons.chevron_right, color: Color(0xFF8B4944)),
            ]),
          ]),
        ),
      ),
    ),
  );

  Widget _estado(String mensagem, String? botao, VoidCallback? acao) => Container(
    width: double.infinity, padding: EdgeInsets.all(24.r),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
    child: Column(children: [
      const Icon(Icons.receipt_long_outlined, size: 36, color: Color(0xFF8B4944)),
      SizedBox(height: 10.h),
      Text(mensagem, textAlign: TextAlign.center),
      if (botao != null) TextButton(onPressed: acao, child: Text(botao)),
    ]),
  );
}
