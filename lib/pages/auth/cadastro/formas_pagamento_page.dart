import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/item_forma_pagamento.dart';
import 'package:nhac_lojas/components/register_steps.dart';
import 'package:nhac_lojas/models/cadastro_loja.dart';

class FormasPagamentoPage extends StatefulWidget {
  final CadastroLoja cadastro;

  const FormasPagamentoPage({
    super.key,
    required this.cadastro,
  });

  @override
  State<FormasPagamentoPage> createState() =>
      _FormasPagamentoPageState();
}

class _FormasPagamentoPageState extends State<FormasPagamentoPage> {
  late bool aceitaDinheiro;
  late bool aceitaCredito;
  late bool aceitaDebito;
  late bool aceitaPix;
  late bool aceitaValeRefeicao;
  late bool aceitaValeAlimentacao;

  @override
  void initState() {
    super.initState();

    aceitaDinheiro = widget.cadastro.aceitaDinheiro;
    aceitaCredito = widget.cadastro.aceitaCredito;
    aceitaDebito = widget.cadastro.aceitaDebito;
    aceitaPix = widget.cadastro.aceitaPix;
    aceitaValeRefeicao =
        widget.cadastro.aceitaValeRefeicao;
    aceitaValeAlimentacao =
        widget.cadastro.aceitaValeAlimentacao;
  }

  void continuar() {
    // Salva as escolhas na model.
    widget.cadastro.aceitaDinheiro = aceitaDinheiro;
    widget.cadastro.aceitaCredito = aceitaCredito;
    widget.cadastro.aceitaDebito = aceitaDebito;
    widget.cadastro.aceitaPix = aceitaPix;
    widget.cadastro.aceitaValeRefeicao =
        aceitaValeRefeicao;
    widget.cadastro.aceitaValeAlimentacao =
        aceitaValeAlimentacao;

    // Continua levando o MESMO CadastroLoja.
    context.push(
      '/revisar-dados',
      extra: widget.cadastro,
    );
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
                // CABEÇALHO
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

                // ETAPAS
                const RegisterSteps(
                  passoAtual: PassoCadastrar.pagamento,
                ),

                SizedBox(height: 18.h),

                // TÍTULO
                Text(
                  'Formas de pagamento',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'Selecione as formas de pagamento que sua loja aceita.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),

                SizedBox(height: 18.h),

                // DINHEIRO
                ItemFormaPagamento(
                  icon: Icons.money_outlined,
                  metodo: 'Dinheiro',
                  ativoInicial: aceitaDinheiro,
                  onChanged: (valor) {
                    setState(() {
                      aceitaDinheiro = valor;
                    });
                  },
                ),

                const Divider(),

                // CRÉDITO
                ItemFormaPagamento(
                  icon: Icons.credit_card,
                  metodo: 'Cartão de crédito',
                  ativoInicial: aceitaCredito,
                  onChanged: (valor) {
                    setState(() {
                      aceitaCredito = valor;
                    });
                  },
                ),

                const Divider(),

                // DÉBITO
                ItemFormaPagamento(
                  icon: Icons.credit_card,
                  metodo: 'Cartão de débito',
                  ativoInicial: aceitaDebito,
                  onChanged: (valor) {
                    setState(() {
                      aceitaDebito = valor;
                    });
                  },
                ),

                const Divider(),

                // PIX
                ItemFormaPagamento(
                  icon: Icons.bolt_outlined,
                  metodo: 'Pix',
                  ativoInicial: aceitaPix,
                  onChanged: (valor) {
                    setState(() {
                      aceitaPix = valor;
                    });
                  },
                ),

                const Divider(),

                // VALE REFEIÇÃO
                ItemFormaPagamento(
                  icon: Icons.money_outlined,
                  metodo: 'Vale refeição',
                  ativoInicial: aceitaValeRefeicao,
                  onChanged: (valor) {
                    setState(() {
                      aceitaValeRefeicao = valor;
                    });
                  },
                ),

                const Divider(),

                // VALE ALIMENTAÇÃO
                ItemFormaPagamento(
                  icon: Icons.money_outlined,
                  metodo: 'Vale alimentação',
                  ativoInicial: aceitaValeAlimentacao,
                  onChanged: (valor) {
                    setState(() {
                      aceitaValeAlimentacao = valor;
                    });
                  },
                ),

                SizedBox(height: 24.h),

                // CONTINUAR
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