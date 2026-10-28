import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nhac_lojas/components/app_notification.dart';
import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/container_nhac.dart';

import '../models/pedido_resumo_model.dart';
import '../services/auth_service.dart';
import '../services/pedido_service.dart';

class UpdateOrderStatus extends StatefulWidget {
  final PedidoResumoLojistaModel pedido;

  const UpdateOrderStatus({
    super.key,
    required this.pedido,
  });

  @override
  State<UpdateOrderStatus> createState() => _UpdateOrderStatusState();
}

class _UpdateOrderStatusState extends State<UpdateOrderStatus> {
  final PedidoService _pedidoService = PedidoService();

  String _statusSelecionado = '';

  bool _salvando = false;

  // O lojista só pode atualizar o status do preparo.
  final List<Map<String, String>> _statusDisponiveis = [
    {
      'valor': 'PREPARANDO',
      'titulo': 'Em preparo',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Só seleciona um valor inicial se ele estiver disponível
    // nas opções do dropdown.
    if (widget.pedido.status == 'PREPARANDO') {
      _statusSelecionado = 'PREPARANDO';
    }
  }

  String _formatarStatus(String status) {
    switch (status) {
      case 'PENDENTE':
        return 'Pendente / Confirmar';
      case 'PAGO':
        return 'Pago';
      case 'PREPARANDO':
        return 'Em preparo';
      case 'SAIU_ENTREGA':
        return 'A caminho';
      case 'ENTREGUE':
        return 'Entregue';
      case 'CANCELADO':
        return 'Cancelado';
      default:
        return status;
    }
  }

  Future<void> _salvarStatus() async {
    if (_salvando) return;

    if (_statusSelecionado.isEmpty) {
      showAppNotification(
        context,
        type: NotificationType.error,
        message: 'Selecione o status do preparo.',
      );
      return;
    }

    if (_statusSelecionado == widget.pedido.status) {
      showAppNotification(
        context,
        type: NotificationType.error,
        message: 'O pedido já está nesse status.',
      );
      return;
    }

    // Proteção adicional na interface: o lojista só pode
    // enviar o status PREPARANDO.
    if (_statusSelecionado != 'PREPARANDO') {
      showAppNotification(
        context,
        type: NotificationType.error,
        message: 'Você só pode atualizar o status do preparo.',
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      final token = await AuthService.obterToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Sessão expirada. Faça login novamente.',
        );
      }

      await _pedidoService.atualizarStatus(
        token: token,
        pedidoId: widget.pedido.id,
        status: _statusSelecionado,
      );

      if (!mounted) return;

      showAppNotification(
        context,
        type: NotificationType.success,
        message: 'Pedido atualizado para Em preparo!',
      );

      // Retorna à tela anterior indicando sucesso.
      context.pop(true);
    } catch (e) {
      if (!mounted) return;

      showAppNotification(
        context,
        type: NotificationType.error,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

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
              30.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const BackArrow(),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        'Atualizar preparo',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Resumo do pedido.
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: ContainerNhac(
                    icon: Icons.receipt,
                    corIcone: Colors.redAccent,
                    informacao: widget.pedido.clienteNome,
                    codigo: int.tryParse(widget.pedido.id) ?? 0,
                    quantidadeItens: widget.pedido.quantidadeItens,
                    preco: widget.pedido.valorTotal,
                    situacao: _formatarStatus(widget.pedido.status),
                    exibirCirculoSituacao: false,
                  ),
                ),

                SizedBox(height: 24.h),

                Text(
                  'STATUS ATUAL',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: 8.h),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.pedido.status == 'PREPARANDO'
                            ? Icons.restaurant
                            : Icons.info_outline,
                        color: const Color(0xFF5D201C),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          _formatarStatus(widget.pedido.status),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                Text(
                  'NOVO STATUS DO PREPARO',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),

                SizedBox(height: 12.h),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statusSelecionado.isEmpty
                          ? null
                          : _statusSelecionado,
                      hint: const Text('Selecione o status'),
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(16.r),
                      items: _statusDisponiveis.map((status) {
                        return DropdownMenuItem<String>(
                          value: status['valor']!,
                          child: Text(status['titulo']!),
                        );
                      }).toList(),
                      onChanged: _salvando
                          ? null
                          : (valor) {
                              if (valor == null) return;

                              setState(() {
                                _statusSelecionado = valor;
                              });
                            },
                    ),
                  ),
                ),

                SizedBox(height: 36.h),

                SizedBox(
                  width: double.infinity,
                  child: ButtonNhac(
                    texto: _salvando
                        ? 'Salvando...'
                        : 'Iniciar preparo',
                    onTap: _salvando ? null : _salvarStatus,
                  ),
                ),

                SizedBox(height: 12.h),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _salvando
                        ? null
                        : () => context.pop(),
                    child: const Text('Voltar'),
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