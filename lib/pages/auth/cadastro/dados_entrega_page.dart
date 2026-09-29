import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const _corPrincipal = Color(0xFFFF6961);
  static const _tempoMinPadrao = 30;
  static const _tempoMaxPadrao = 45;

  late bool entregaPropria;
  late bool retiradaNoLocal;

  late final TextEditingController taxaEntregaController;
  late final TextEditingController tempoMinController;
  late final TextEditingController tempoMaxController;
  late final TextEditingController raioEntregaController;

  // Aceita números com vírgula ou ponto, no máximo 2 casas decimais
  final _decimalFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}'));
  final _inteiroFormatter = FilteringTextInputFormatter.digitsOnly;

  @override
  void initState() {
    super.initState();

    final c = widget.cadastro;

    entregaPropria = c.entregaPropria;
    retiradaNoLocal = c.retiradaNoLocal;

    final taxa = c.taxaEntregaBase;
    taxaEntregaController = TextEditingController(
      text: (taxa == null || taxa == 0)
          ? ''
          : taxa.toStringAsFixed(2).replaceAll('.', ','),
    );

    tempoMinController = TextEditingController(
      text: (c.tempoEntregaMin ?? _tempoMinPadrao).toString(),
    );

    tempoMaxController = TextEditingController(
      text: (c.tempoEntregaMax ?? _tempoMaxPadrao).toString(),
    );

    raioEntregaController = TextEditingController(
      text: c.raioEntregaKm?.toString() ?? '',
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

  void _erro(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  double? _parseDecimal(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.'));

  void continuar() {
    FocusScope.of(context).unfocus();

    if (!entregaPropria && !retiradaNoLocal) {
      _erro('Selecione ao menos uma forma de atendimento.');
      return;
    }

    final c = widget.cadastro;

    if (entregaPropria) {
      final taxaTexto = taxaEntregaController.text.trim();
      final taxa = taxaTexto.isEmpty ? 0.0 : _parseDecimal(taxaTexto);
      if (taxa == null || taxa < 0) {
        _erro('Informe uma taxa de entrega válida.');
        return;
      }

      final min = int.tryParse(tempoMinController.text.trim()) ??
          _tempoMinPadrao;
      final max = int.tryParse(tempoMaxController.text.trim()) ??
          _tempoMaxPadrao;

      if (min <= 0 || max <= 0) {
        _erro('Os tempos de entrega devem ser maiores que zero.');
        return;
      }
      if (min > max) {
        _erro('O tempo mínimo não pode ser maior que o máximo.');
        return;
      }

      final raioTexto = raioEntregaController.text.trim();
      double? raio;
      if (raioTexto.isNotEmpty) {
        raio = _parseDecimal(raioTexto);
        if (raio == null || raio <= 0) {
          _erro('Informe um raio de entrega válido ou deixe vazio.');
          return;
        }
      }

      c.taxaEntregaBase = taxa;
      c.tempoEntregaMin = min;
      c.tempoEntregaMax = max;
      c.raioEntregaKm = raio;
    } else {
      // Sem entrega própria: não envia valores digitados antes
      c.taxaEntregaBase = 0;
      c.tempoEntregaMin = _tempoMinPadrao;
      c.tempoEntregaMax = _tempoMaxPadrao;
      c.raioEntregaKm = null;
    }

    c.entregaPropria = entregaPropria;
    c.retiradaNoLocal = retiradaNoLocal;

    context.push(
      '/horario-funcionamento',
      extra: c,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                  const RegisterSteps(passoAtual: PassoCadastrar.entrega),
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
                    onChanged: (v) => setState(() => entregaPropria = v),
                  ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: entregaPropria
                        ? _buildConfiguracoesEntrega()
                        : const SizedBox(width: double.infinity),
                  ),

                  SizedBox(height: 16.h),

                  _buildOpcao(
                    titulo: 'Retirada no local',
                    descricao: 'O cliente pode retirar o pedido na loja',
                    icone: Icons.storefront_outlined,
                    valor: retiradaNoLocal,
                    onChanged: (v) => setState(() => retiradaNoLocal = v),
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
      ),
    );
  }

  Widget _buildConfiguracoesEntrega() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Text(
          'Configurações da entrega',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),

        _label('Taxa de entrega (R\$)'),
        SizedBox(height: 4.h),
        NhacInputField(
          controller: taxaEntregaController,
          hintText: 'Ex: 5,99 (vazio = entrega grátis)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [_decimalFormatter],
        ),

        SizedBox(height: 16.h),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Tempo mín. (min)'),
                  SizedBox(height: 4.h),
                  NhacInputField(
                    controller: tempoMinController,
                    hintText: '30',
                    keyboardType: TextInputType.number,
                    inputFormatters: [_inteiroFormatter],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Tempo máx. (min)'),
                  SizedBox(height: 4.h),
                  NhacInputField(
                    controller: tempoMaxController,
                    hintText: '45',
                    keyboardType: TextInputType.number,
                    inputFormatters: [_inteiroFormatter],
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        _label('Raio de entrega (km)'),
        SizedBox(height: 4.h),
        NhacInputField(
          controller: raioEntregaController,
          hintText: 'Ex: 10 (opcional)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [_decimalFormatter],
        ),
        SizedBox(height: 8.h),
        Text(
          'Deixe vazio para não limitar o raio de entrega.',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _label(String texto) {
    return Text(
      texto,
      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildOpcao({
    required String titulo,
    required String descricao,
    required IconData icone,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: valor ? _corPrincipal : Colors.grey.shade200,
            width: valor ? 1.5 : 1,
          ),
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
              child: Icon(icone, size: 24.sp, color: Colors.redAccent),
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
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Switch(
              value: valor,
              activeThumbColor: Colors.white,
              activeTrackColor: _corPrincipal,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}