import 'package:flutter/material.dart';
import '../../services/gestao_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/filter_tag.dart';

class CupomPage extends StatefulWidget {
  const CupomPage({super.key});

  @override
  State<CupomPage> createState() => _CupomPageState();
}

class _CupomPageState extends State<CupomPage> {
  late Future<List<dynamic>> cupons;
  String filtro = '';
  final alterando = <String>{};
  @override
  void initState() {
    super.initState();
    cupons = carregar();
  }

  Future<List<dynamic>> carregar() async =>
      (await GestaoService.requisitar('GET', 'lojista/cupons')) as List;
  void atualizar() => setState(() => cupons = carregar());
  Future<void> alterar(String id, bool ativo) async {
    if (!alterando.add(id)) return;
    try {
      await GestaoService.requisitar(
        'PATCH',
        'lojista/cupons/${Uri.encodeComponent(id)}',
        {'ativo': ativo},
      );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      alterando.remove(id);
      if (mounted) atualizar();
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
                    'Cupons e promoções',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Conteúdo rolável encapsulado
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListaFilterTags(
                        filtros: const ['Ativos', 'Agendados', 'Encerrados'],
                        onSelected: (v) => setState(() => filtro = v),
                      ),
                      FutureBuilder<List<dynamic>>(
                        future: cupons,
                        builder: (context, snapshot) {
                          if (snapshot.hasError)
                            return TextButton(
                              onPressed: atualizar,
                              child: const Text(
                                'Não foi possível carregar. Tentar novamente',
                              ),
                            );
                          if (snapshot.connectionState != ConnectionState.done)
                            return const CircularProgressIndicator();
                          final hoje = DateUtils.dateOnly(DateTime.now());
                          final lista = snapshot.data!.where((c) {
                            if (filtro.isEmpty) return true;
                            if (c['ativo'] != true ||
                                DateTime.parse(c['fim']).isBefore(hoje)) {
                              return filtro == 'Encerrados';
                            }
                            if (DateTime.parse(c['inicio']).isAfter(hoje))
                              return filtro == 'Agendados';
                            return filtro == 'Ativos';
                          }).toList();
                          if (lista.isEmpty)
                            return const Padding(
                              padding: EdgeInsets.all(24),
                              child: Text('Nenhum cupom neste filtro.'),
                            );
                          return Column(
                            children: [
                              for (final c in lista)
                                SwitchListTile(
                                  title: Text(c['codigo']),
                                  subtitle: Text(
                                    '${c['inicio']} a ${c['fim']} · mínimo R\$ ${c['minimo']}',
                                  ),
                                  value: c['ativo'] == true,
                                  onChanged: (v) => alterar(c['id'], v),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Botão fixo no rodapé
              ButtonNhac(
                texto: 'Criar cupom',
                onTap: () async {
                  if (await context.push<bool>('/criar-cupom') == true &&
                      mounted)
                    atualizar();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
