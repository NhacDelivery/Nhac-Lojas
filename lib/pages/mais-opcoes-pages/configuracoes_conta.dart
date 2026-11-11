import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/container_nhac.dart';

class ConfiguracoesConta extends StatefulWidget {
  const ConfiguracoesConta({super.key});

  @override
  State<ConfiguracoesConta> createState() => _ConfiguracoesContaState();
}

class _ConfiguracoesContaState extends State<ConfiguracoesConta> {
  bool novosPedidos = true;
  bool mensagensClientes = true;
  bool avaliacoes = true;
  bool novidadesPromocoes = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BackArrow(),
                  SizedBox(width: 12.w),
                  Text(
                    'Configurações da conta',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Text(
                      'Dados de acesso',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 4.w,
                            ),
                            child: ContainerNhac(
                              informacao: 'E-mail',
                              complemento: 'contato@nhacburguer.com',
                              exibirSeta: true,
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 4.w,
                            ),
                            child: ContainerNhac(
                              informacao: 'Telefone',
                              complemento: '(11) 98765-4321',
                              exibirSeta: true,
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 4.w,
                            ),
                            child: ContainerNhac(
                              informacao: 'Senha',
                              complemento: '********',
                              exibirSeta: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h,),
                    Text(
                      'Notificações',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 4.w,
                            ),
                            child: ContainerNhac(
                              informacao: 'Novos pedidos',
                              complemento: 'Alerta sonoro e push',
                              exibirSwitch: true,
                              ativoInicial: novosPedidos,
                              onSwitchChanged: (valor) {
                                setState(() {
                                  novosPedidos = valor;
                                });
                              },
                              onTap: ()=> {
                                setState((){
                                  novosPedidos = !novosPedidos;
                                })
                              },
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 4.w,
                            ),
                            child: ContainerNhac(
                              informacao: 'Mensagens de clientes',
                              complemento: 'Push quando chegar mensagem',
                              exibirSwitch: true,
                              ativoInicial: mensagensClientes,
                              onSwitchChanged: (valor) {
                                setState(() {
                                  mensagensClientes = valor;
                                });
                              },
                              onTap: ()=>{
                                setState(() {
                                  mensagensClientes = !mensagensClientes;
                                })
                              },
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 4.w,
                            ),
                            child: ContainerNhac(
                              informacao: 'Avaliações',
                              complemento: 'Quando receber uma nova avaliação',
                              exibirSwitch: true,
                              ativoInicial: avaliacoes,
                              onSwitchChanged: (valor) {
                                setState(() {
                                  avaliacoes = valor;
                                });
                              },
                              onTap: ()=>{
                                setState(() {
                                  avaliacoes = !avaliacoes;
                                })
                              },
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 4.w,
                            ),
                            child: ContainerNhac(
                              informacao: 'Novidades e promoções Nhac',
                              complemento: 'Comunicados da plataforma',
                              exibirSwitch: true,
                              ativoInicial: novidadesPromocoes,
                              onSwitchChanged: (valor) {
                                setState(() {
                                  novidadesPromocoes = valor;
                                });
                              },
                              onTap: ()=>{
                                setState(() {
                                  novidadesPromocoes = !novidadesPromocoes;
                                })
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}