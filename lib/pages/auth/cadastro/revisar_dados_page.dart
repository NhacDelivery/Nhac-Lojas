import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/container_card_revisao.dart';
import 'package:nhac_lojas/components/filter_tag.dart';
import 'package:nhac_lojas/components/register_steps.dart';
import 'package:nhac_lojas/models/cadastro_loja.dart';

class RevisarDadosPage extends StatelessWidget {
  final CadastroLoja cadastro;

  const RevisarDadosPage({
    super.key,
    required this.cadastro,
  });
  
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
                const RegisterSteps(passoAtual: PassoCadastrar.revisar),
                SizedBox(height: 18.h),
                Text(
                  'Revise os dados da loja',
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
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
                              color: Color.fromARGB(255, 255, 213, 213),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 24.sp,
                              color: Colors.redAccent,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nhac Burguer',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Restaurante · Hamburgueria',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Os melhores hambúrgueres artesanais da região, feitos na hora com ingredientes frescos.',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rua das Flores, 123',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Centro · São Paulo - SP',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'CEP 01310-100',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                      ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tipo',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            'Entrega própria',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
                    children: const [
                      ListaFilterTags(
                        filtros: ['Dinheiro', 'Crédito', 'Débito', 'Pix']
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Seg a Sex',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            '08:00 - 18:00',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sábado',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            '10:00 - 22:00',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Domingo',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            'Fechado',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                ButtonNhac(
                  texto: 'Finalizar cadastro',
                  onTap: () => context.go('/loja-cadastrada'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}