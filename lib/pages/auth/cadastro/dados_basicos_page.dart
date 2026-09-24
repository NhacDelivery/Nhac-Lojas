import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/nhac_input_field.dart';
import 'package:nhac_lojas/components/register_steps.dart';
import 'package:nhac_lojas/models/cadastro_loja.dart';

class DadosBasicosPage extends StatefulWidget {
  const DadosBasicosPage({super.key});

  @override
  State<DadosBasicosPage> createState() => _DadosBasicosState();
}

class _DadosBasicosState extends State<DadosBasicosPage> {
  final TextEditingController nomeController = TextEditingController();final TextEditingController descricaoController = TextEditingController();
  final TextEditingController tipoCulinariaController = TextEditingController();

@override
void dispose() {
  nomeController.dispose();
  descricaoController.dispose();
  tipoCulinariaController.dispose();
  super.dispose();
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
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                const RegisterSteps(passoAtual: PassoCadastrar.dados),
                SizedBox(height: 18.h),
                Text(
                  'Dados básicos',
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Vamos começar com algumas informações sobre sua loja.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 76.w,
                          height: 76.w,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 255, 213, 213),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 24.sp,
                            color: Colors.redAccent,
                          ),
                        ),
                        Positioned(
                          right: 2.w,
                          bottom: 2.h,
                          child: Container(
                            padding: EdgeInsets.all(2.r),
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 231, 229),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(6.r),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add,
                                size: 8.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Foto de perfil',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Logo ou foto da fachada da loja',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                Text(
                  'Nome da loja',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 4.h),

                NhacInputField(
                  hintText: 'Ex: Nhac Burguer',
                  controller: nomeController,
                  ),

                SizedBox(height: 16.h),
                Text(
                  'Descrição da loja',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 4.h),
                
                NhacInputField(
                  hintText: 'Conte um pouco sobre a sua loja...',
                  controller: descricaoController,
                  ),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '0/150',
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                  ),
                ),

                SizedBox(height: 16.h),
                
                Text(
                  'Tipo de estabelecimento',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                
                SizedBox(height: 16.h),
                Text(
                  'Culinária / Categoria',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 4.h),

                NhacInputField(
                  controller: tipoCulinariaController,
                  hintText: 'Selecione',
                  readOnly: true,
                  suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, size: 24.sp),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return ListView(
                          shrinkWrap: true,
                          children: [
                            ListTile(
                              title: const Text('Hamburgueria'),
                              onTap: () {
                                tipoCulinariaController.text = 'Hamburgueria';
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text('Pizzaria'),
                              onTap: () {
                                tipoCulinariaController.text = 'Pizzaria';
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text('Japonesa'),
                              onTap: () {
                                tipoCulinariaController.text = 'Japonesa';
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text('Doceria'),
                              onTap: () {
                                tipoCulinariaController.text = 'Doceria';
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 24.h),
               ButtonNhac(
                  texto: 'Continuar',
                  onTap: () {
                    final cadastro = CadastroLoja();

                    cadastro.nome = nomeController.text.trim();
                    cadastro.descricao = descricaoController.text.trim();
                    cadastro.categoria = tipoCulinariaController.text.trim();

                    context.push(
                      '/endereco-loja',
                      extra: cadastro,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}