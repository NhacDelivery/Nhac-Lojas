import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/models/pedido_resumo_model.dart';

class OrderDetailsPage extends StatelessWidget {
  final PedidoResumoLojistaModel pedido;
  const OrderDetailsPage({super.key, required this.pedido});

  String _moeda(double v) => 'R$ ' + v.toStringAsFixed(2).replaceAll('.', ',');
  String _data(DateTime d) {
    final x = d.toLocal();
    return x.day.toString().padLeft(2, '0') + '/' +
      x.month.toString().padLeft(2, '0') + '/' + x.year.toString() + ' às ' +
      x.hour.toString().padLeft(2, '0') + ':' + x.minute.toString().padLeft(2, '0');
  }
  String _status(String s) => switch (s.toUpperCase()) {
    'PENDENTE' || 'AGUARDANDO_CONFIRMACAO' => 'Novo pedido',
    'PREPARANDO' => 'Em preparo',
    'PRONTO' => 'Pronto para retirada',
    'A_CAMINHO' || 'EM_ROTA' => 'A caminho',
    'ENTREGUE' => 'Entregue',
    'CANCELADO' => 'Cancelado',
    _ => s.replaceAll('_', ' '),
  };

  @override
  Widget build(BuildContext context) {
    final podeAtualizar = !['ENTREGUE', 'CANCELADO'].contains(pedido.status.toUpperCase());
    return Scaffold(
      body: SafeArea(child: Column(children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 14.h),
          child: Row(children: [
            const BackArrow(),
            SizedBox(width: 12.w),
            Expanded(child: Text('Pedido #' + pedido.id, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800))),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 30.h),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: double.infinity, padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('STATUS DO PEDIDO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: Color(0xFF8B4944))),
                SizedBox(height: 8.h),
                Text(_status(pedido.status), style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800)),
                SizedBox(height: 5.h),
                Text('Recebido em ' + _data(pedido.criadoEm), style: const TextStyle(color: Color(0xFF8B4944), fontSize: 12)),
              ]),
            ),
            SizedBox(height: 14.h),
            _secao('CLIENTE', [
              _linha(Icons.person_outline, 'Nome', pedido.clienteNome),
            ]),
            SizedBox(height: 14.h),
            _secao('RESUMO DO PEDIDO', [
              _linha(Icons.shopping_bag_outlined, 'Quantidade', pedido.quantidadeItens.toString() + ' itens'),
              const Divider(height: 22),
              _linha(Icons.payments_outlined, 'Valor total', _moeda(pedido.valorTotal)),
              const Divider(height: 22),
              _linha(Icons.tag_outlined, 'Identificador', pedido.id),
            ]),
            SizedBox(height: 14.h),
            Container(
              width: double.infinity, padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(color: const Color(0xFFFFF3F2), borderRadius: BorderRadius.circular(14.r)),
              child: const Text('A API disponibiliza para esta tela somente o resumo do pedido. Não exibimos endereço, telefone, pagamento ou produtos fictícios.', style: TextStyle(fontSize: 12, height: 1.45, color: Color(0xFF8B4944))),
            ),
          ]),
        )),
        if (podeAtualizar)
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6961), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 15.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r))),
                onPressed: () async {
                  final atualizado = await context.push<bool>('/update-status', extra: pedido);
                  if (context.mounted && atualizado == true) context.pop(true);
                },
                child: const Text('Atualizar status do pedido', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ),
      ])),
    );
  }

  Widget _secao(String titulo, List<Widget> children) => Container(
    width: double.infinity, padding: EdgeInsets.all(18.r),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titulo, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: Color(0xFF8B4944))),
      SizedBox(height: 14.h),
      ...children,
    ]),
  );

  Widget _linha(IconData icone, String titulo, String valor) => Row(children: [
    Icon(icone, color: const Color(0xFFFF6961), size: 20),
    SizedBox(width: 10.w),
    Expanded(child: Text(titulo, style: const TextStyle(color: Color(0xFF8B4944), fontSize: 12))),
    Flexible(child: Text(valor, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w700))),
  ]);
}
