import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ItemFormaPagamento extends StatefulWidget {
  final IconData icon;
  final String metodo;
  final bool ativoInicial;
  final ValueChanged<bool>? onChanged;

  const ItemFormaPagamento({
    required this.icon,
    required this.metodo,
    this.ativoInicial = true,
    this.onChanged,
    super.key,
  });

  @override
  State<ItemFormaPagamento> createState() => _ItemFormaPagamentoState();
}

class _ItemFormaPagamentoState extends State<ItemFormaPagamento> {
  late bool ativo;

  @override
  void initState() {
    super.initState();
    ativo = widget.ativoInicial;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 242, 230),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(widget.icon, size: 20.sp),
          ),
          Text(
            widget.metodo,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: ativo,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFFFF6961),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              onChanged: (valor) => setState(() => ativo = valor),
            ),
          ),
        ],
      ),
    );
  }
}
