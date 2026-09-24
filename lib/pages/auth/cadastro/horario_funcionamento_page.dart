import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/item_horario_funcionamento.dart';
import 'package:nhac_lojas/components/register_steps.dart';
import 'package:nhac_lojas/models/cadastro_loja.dart';

class HorarioFuncionamentoPage extends StatefulWidget {
  final CadastroLoja cadastro;

  const HorarioFuncionamentoPage({
    super.key,
    required this.cadastro,
  });

  @override
  State<HorarioFuncionamentoPage> createState() =>
      _HorarioFuncionamentoPageState();
}

class _HorarioFuncionamentoPageState
    extends State<HorarioFuncionamentoPage> {
  String? domingo;
  String? segunda;
  String? terca;
  String? quarta;
  String? quinta;
  String? sexta;
  String? sabado;

  void continuar() {
    widget.cadastro.domingo = domingo ?? 'Fechado';
    widget.cadastro.segunda = segunda ?? 'Fechado';
    widget.cadastro.terca = terca ?? 'Fechado';
    widget.cadastro.quarta = quarta ?? 'Fechado';
    widget.cadastro.quinta = quinta ?? 'Fechado';
    widget.cadastro.sexta = sexta ?? 'Fechado';
    widget.cadastro.sabado = sabado ?? 'Fechado';

    context.push(
      '/forma-pagamento-cadastro',
      extra: widget.cadastro,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const BackArrow(),
                    SizedBox(width: 12.w),
                    Text(
                      'Cadastrar loja',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                const RegisterSteps(
                  passoAtual: PassoCadastrar.horarios,
                ),

                SizedBox(height: 18.h),

                Text(
                  'Horário de funcionamento',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'Defina os dias e horários em que sua loja recebe pedidos.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),

                SizedBox(height: 18.h),

                ItemHorarioFuncionamento(
                  diaSemana: 'Seg',
                  ativoInicial: true,
                  onHorarioChanged: (horario) {
                    segunda = horario;
                  },
                ),

                const Divider(),

                ItemHorarioFuncionamento(
                  diaSemana: 'Ter',
                  ativoInicial: true,
                  onHorarioChanged: (horario) {
                    terca = horario;
                  },
                ),

                const Divider(),

                ItemHorarioFuncionamento(
                  diaSemana: 'Qua',
                  ativoInicial: true,
                  onHorarioChanged: (horario) {
                    quarta = horario;
                  },
                ),

                const Divider(),

                ItemHorarioFuncionamento(
                  diaSemana: 'Qui',
                  ativoInicial: true,
                  onHorarioChanged: (horario) {
                    quinta = horario;
                  },
                ),

                const Divider(),

                ItemHorarioFuncionamento(
                  diaSemana: 'Sex',
                  ativoInicial: true,
                  onHorarioChanged: (horario) {
                    sexta = horario;
                  },
                ),

                const Divider(),

                ItemHorarioFuncionamento(
                  diaSemana: 'Sáb',
                  ativoInicial: true,
                  onHorarioChanged: (horario) {
                    sabado = horario;
                  },
                ),

                const Divider(),

                ItemHorarioFuncionamento(
                  diaSemana: 'Dom',
                  ativoInicial: false,
                  onHorarioChanged: (horario) {
                    domingo = horario;
                  },
                ),

                SizedBox(height: 24.h),

                ButtonNhac(
                  texto: 'Continuar',
                  onTap: continuar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}