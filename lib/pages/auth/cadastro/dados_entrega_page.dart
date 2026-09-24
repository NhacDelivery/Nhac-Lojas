import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/nhac_input_field.dart';
import 'package:nhac_lojas/components/register_steps.dart';
import 'package:nhac_lojas/models/cadastro_loja.dart';

class DadosEntregaPage extends StatefulWidget {
  final CadastroLoja cadastro;

  const DadosEntregaPage({
    super.key,
    required this.cadastro,
  });

  @override
  State<DadosEntregaPage> createState() => _DadosEntregaPageState();
}

class _DadosEntregaPageState extends State<DadosEntregaPage> {
  late bool entregaPropria;
  late bool retiradaNoLocal;

  late TextEditingController taxaEntregaController;
  late TextEditingController tempoMinController;
  late TextEditingController tempoMaxController;
  late TextEditingController raioEntregaController;

  @override
  void initState() {
    super.initState();

    entregaPropria = widget.cadastro.entregaPropria;
    retiradaNoLocal = widget.cadastro.retiradaNoLocal;

    taxaEntregaController = TextEditingController(
      text: widget.cadastro.taxaEntregaBase == 0
          ? ''
          : widget.cadastro.taxaEntregaBase.toString(),
    );

    tempoMinController = TextEditingController(
      text: widget.cadastro.tempoEntregaMin.toString(),
    );

    tempoMaxController = TextEditingController(
      text: widget.cadastro.tempoEntregaMax.toString(),
    );

    raioEntregaController = TextEditingController(
      text: widget.cadastro.raioEntregaKm?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    taxaEntregaController.dispose();
    tempoMinController.dispose();
    tempoMaxController.dispose();
    raioEntregaController.dispose();

    super.dispose();
  }

  void continuar() {
    widget.cadastro.entregaPropria = entregaPropria;
    widget.cadastro.retiradaNoLocal = retiradaNoLocal;

    widget.cadastro.taxaEntregaBase =
        double.tryParse(
          taxaEntregaController.text
              .trim()
              .replaceAll(',', '.'),
        ) ??
        0;

    widget.cadastro.tempoEntregaMin =
        int.tryParse(tempoMinController.text.trim()) ?? 30;

    widget.cadastro.tempoEntregaMax =
        int.tryParse(tempoMaxController.text.trim()) ?? 45;

    final raio = raioEntregaController.text.trim();

    widget.cadastro.raioEntregaKm =
        raio.isEmpty ? null : double.tryParse(raio.replaceAll(',', '.'));

    context.push(
      '/horario-funcionamento',
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
                  passoAtual: PassoCadastrar.entrega,
                ),

                SizedBox(height: 18.h),

                Text(
                  'Dados da entrega',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'Configure como sua loja irá atender os pedidos.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),

                SizedBox(height: 24.h),

                _buildOpcao(
                  titulo: 'Entrega própria',
                  descricao: 'Minha equipe faz as entregas',
                  icone: Icons.local_shipping_outlined,
                  valor: entregaPropria,
                  onChanged: (valor) {
                    setState(() {
                      entregaPropria = valor;
                    });
                  },
                ),

                if (entregaPropria) ...[
                  SizedBox(height: 20.h),

                  Text(
                    'Configurações da entrega',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  Text(
                    'Taxa de entrega',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  NhacInputField(
                    controller: taxaEntregaController,
                    hintText: 'Ex: 5,99',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tempo mínimo',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 4.h),

                            NhacInputField(
                              controller: tempoMinController,
                              hintText: '30 min',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 12.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tempo máximo',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 4.h),

                            NhacInputField(
                              controller: tempoMaxController,
                              hintText: '45 min',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  Text(
                    'Raio de entrega',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  NhacInputField(
                    controller: raioEntregaController,
                    hintText: 'Ex: 10 km (opcional)',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    'Deixe vazio para não limitar o raio de entrega.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],

                SizedBox(height: 24.h),

                _buildOpcao(
                  titulo: 'Retirada no local',
                  descricao: 'O cliente pode retirar o pedido na loja',
                  icone: Icons.storefront_outlined,
                  valor: retiradaNoLocal,
                  onChanged: (valor) {
                    setState(() {
                      retiradaNoLocal = valor;
                    });
                  },
                ),

                SizedBox(height: 32.h),

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

  Widget _buildOpcao({
    required String titulo,
    required String descricao,
    required IconData icone,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 242, 230),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              icone,
              size: 24.sp,
              color: Colors.redAccent,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4.h),

                Text(
                  descricao,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: valor,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFFFF6961),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
            trackOutlineColor:
                WidgetStateProperty.all(Colors.transparent),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}