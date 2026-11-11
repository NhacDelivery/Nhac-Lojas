import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/container_nhac.dart';
import 'package:nhac_lojas/models/usuario_model.dart';
import 'package:nhac_lojas/services/auth_service.dart';
import 'package:nhac_lojas/services/usuario_service.dart';

class ConfiguracoesConta extends StatefulWidget {
  const ConfiguracoesConta({super.key});

  @override
  State<ConfiguracoesConta> createState() => _ConfiguracoesContaState();
}

class _ConfiguracoesContaState extends State<ConfiguracoesConta> {
  final UsuarioService _usuarioService = UsuarioService();
  UsuarioModel? _usuario;
  String? _usuarioId;
  String? _erro;
  bool _carregando = true;
  bool _salvando = false;

  Map<String, bool> _preferencias = {
    'notificarNovoPedido': true,
    'notificarMensagens': true,
    'notificarAvaliacoes': false,
    'notificarNovidades': false,
  };

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final id = await AuthService.obterUsuarioId();
      if (id == null || id.isEmpty) {
        throw Exception('Não foi possível identificar a conta autenticada.');
      }
      final resultados = await Future.wait([
        _usuarioService.buscarUsuario(id),
        _usuarioService.buscarPreferenciasNotificacao(id),
      ]);
      if (!mounted) return;
      setState(() {
        _usuarioId = id;
        _usuario = resultados[0] as UsuarioModel;
        _preferencias = resultados[1] as Map<String, bool>;
        _erro = null;
        _carregando = false;
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _erro = erro.toString().replaceFirst('Exception: ', '');
        _carregando = false;
      });
    }
  }

  Future<void> _alternarPreferencia(String chave, bool valor) async {
    final id = _usuarioId;
    if (id == null || _salvando) return;

    final anteriores = Map<String, bool>.from(_preferencias);
    setState(() {
      _preferencias = {..._preferencias, chave: valor};
      _salvando = true;
    });

    try {
      final salvas = await _usuarioService.atualizarPreferenciasNotificacao(
        usuarioId: id,
        preferencias: _preferencias,
      );
      if (!mounted) return;
      setState(() => _preferencias = salvas);
    } catch (erro) {
      if (!mounted) return;
      setState(() => _preferencias = anteriores);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro.toString().replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Widget _itemPreferencia({
    required String chave,
    required String titulo,
    required String descricao,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      child: ContainerNhac(
        informacao: titulo,
        complemento: descricao,
        exibirSwitch: true,
        ativoInicial: _preferencias[chave] ?? false,
        onSwitchChanged: (valor) => _alternarPreferencia(chave, valor),
      ),
    );
  }

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
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: _carregando
                    ? const Center(child: CircularProgressIndicator())
                    : _erro != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_erro!, textAlign: TextAlign.center),
                                SizedBox(height: 12.h),
                                TextButton(
                                  onPressed: () {
                                    setState(() => _carregando = true);
                                    _carregarDados();
                                  },
                                  child: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            physics: const BouncingScrollPhysics(),
                            children: [
                              Text(
                                'Dados de acesso',
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
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
                                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                                      child: ContainerNhac(
                                        informacao: 'E-mail',
                                        complemento: _usuario?.email ?? 'Não informado',
                                      ),
                                    ),
                                    const Divider(),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                                      child: ContainerNhac(
                                        informacao: 'Telefone',
                                        complemento: _usuario?.telefone ?? 'Não informado',
                                      ),
                                    ),
                                    const Divider(),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                                      child: ContainerNhac(
                                        informacao: 'Conta',
                                        complemento: _usuario?.nome ?? 'Não informado',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Row(
                                children: [
                                  Text(
                                    'Notificações',
                                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  if (_salvando)
                                    SizedBox(
                                      width: 14.r,
                                      height: 14.r,
                                      child: const CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                ],
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
                                    _itemPreferencia(
                                      chave: 'notificarNovoPedido',
                                      titulo: 'Novos pedidos',
                                      descricao: 'Alertas de novos pedidos',
                                    ),
                                    const Divider(),
                                    _itemPreferencia(
                                      chave: 'notificarMensagens',
                                      titulo: 'Mensagens de clientes',
                                      descricao: 'Avisos de novas mensagens',
                                    ),
                                    const Divider(),
                                    _itemPreferencia(
                                      chave: 'notificarAvaliacoes',
                                      titulo: 'Avaliações',
                                      descricao: 'Quando receber uma avaliação',
                                    ),
                                    const Divider(),
                                    _itemPreferencia(
                                      chave: 'notificarNovidades',
                                      titulo: 'Novidades e promoções Nhac',
                                      descricao: 'Comunicados da plataforma',
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
