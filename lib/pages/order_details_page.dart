import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/models/pedido_detalhe_lojista_model.dart';
import 'package:nhac_lojas/models/pedido_resumo_model.dart';
import 'package:nhac_lojas/services/auth_service.dart';
import 'package:nhac_lojas/services/pedido_service.dart';

class OrderDetailsPage extends StatefulWidget {
  final PedidoResumoLojistaModel pedido;
  const OrderDetailsPage({super.key, required this.pedido});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final PedidoService _service = PedidoService();
  PedidoDetalheLojistaModel? _detalhe;
  String? _erro;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    if (mounted) setState(() { _carregando = true; _erro = null; });
    try {
      final token = await AuthService.obterToken();
      if (token == null || token.isEmpty) {
        throw Exception('Sua sessão expirou. Entre novamente.');
      }
      final detalhe = await _service.buscarDetalhe(
        token: token,
        pedidoId: widget.pedido.id,
      );
      if (!mounted) return;
      setState(() { _detalhe = detalhe; _carregando = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
        _carregando = false;
      });
    }
  }

  String _moeda(double v) => 'R\$ ' + v.toStringAsFixed(2).replaceAll('.', ',');
  String _data(DateTime d) {
    final x = d.toLocal();
    return x.day.toString().padLeft(2, '0') + '/' +
        x.month.toString().padLeft(2, '0') + '/' + x.year.toString() + ' às ' +
        x.hour.toString().padLeft(2, '0') + ':' +
        x.minute.toString().padLeft(2, '0');
  }

  String _status(String s) => switch (s.toUpperCase()) {
    'PENDENTE' => 'Recebido',
    'PAGO' => 'Pago',
    'PREPARANDO' => 'Em preparo',
    'SAIU_ENTREGA' => 'A caminho',
    'ENTREGUE' => 'Entregue',
    'CANCELADO' => 'Cancelado',
    _ => s.replaceAll('_', ' '),
  };

  @override
  Widget build(BuildContext context) {
    final detalhe = _detalhe;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 14.h),
            child: Row(children: [
              const BackArrow(),
              SizedBox(width: 12.w),
              Expanded(child: Text(
                'Pedido #${widget.pedido.id}',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800),
              )),
            ]),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _erro != null
                    ? _estadoErro()
                    : RefreshIndicator(
                        onRefresh: _carregar,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
                          children: [
                            _cartao('STATUS DO PEDIDO', [
                              Text(_status(detalhe!.status),
                                  style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800)),
                              SizedBox(height: 5.h),
                              Text('Recebido em ${_data(detalhe.criadoEm)}',
                                  style: const TextStyle(color: Color(0xFF8B4944), fontSize: 12)),
                            ]),
                            SizedBox(height: 14.h),
                            _cartao('INFORMAÇÕES DO CLIENTE', [
                              _linha(Icons.person_outline, 'Nome', detalhe.clienteNome),
                              const Divider(height: 22),
                              _linha(Icons.phone_outlined, 'Telefone',
                                  detalhe.clienteTelefone?.isNotEmpty == true
                                      ? detalhe.clienteTelefone!
                                      : 'Não informado'),
                            ]),
                            SizedBox(height: 14.h),
                            _cartao('ENDEREÇO DE ENTREGA', [
                              if (detalhe.enderecoEntrega == null)
                                const Text('Endereço não informado')
                              else ...[
                                Text(
                                  '${detalhe.enderecoEntrega!.rua}, ${detalhe.enderecoEntrega!.numero}'
                                  '${(detalhe.enderecoEntrega!.complemento?.isNotEmpty ?? false) ? ' - ${detalhe.enderecoEntrega!.complemento}' : ''}',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '${detalhe.enderecoEntrega!.bairro} · ${detalhe.enderecoEntrega!.cidade}/${detalhe.enderecoEntrega!.estado}',
                                  style: const TextStyle(color: Color(0xFF8B4944), fontSize: 12),
                                ),
                                Text('CEP ${detalhe.enderecoEntrega!.cep}',
                                    style: const TextStyle(color: Color(0xFF8B4944), fontSize: 12)),
                              ],
                            ]),
                            SizedBox(height: 14.h),
                            _cartao('ITENS DO PEDIDO', [
                              if (detalhe.itens.isEmpty)
                                const Text('Nenhum item informado.')
                              else
                                ...detalhe.itens.map((item) => Padding(
                                  padding: EdgeInsets.only(bottom: 12.h),
                                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Container(
                                      width: 38.r, height: 38.r,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF0EF),
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      child: item.imagemUrl == null || item.imagemUrl!.isEmpty
                                          ? const Icon(Icons.fastfood_outlined, color: Color(0xFFFF6961))
                                          : ClipRRect(
                                              borderRadius: BorderRadius.circular(10.r),
                                              child: Image.network(item.imagemUrl!, fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => const Icon(Icons.fastfood_outlined)),
                                            ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text('${item.quantidade}x ${item.nome}',
                                          style: const TextStyle(fontWeight: FontWeight.w700)),
                                      if (item.adicionais.isNotEmpty)
                                        Text(item.adicionais.join(', '),
                                            style: const TextStyle(color: Color(0xFF8B4944), fontSize: 11)),
                                    ])),
                                    Text(_moeda(item.preco * item.quantidade),
                                        style: const TextStyle(fontWeight: FontWeight.w700)),
                                  ]),
                                )),
                              if (detalhe.observacao?.isNotEmpty == true) ...[
                                const Divider(),
                                _linha(Icons.notes_rounded, 'Observação', detalhe.observacao!),
                              ],
                              const Divider(height: 22),
                              _linha(Icons.delivery_dining, 'Taxa de entrega', _moeda(detalhe.taxaFrete)),
                              const Divider(height: 22),
                              _linha(Icons.payments_outlined, 'Total', _moeda(detalhe.valorTotal)),
                            ]),
                            SizedBox(height: 14.h),
                            _cartao('PAGAMENTO', [
                              _linha(Icons.credit_card_outlined, 'Forma', detalhe.formaPagamento),
                              if (detalhe.trocoPara != null) ...[
                                const Divider(height: 22),
                                _linha(Icons.payments_outlined, 'Troco para', _moeda(detalhe.trocoPara!)),
                              ],
                            ]),
                          ],
                        ),
                      ),
          ),
          if (!_carregando && _erro == null && detalhe != null &&
              !['ENTREGUE', 'CANCELADO'].contains(detalhe.status.toUpperCase()))
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6961),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  onPressed: () async {
                    final atualizado = await context.push<bool>(
                      '/update-status',
                      extra: widget.pedido,
                    );
                    if (context.mounted && atualizado == true) {
                      await _carregar();
                      if (context.mounted) context.pop(true);
                    }
                  },
                  child: const Text('Atualizar status do pedido',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _estadoErro() => Center(
    child: Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_outlined, size: 42, color: Color(0xFF8B4944)),
        SizedBox(height: 12.h),
        Text(_erro!, textAlign: TextAlign.center),
        TextButton(onPressed: _carregar, child: const Text('Tentar novamente')),
      ]),
    ),
  );

  Widget _cartao(String titulo, List<Widget> children) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(18.r),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titulo, style: const TextStyle(
        fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1,
        color: Color(0xFF8B4944),
      )),
      SizedBox(height: 14.h),
      ...children,
    ]),
  );

  Widget _linha(IconData icone, String titulo, String valor) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icone, color: const Color(0xFFFF6961), size: 20),
      SizedBox(width: 10.w),
      Expanded(child: Text(titulo,
          style: const TextStyle(color: Color(0xFF8B4944), fontSize: 12))),
      SizedBox(width: 10.w),
      Flexible(child: Text(valor, textAlign: TextAlign.end,
          style: const TextStyle(fontWeight: FontWeight.w700))),
    ],
  );
}
