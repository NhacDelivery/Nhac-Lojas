// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:nhac_lojas/components/app_notification.dart';
// import 'package:nhac_lojas/components/back_arrow.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:nhac_lojas/components/button_nhac.dart';
// import 'package:nhac_lojas/components/container_nhac.dart';
// import 'package:nhac_lojas/components/item_horario_funcionamento.dart';

// class HorarioEdicaoPage extends StatefulWidget {
//   const HorarioEdicaoPage({super.key});

//   @override
//   State<HorarioEdicaoPage> createState() => _HorarioEdicaoPageState();
// }

// class _HorarioEdicaoPageState extends State<HorarioEdicaoPage> {
//   bool lojaAberta = true;
//   String statusLoja = 'Loja aberta';
//   String complementoStatusLoja = 'Aberta para receber pedidos';

//   void _alterarStatusLoja(BuildContext context) {
//     if (lojaAberta) {
//       statusLoja = 'Loja aberta';
//       complementoStatusLoja = 'Aberta para receber pedidos';
//     } else {
//       statusLoja = 'Loja fechada';
//       complementoStatusLoja = 'Não recebe pedidos';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.fromLTRB(20.w, 26.h, 20.w, 30.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   const BackArrow(),
//                   SizedBox(width: 12.w),
//                   Text(
//                     'Horário de funcionamento',
//                     style: TextStyle(
//                       fontSize: 20.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 24.h),
              
//               // Conteúdo rolável encapsulado
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.all(16.r),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20.r),
//                         ),
//                         child: Column(
//                           children: [
//                             ContainerNhac(
//                               icon: Icons.store_outlined,
//                               informacao: statusLoja,
//                               complemento: complementoStatusLoja,
//                               exibirSwitch: true,
//                               ativoInicial: lojaAberta,
//                               onSwitchChanged: (valor) {
//                                 setState(() {
//                                   lojaAberta = valor;
//                                   _alterarStatusLoja(context);
//                                 });
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 16.h),
//                       Text(
//                         'HORÁRIOS',
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 8.h),
//                       Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.all(16.r),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20.r),
//                         ),
//                         child: Column(
//                           children: [
//                             const ItemHorarioFuncionamento(
//                               diaSemana: 'Seg',
//                               horario: '08:00 - 18:00',
//                               ativoInicial: true,
//                             ),
//                             const Divider(),
//                             const ItemHorarioFuncionamento(
//                               diaSemana: 'Ter',
//                               horario: '08:00 - 18:00',
//                               ativoInicial: true,
//                             ),
//                             const Divider(),
//                             const ItemHorarioFuncionamento(
//                               diaSemana: 'Qua',
//                               horario: '08:00 - 18:00',
//                               ativoInicial: true,
//                             ),
//                             const Divider(),
//                             const ItemHorarioFuncionamento(
//                               diaSemana: 'Qui',
//                               horario: '08:00 - 18:00',
//                               ativoInicial: true,
//                             ),
//                             const Divider(),
//                             const ItemHorarioFuncionamento(
//                               diaSemana: 'Sex',
//                               horario: '08:00 - 22:00',
//                               ativoInicial: true,
//                             ),
//                             const Divider(),
//                             const ItemHorarioFuncionamento(
//                               diaSemana: 'Sáb',
//                               horario: '10:00 - 22:00',
//                               ativoInicial: true,
//                             ),
//                             const Divider(),
//                             const ItemHorarioFuncionamento(
//                               diaSemana: 'Dom',
//                               horario: 'Fechado',
//                               ativoInicial: false,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
              
//               SizedBox(height: 16.h),
              
//               // Botão fixo no rodapé
//               ButtonNhac(
//                 texto: 'Salvar alterações',
//                 onTap: () {
//                   context.pop();
//                   showAppNotification(
//                     context,
//                     type: NotificationType.success,
//                     message: 'Informações alteradas!',
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }