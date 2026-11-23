import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/gestao_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/container_nhac.dart';
import 'package:nhac_lojas/components/filter_tag.dart';
import 'package:nhac_lojas/components/nhac_input_field.dart';

class CriarCupomPage extends StatefulWidget {
  const CriarCupomPage({super.key});

  @override
  State<CriarCupomPage> createState() => _CriarCupomPageState();
}

class _CriarCupomPageState extends State<CriarCupomPage> {
  bool cupomAtivo = true;
  bool salvando = false;
  String tipo = 'Percentual';
  final campos = <String, String>{};
  Future<void> criar() async {
    if (salvando) return;
    setState(() => salvando = true);
    try {
      final datas = DateFormat('dd/MM/yyyy');
      final inicio = datas.parseStrict(campos['inicio'] ?? '');
      final fim = datas.parseStrict(campos['fim'] ?? '');
      final codigo = (campos['codigo'] ?? '').trim().toUpperCase();
      if (!RegExp(r'^[A-Z0-9_-]{3,30}$').hasMatch(codigo))
        throw const FormatException(
          'Use de 3 a 30 letras, números, hífens ou sublinhados no código.',
        );
      final tipos = {
        'Percentual': 'PERCENTUAL',
        'Valor fixo': 'FIXO',
        'Frete grátis': 'FRETE_GRATIS',
      };
      if (!tipos.containsKey(tipo))
        throw const FormatException('Selecione o tipo de desconto.');
      double numero(String campo, String padrao) =>
          double.parse((campos[campo] ?? padrao).trim().replaceAll(',', '.'));
      await GestaoService.requisitar('POST', 'lojista/cupons', {
        'codigo': codigo,
        'tipo': tipos[tipo],
        'descricao': campos['descricao']?.trim(),
        'valor': tipo == 'Frete grátis' ? 0 : numero('valor', ''),
        'minimo': numero('minimo', '0'),
        'inicio': DateFormat('yyyy-MM-dd').format(inicio),
        'fim': DateFormat('yyyy-MM-dd').format(fim),
        'limite': int.parse(campos['limite'] ?? '1'),
        'ativo': cupomAtivo,
      });
      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is FormatException
                  ? 'Confira código, valores, limite e datas (dia/mês/ano).'
                  : e.toString().replaceFirst('Exception: ', ''),
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 26.h, 20.w, 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BackArrow(),
                  SizedBox(width: 12.w),
                  Text(
                    'Criar cupom',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Conteúdo rolável encapsulado com Expanded + SingleChildScrollView
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Código do cupom',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      NhacInputField(
                        onChanged: (v) => campos['codigo'] = v,
                        hintText: 'EX: NHAC20',
                        prefixIcon: Icon(Icons.discount_outlined),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Tipo de desconto',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      ListaFilterTags(
                        filtros: ['Percentual', 'Valor fixo', 'Frete grátis'],
                        initialIndex: 0,
                        onSelected: (v) => setState(() => tipo = v),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Valor do desconto',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                NhacInputField(
                                  onChanged: (v) => campos['valor'] = v,
                                  hintText: '20%',
                                  prefixIcon: Icon(Icons.discount_outlined),
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
                                  'Pedido mínimo',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                NhacInputField(
                                  onChanged: (v) => campos['minimo'] = v,
                                  hintText: 'R\$ 50,00',
                                  prefixIcon: Icon(Icons.discount_outlined),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Descrição (aparece pro cliente)',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      NhacInputField(
                        onChanged: (v) => campos['descricao'] = v,
                        hintText:
                            'Ex: 20% de desconto em pedidos acima de R\$ 50,00',
                        maxLines: 2,
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Válido de',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                NhacInputField(
                                  onChanged: (v) => campos['inicio'] = v,
                                  hintText: '15/11/2026',
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
                                  'Válido até',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                NhacInputField(
                                  onChanged: (v) => campos['fim'] = v,
                                  hintText: '23/11/2026',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Limite de uso por cliente',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      NhacInputField(
                        onChanged: (v) => campos['limite'] = v,
                        hintText: '1 uso por cliente',
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: ContainerNhac(
                          informacao: 'Ativar imediatamente',
                          complemento: 'Cupom já fica disponível pros clientes',
                          ativoInicial: cupomAtivo,
                          exibirSwitch: true,
                          onSwitchChanged: (value) {
                            setState(() {
                              cupomAtivo = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Botão fixo no rodapé
              ButtonNhac(
                texto: salvando ? 'Criando...' : 'Criar cupom',
                onTap: salvando ? null : criar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
