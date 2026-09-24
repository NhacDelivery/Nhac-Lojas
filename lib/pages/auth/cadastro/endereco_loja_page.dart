import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/nhac_input_field.dart';
import 'package:nhac_lojas/components/register_steps.dart';
import 'package:nhac_lojas/models/cadastro_loja.dart';

class EnderecoLojaPage extends StatefulWidget {
  final CadastroLoja cadastro;

  const EnderecoLojaPage({
    super.key,
    required this.cadastro,
  });

  @override
  State<EnderecoLojaPage> createState() => _EnderecoLojaPageState();
}

class _EnderecoLojaPageState extends State<EnderecoLojaPage> {
  late final TextEditingController cepController;
  late final TextEditingController ruaController;
  late final TextEditingController numeroController;
  late final TextEditingController complementoController;
  late final TextEditingController bairroController;
  late final TextEditingController cidadeController;
  late final TextEditingController estadoController;

  @override
  void initState() {
    super.initState();

    cepController = TextEditingController(
      text: widget.cadastro.cep ?? '',
    );

    ruaController = TextEditingController(
      text: widget.cadastro.rua ?? '',
    );

    numeroController = TextEditingController(
      text: widget.cadastro.numero ?? '',
    );

    complementoController = TextEditingController(
      text: widget.cadastro.complemento ?? '',
    );

    bairroController = TextEditingController(
      text: widget.cadastro.bairro ?? '',
    );

    cidadeController = TextEditingController(
      text: widget.cadastro.cidade ?? '',
    );

    estadoController = TextEditingController(
      text: widget.cadastro.estado ?? '',
    );
  }

  @override
  void dispose() {
    cepController.dispose();
    ruaController.dispose();
    numeroController.dispose();
    complementoController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    estadoController.dispose();

    super.dispose();
  }

  void continuar() {
    widget.cadastro.cep = cepController.text.trim();
    widget.cadastro.rua = ruaController.text.trim();
    widget.cadastro.numero = numeroController.text.trim();
    widget.cadastro.complemento = complementoController.text.trim();
    widget.cadastro.bairro = bairroController.text.trim();
    widget.cadastro.cidade = cidadeController.text.trim();
    widget.cadastro.estado = estadoController.text.trim().toUpperCase();

    context.push(
      '/dados-entrega',
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
                  passoAtual: PassoCadastrar.endereco,
                ),

                SizedBox(height: 18.h),

                Text(
                  'Endereço da loja',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'Informe onde sua loja está localizada.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),

                SizedBox(height: 18.h),

                Text(
                  'CEP',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4.h),

                NhacInputField(
                  controller: cepController,
                  hintText: '00000-000',
                  suffixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.redAccent,
                    size: 24.sp,
                  ),
                ),

                SizedBox(height: 16.h),

                Text(
                  'Rua',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4.h),

                NhacInputField(
                  controller: ruaController,
                  hintText: 'Nome da rua',
                ),

                SizedBox(height: 16.h),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Número',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 4.h),

                          NhacInputField(
                            controller: numeroController,
                            hintText: '123',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Complemento',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 4.h),

                          NhacInputField(
                            controller: complementoController,
                            hintText: 'Opcional',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                Text(
                  'Bairro',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4.h),

                NhacInputField(
                  controller: bairroController,
                  hintText: 'Nome do bairro',
                ),

                SizedBox(height: 16.h),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cidade',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 4.h),

                          NhacInputField(
                            controller: cidadeController,
                            hintText: 'Nome da cidade',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UF',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 4.h),

                          NhacInputField(
                            controller: estadoController,
                            hintText: 'UF',
                          ),
                        ],
                      ),
                    ),
                  ],
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

