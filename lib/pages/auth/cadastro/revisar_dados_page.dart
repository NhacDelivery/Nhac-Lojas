import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/container_card_revisao.dart';
import 'package:nhac_lojas/components/filter_tag.dart';
import 'package:nhac_lojas/components/register_steps.dart';
import 'package:nhac_lojas/models/cadastro_loja.dart';
import 'package:nhac_lojas/services/auth_service.dart';
import '../../../services/loja_service.dart';

class RevisarDadosPage extends StatefulWidget {
  final CadastroLoja cadastro;

  const RevisarDadosPage({
    super.key,
    required this.cadastro,
  });

  @override
  State<RevisarDadosPage> createState() => _RevisarDadosPageState();
}

class _RevisarDadosPageState extends State<RevisarDadosPage> {
  final LojaService _lojaService = LojaService();

  bool _carregando = false;

  Future<void> finalizarCadastro() async {
    if (_carregando) return;

    setState(() {
      _carregando = true;
    });

    try {

      final token = await AuthService.obterToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Sua sessão expirou. Faça login novamente.',
        );
      }

      print('🔐 Token encontrado.');
      print('➡️ Enviando cadastro da loja...');

      

      await _lojaService.criarLoja(
        cadastro: widget.cadastro,
        token: token,
      );

      
      if (!mounted) return;

      context.go('/loja-cadastrada');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _carregando = false;
      });
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
                  passoAtual: PassoCadastrar.revisar,
                ),

                SizedBox(height: 18.h),

                Text(
                  'Revise os dados da loja',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'Confirme as informações antes de finalizar seu cadastro.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),

                SizedBox(height: 18.h),

                ContainerCardRevisao(
                  title: 'Dados básicos',
                  onEdit: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64.w,
                            height: 64.w,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(
                                255,
                                255,
                                213,
                                213,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 24.sp,
                              color: Colors.redAccent,
                            ),
                          ),

                          SizedBox(width: 12.w),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.cadastro.nome ?? '',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Text(
                                  widget.cadastro.categoria ?? '',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      Text(
                        widget.cadastro.descricao ?? '',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 18.h),

                ContainerCardRevisao(
                  title: 'Endereço',
                  onEdit: () {},
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.cadastro.rua ?? ''}, '
                        '${widget.cadastro.numero ?? ''}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        '${widget.cadastro.bairro ?? ''} · '
                        '${widget.cadastro.cidade ?? ''} - '
                        '${widget.cadastro.estado ?? ''}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        'CEP ${widget.cadastro.cep ?? ''}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                      ),

                      if ((widget.cadastro.complemento ?? '')
                          .isNotEmpty) ...[
                        SizedBox(height: 4.h),

                        Text(
                          widget.cadastro.complemento!,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 18.h),

                ContainerCardRevisao(
                  title: 'Entrega',
                  onEdit: () {},
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tipo',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),

                          Text(
                            widget.cadastro.entregaPropria
                                ? 'Entrega própria'
                                : 'Retirada no local',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      if (widget.cadastro.entregaPropria) ...[
                        SizedBox(height: 8.h),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Retirada no local',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.sp,
                              ),
                            ),

                            Text(
                              widget.cadastro.retiradaNoLocal
                                  ? 'Sim'
                                  : 'Não',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 18.h),

                ContainerCardRevisao(
                  title: 'Pagamento',
                  onEdit: () {},
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      if (widget.cadastro.aceitaDinheiro)
                        const ListaFilterTags(
                          filtros: ['Dinheiro'],
                        ),

                      if (widget.cadastro.aceitaCredito)
                        const ListaFilterTags(
                          filtros: ['Crédito'],
                        ),

                      if (widget.cadastro.aceitaDebito)
                        const ListaFilterTags(
                          filtros: ['Débito'],
                        ),

                      if (widget.cadastro.aceitaPix)
                        const ListaFilterTags(
                          filtros: ['Pix'],
                        ),

                      if (widget.cadastro.aceitaValeRefeicao)
                        const ListaFilterTags(
                          filtros: ['Vale refeição'],
                        ),

                      if (widget.cadastro.aceitaValeAlimentacao)
                        const ListaFilterTags(
                          filtros: ['Vale alimentação'],
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 18.h),

                ContainerCardRevisao(
                  title: 'Horários',
                  onEdit: () {},
                  child: Column(
                    children: [
                      _HorarioRow(
                        dia: 'Domingo',
                        horario:
                            widget.cadastro.domingo ?? 'Fechado',
                      ),

                      SizedBox(height: 4.h),

                      _HorarioRow(
                        dia: 'Segunda',
                        horario:
                            widget.cadastro.segunda ?? 'Fechado',
                      ),

                      SizedBox(height: 4.h),

                      _HorarioRow(
                        dia: 'Terça',
                        horario:
                            widget.cadastro.terca ?? 'Fechado',
                      ),

                      SizedBox(height: 4.h),

                      _HorarioRow(
                        dia: 'Quarta',
                        horario:
                            widget.cadastro.quarta ?? 'Fechado',
                      ),

                      SizedBox(height: 4.h),

                      _HorarioRow(
                        dia: 'Quinta',
                        horario:
                            widget.cadastro.quinta ?? 'Fechado',
                      ),

                      SizedBox(height: 4.h),

                      _HorarioRow(
                        dia: 'Sexta',
                        horario:
                            widget.cadastro.sexta ?? 'Fechado',
                      ),

                      SizedBox(height: 4.h),

                      _HorarioRow(
                        dia: 'Sábado',
                        horario:
                            widget.cadastro.sabado ?? 'Fechado',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),
                ButtonNhac(
                  texto: _carregando
                      ? 'Cadastrando...'
                      : 'Finalizar cadastro',
                  onTap: _carregando
                      ? null
                      : finalizarCadastro,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HorarioRow extends StatelessWidget {
  final String dia;
  final String horario;

  const _HorarioRow({
    required this.dia,
    required this.horario,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          dia,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14.sp,
          ),
        ),

        Flexible(
          child: Text(
            horario,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
