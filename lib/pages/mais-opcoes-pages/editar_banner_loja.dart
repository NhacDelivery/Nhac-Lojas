import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/seletor_banner_loja.dart';
import 'package:nhac_lojas/models/loja_model.dart';
import 'package:nhac_lojas/services/auth_service.dart';
import 'package:nhac_lojas/services/loja_service.dart';
import 'package:nhac_lojas/services/upload_service.dart';

class EditarBannerLoja extends StatefulWidget {
  const EditarBannerLoja({super.key});

  @override
  State<EditarBannerLoja> createState() => _EditarBannerLojaState();
}

class _EditarBannerLojaState extends State<EditarBannerLoja> {
  final _lojaService = LojaService();
  late Future<LojaModel> _consulta;
  File? _arquivo;
  String? _urlEnviada;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _consulta = _carregarLoja();
  }

  Future<String> _obterToken() async {
    final token = await AuthService.obterToken();
    if (token == null || token.isEmpty) {
      throw Exception('Entre na sua conta para alterar o banner.');
    }
    return token;
  }

  Future<LojaModel> _carregarLoja() async {
    return _lojaService.buscarMinhaLoja(await _obterToken());
  }

  Future<void> _salvar(LojaModel loja) async {
    final arquivo = _arquivo;
    if (arquivo == null || _salvando) return;

    setState(() => _salvando = true);
    try {
      final token = await _obterToken();
      final url = _urlEnviada ??= await UploadService().enviarImagem(
        arquivo: arquivo,
        token: token,
      );
      final atualizada = await _lojaService.atualizarBanner(
        lojaId: loja.id,
        bannerUrl: url,
        token: token,
      );
      if (!mounted) return;

      setState(() {
        _consulta = Future.value(atualizada);
        _arquivo = null;
        _urlEnviada = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner da loja atualizado.')),
      );
    } catch (erro) {
      if (!mounted) return;
      final mensagem = erro is Exception
          ? erro.toString().replaceFirst('Exception: ', '')
          : 'Não foi possível salvar o banner. Tente novamente.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensagem)));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackArrow(),
        title: const Text('Personalização da loja'),
      ),
      body: SafeArea(
        child: FutureBuilder<LojaModel>(
          future: _consulta,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final loja = snapshot.data;
            if (loja == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Não foi possível carregar o banner da loja.'),
                    TextButton(
                      onPressed: () =>
                          setState(() => _consulta = _carregarLoja()),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: EdgeInsets.all(20.r),
              children: [
                SeletorBannerLoja(
                  arquivo: _arquivo,
                  url: loja.bannerUrl,
                  onChanged: _salvando
                      ? null
                      : (arquivo) => setState(() {
                          _arquivo = arquivo;
                          _urlEnviada = null;
                        }),
                ),
                SizedBox(height: 16.h),
                ButtonNhac(
                  texto: _salvando ? 'Salvando...' : 'Salvar banner',
                  onTap: _arquivo == null || _salvando
                      ? null
                      : () => _salvar(loja),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
