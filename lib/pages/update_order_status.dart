
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nhac_lojas/components/app_notification.dart';
import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/container_nhac.dart';
import 'package:nhac_lojas/components/order_status.dart';

import '../models/pedido_resumo_model.dart';

class UpdateOrderStatus extends StatelessWidget {
  final PedidoResumoLojistaModel pedido;

  const UpdateOrderStatus({
    super.key,
    required this.pedido,
  });

  StatusPedido _converterStatus(String status) {
    switch (status) {
      case 'PENDENTE':
        return StatusPedido.recebido;
      case 'PREPARANDO':
        return StatusPedido.emPreparo;

      // Ajuste estes casos conforme os valores existentes
      // no enum StatusPedido do seu projeto.
      default:
        return StatusPedido.recebido;
    }
  }

  String _formatarStatus(String status) {
    switch (status) {
      case 'PENDENTE':
        return 'Confirmar';
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
              20.h,
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
                        'Atualizar status',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

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
                    informacao: pedido.clienteNome,
                    codigo: int.tryParse(pedido.id) ?? 0,
                    quantidadeItens: pedido.quantidadeItens,
                    preco: pedido.valorTotal,
                    situacao: _formatarStatus(pedido.status),
                    exibirCirculoSituacao: false,
                  ),
                ),

                SizedBox(height: 16.h),

                Text(
                  'ANDAMENTO DO PEDIDO',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),

                SizedBox(height: 12.h),

                OrderStatus(
                  statusAtual: _converterStatus(pedido.status),
                  horarios: {
                    StatusPedido.recebido: '',
                    if (pedido.status == 'PREPARANDO')
                      StatusPedido.emPreparo: '',
                  },
                ),

                SizedBox(height: 48.h),

                ButtonNhac(
                  texto: 'Salvar status',
                  onTap: () {
                    // Ainda não persiste o status na API.
                    // A gravação deverá ser feita pelo serviço
                    // responsável por atualizar o pedido.
                    context.pop();

                    showAppNotification(
                      context,
                      type: NotificationType.success,
                      message: 'Tela fechada. O status ainda não foi salvo na API.',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
