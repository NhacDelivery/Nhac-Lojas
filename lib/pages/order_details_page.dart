
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/container_nhac.dart';
import 'package:nhac_lojas/components/icon_container.dart';

import '../models/pedido_resumo_model.dart';

class OrderDetailsPage extends StatelessWidget {
  final PedidoResumoLojistaModel pedido;

  const OrderDetailsPage({
    super.key,
    required this.pedido,
  });

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

  Color _corStatus(String status) {
    switch (status) {
      case 'PENDENTE':
        return Colors.orange;
      case 'PAGO':
        return Colors.green;
      case 'PREPARANDO':
        return Colors.blue;
      case 'SAIU_ENTREGA':
        return Colors.deepPurple;
      case 'ENTREGUE':
        return Colors.green;
      case 'CANCELADO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatarHorario(DateTime data) {
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();

    return '$dia/$mes/$ano às ${_formatarHorario(data)}';
  }

  String _formatarValor(dynamic valor) {
    final numero = valor is num
        ? valor.toDouble()
        : double.tryParse(valor.toString()) ?? 0.0;

    return 'R\$ ${numero.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final corStatus = _corStatus(pedido.status);

    return Scaffold(
      body: SingleChildScrollView(
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
              Row(
                children: [
                  const BackArrow(),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Pedido #${pedido.id}',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconContainer(
                    icon: Icons.print_rounded,
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 4.h,
                  horizontal: 10.w,
                ),
                decoration: BoxDecoration(
                  color: corStatus.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  _formatarStatus(pedido.status),
                  style: TextStyle(
                    color: corStatus,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              Text(
                'INFORMAÇÕES DO CLIENTE',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 12.h),

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
                      icon: Icons.person,
                      informacao: pedido.clienteNome,
                    ),

                    SizedBox(height: 8.h),
                    const Divider(
                      color: Color.fromARGB(50, 158, 158, 158),
                    ),
                    SizedBox(height: 8.h),

                    ContainerNhac(
                      icon: Icons.receipt_long,
                      informacao:
                          'Pedido criado em ${_formatarData(pedido.criadoEm)}',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              Text(
                'RESUMO DO PEDIDO',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 12.h),

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
                      informacao: 'Quantidade de itens',
                      quantidadeItens: pedido.quantidadeItens,
                    ),

                    SizedBox(height: 8.h),
                    const Divider(
                      color: Color.fromARGB(50, 158, 158, 158),
                    ),
                    SizedBox(height: 8.h),

                    ContainerNhac(
                      complemento: 'Total do pedido',
                      fontSizeComplemento: 14,
                      preco: pedido.valorTotal,
                      fontSizePreco: 16,
                      precoEmDestaque: true,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              Text(
                'PAGAMENTO',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 14.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: ContainerNhac(
                  icon: Icons.payments_outlined,
                  informacao: _formatarValor(pedido.valorTotal),
                ),
              ),

              SizedBox(height: 16.h),

             ButtonNhac(
              texto: 'Atualizar status',
              onTap: () {
                context.push(
                  '/update-status',
                  extra: pedido,
                );
              },
            ),
            ],
          ),
        ),
      ),
    );
  }
}
