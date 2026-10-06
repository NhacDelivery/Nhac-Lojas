import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nhac_lojas/components/container_nhac.dart';
import 'package:nhac_lojas/components/filter_tag.dart';
import 'package:nhac_lojas/components/icon_container.dart';
import 'package:nhac_lojas/controllers/scroll_shell_controller.dart';
import '../models/pedido_resumo_model.dart';
import '../services/auth_service.dart';
import '../services/pedido_service.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final PedidoService _pedidoService = PedidoService();

  List<PedidoResumoLojistaModel> _pedidos = [];

  bool _carregando = true;
  String? _erro;

  String? _statusSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarPedidos();
  }

  Future<void> _carregarPedidos() async {
    try {
      setState(() {
        _carregando = true;
        _erro = null;
      });

      final token = await AuthService.obterToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Usuário não autenticado.',
        );
      }

      final pedidos =
          await _pedidoService.buscarPedidos(
        token: token,
        status: _statusSelecionado,
      );

      if (!mounted) return;

      setState(() {
        _pedidos = pedidos;
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

  Future<void> _selecionarFiltro(
    String? status,
  ) async {
    setState(() {
      _statusSelecionado = status;
    });

    await _carregarPedidos();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _carregarPedidos,
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
            children: [
              _buildCabecalho(),

              SizedBox(height: 24.h),

              _buildFiltros(),

              SizedBox(height: 24.h),

              _buildConteudo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCabecalho() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Pedidos',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),

        IconContainer(
          icon: Icons.notifications_none_rounded,
        ),
      ],
    );
  }

  Widget _buildFiltros() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFiltro(
            titulo: 'Todos',
            status: null,
          ),

          SizedBox(width: 8.w),

          _buildFiltro(
            titulo: 'Confirmar',
            status: 'PENDENTE',
          ),

          SizedBox(width: 8.w),

          _buildFiltro(
            titulo: 'Em preparo',
            status: 'PREPARANDO',
          ),

          SizedBox(width: 8.w),

          _buildFiltro(
            titulo: 'A caminho',
            status: 'SAIU_ENTREGA',
          ),

          SizedBox(width: 8.w),

          _buildFiltro(
            titulo: 'Entregue',
            status: 'ENTREGUE',
          ),
        ],
      ),
    );
  }

  Widget _buildFiltro({
    required String titulo,
    required String? status,
  }) {
    final selecionado =
        _statusSelecionado == status;

    return GestureDetector(
      onTap: () => _selecionarFiltro(status),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 9.h,
        ),
        decoration: BoxDecoration(
          color: selecionado
              ? Colors.redAccent
              : Colors.white,
          borderRadius:
              BorderRadius.circular(20.r),
          border: Border.all(
            color: selecionado
                ? Colors.redAccent
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          titulo,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: selecionado
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildConteudo() {
    if (_carregando) {
      return Padding(
        padding: EdgeInsets.only(top: 40.h),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_erro != null) {
      return _buildErro();
    }

    if (_pedidos.isEmpty) {
      return _buildSemPedidos();
    }

    return Column(
      children: [
        for (int i = 0; i < _pedidos.length; i++) ...[
          _buildPedido(_pedidos[i]),

          if (i < _pedidos.length - 1)
            SizedBox(height: 12.h),
        ],
      ],
    );
  }

  Widget _buildPedido(
    PedidoResumoLojistaModel pedido,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20.r),
      ),
      child: ContainerNhac(
        codigo: int.tryParse(pedido.id) ?? 0,
        informacao: pedido.clienteNome,
        quantidadeItens:
            pedido.quantidadeItens,
        preco: pedido.valorTotal,
        horario: _formatarHorario(
          pedido.criadoEm,
        ),
        situacao: _formatarStatus(
          pedido.status,
        ),
        onTap: () {
          context.push(
            '/order-details',
            extra: pedido.id,
          );
        },
      ),
    );
  }

  Widget _buildErro() {
    return Padding(
      padding: EdgeInsets.only(top: 30.h),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 45.sp,
          ),

          SizedBox(height: 12.h),

          Text(
            'Não foi possível carregar os pedidos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            _erro ?? 'Erro desconhecido.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey,
            ),
          ),

          SizedBox(height: 16.h),

          ElevatedButton(
            onPressed: _carregarPedidos,
            child: const Text(
              'Tentar novamente',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemPedidos() {
    return Padding(
      padding: EdgeInsets.only(top: 40.h),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 50.sp,
            color: Colors.grey,
          ),

          SizedBox(height: 12.h),

          Text(
            'Nenhum pedido encontrado.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatarStatus(
    String status,
  ) {
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

  String _formatarHorario(
    DateTime data,
  ) {
    final hora = data.hour
        .toString()
        .padLeft(2, '0');

    final minuto = data.minute
        .toString()
        .padLeft(2, '0');

    return '$hora:$minuto';
  }
}