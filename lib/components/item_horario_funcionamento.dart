import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ItemHorarioFuncionamento extends StatefulWidget {
  final String diaSemana;
  final String? horarioInicial;
  final bool ativoInicial;
  final ValueChanged<String?> onHorarioChanged;

  const ItemHorarioFuncionamento({
    super.key,
    required this.diaSemana,
    required this.onHorarioChanged,
    this.horarioInicial,
    this.ativoInicial = true,
  });

  @override
  State<ItemHorarioFuncionamento> createState() =>
      _ItemHorarioFuncionamentoState();
}

class _ItemHorarioFuncionamentoState
    extends State<ItemHorarioFuncionamento> {
  late bool ativo;
  late TimeOfDay inicio;
  late TimeOfDay fim;

  @override
  void initState() {
    super.initState();

    ativo = widget.ativoInicial;

    inicio = const TimeOfDay(hour: 8, minute: 0);
    fim = const TimeOfDay(hour: 18, minute: 0);
  }

  String formatarHora(TimeOfDay hora) {
    final horaFormatada = hora.hour.toString().padLeft(2, '0');
    final minutoFormatado = hora.minute.toString().padLeft(2, '0');

    return '$horaFormatada:$minutoFormatado';
  }

  String obterHorario() {
    if (!ativo) {
      return 'Fechado';
    }

    return '${formatarHora(inicio)} - ${formatarHora(fim)}';
  }

  Future<void> selecionarInicio() async {
    final horario = await showTimePicker(
      context: context,
      initialTime: inicio,
    );

    if (horario == null) return;

    setState(() {
      inicio = horario;
    });

    widget.onHorarioChanged(obterHorario());
  }

  Future<void> selecionarFim() async {
    final horario = await showTimePicker(
      context: context,
      initialTime: fim,
    );

    if (horario == null) return;

    setState(() {
      fim = horario;
    });

    widget.onHorarioChanged(obterHorario());
  }

  void alterarAtivo(bool valor) {
    setState(() {
      ativo = valor;
    });

    widget.onHorarioChanged(obterHorario());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 60.w,
                child: Text(
                  widget.diaSemana,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: const Color(0xFF3D1308),
                  ),
                ),
              ),

              const Spacer(),

              Text(
                ativo ? 'Aberto' : 'Fechado',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: ativo
                      ? const Color(0xFFFF6961)
                      : Colors.grey,
                ),
              ),

              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: ativo,
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFFFF6961),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade300,
                  trackOutlineColor:
                      WidgetStateProperty.all(Colors.transparent),
                  onChanged: alterarAtivo,
                ),
              ),
            ],
          ),

          if (ativo) ...[
            SizedBox(height: 8.h),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: selecionarInicio,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Abertura',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            formatarHora(inicio),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: GestureDetector(
                    onTap: selecionarFim,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fechamento',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            formatarHora(fim),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}