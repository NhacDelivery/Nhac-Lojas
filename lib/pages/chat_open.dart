
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/ballon_chat.dart';
import 'package:nhac_lojas/components/container_nhac.dart';
import 'package:nhac_lojas/components/filter_tag.dart';
import 'package:nhac_lojas/components/icon_container.dart';
import 'package:nhac_lojas/components/search_container.dart';
import 'package:nhac_lojas/services/chat_websocket_service.dart';
import 'package:nhac_lojas/models/conversa_resumo_model.dart';
import 'package:nhac_lojas/models/mensagem_chat_model.dart';
import 'package:nhac_lojas/services/chat_service.dart';
import 'package:nhac_lojas/services/auth_service.dart';

class ChatOpen extends StatefulWidget {
  final ConversaResumoModel conversa;

  const ChatOpen({
    super.key,
    required this.conversa,
  });

  @override
  State<ChatOpen> createState() => _ChatOpenState();
}

class _ChatOpenState extends State<ChatOpen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _mensagemController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MensagemChatModel> _mensagens = [];

  String? _token;
  bool _carregando = true;
  bool _enviando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _inicializarChat();
  }

  Future<void> _inicializarChat() async {
    try {
      final token = await AuthService.obterToken();

      if (token == null || token.isEmpty) {
        throw Exception('Sessão expirada. Entre novamente.');
      }

      _token = token;

      final mensagens = await _chatService.listarMensagens(
        token: token,
        conversaId: widget.conversa.id,
      );

      await _chatService.marcarComoLida(
        token: token,
        conversaId: widget.conversa.id,
      );

      if (!mounted) return;

      setState(() {
        _mensagens = mensagens.reversed.toList();
        _carregando = false;
      });

      _irParaUltimaMensagem();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = e.toString();
        _carregando = false;
      });
    }
  }

  void _irParaUltimaMensagem() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _enviarMensagem() async {
    final conteudo = _mensagemController.text.trim();

    if (conteudo.isEmpty || _enviando) return;

    if (_token == null) {
      _mostrarErro('Sessão expirada. Entre novamente.');
      return;
    }

    // O envio real será conectado ao WebSocket STOMP do backend.
    // Não adicionamos a mensagem à lista antes de confirmar o envio.
    setState(() => _enviando = true);

    try {
      await _enviarViaWebSocket(
        conversaId: widget.conversa.id,
        conteudo: conteudo,
      );

      if (!mounted) return;

      _mensagemController.clear();
    } catch (e) {
      if (!mounted) return;
      _mostrarErro('Não foi possível enviar a mensagem.');
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  Future<void> _enviarViaWebSocket({
    required String conversaId,
    required String conteudo,
  }) async {
    // TODO: integrar com o WebSocket STOMP.
    //
    // O backend informou o destino:
    // /app/conversas/{id}/enviar
    //
    // Ainda precisamos confirmar:
    // - URL do WebSocket;
    // - configuração de autenticação;
    // - formato da resposta/evento recebido.
    throw UnimplementedError(
      'Integração WebSocket ainda não configurada.',
    );
  }

  void _usarRespostaRapida(String texto) {
    _mensagemController.text = texto;
    _mensagemController.selection = TextSelection.collapsed(
      offset: texto.length,
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  String _horario(DateTime? data) {
    if (data == null) return '';

    final local = data.toLocal();
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }

  @override
  void dispose() {
    _mensagemController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversa = widget.conversa;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
          child: Column(
            children: [
              Row(
                children: [
                  const BackArrow(),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ContainerNhac(
                      letrasIcon: _iniciais(conversa.clienteNome),
                      informacao: conversa.clienteNome,
                      complemento: conversa.participanteTipo,
                      formatoIcone: BoxShape.circle,
                    ),
                  ),
                  IconContainer(icon: Icons.more_horiz),
                ],
              ),
              SizedBox(height: 16.h),

              Expanded(
                child: _construirMensagens(),
              ),

              SizedBox(height: 12.h),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _respostaRapida(
                      'Combinado',
                      Icons.chat_bubble_rounded,
                    ),
                    SizedBox(width: 8.w),
                    _respostaRapida(
                      'Pedido a caminho',
                      Icons.chat_bubble_rounded,
                    ),
                    SizedBox(width: 8.w),
                    _respostaRapida(
                      'Vou verificar',
                      Icons.chat_bubble_rounded,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mensagemController,
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _enviarMensagem(),
                      decoration: InputDecoration(
                        hintText: 'Digite uma mensagem...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(
                    width: 48.w,
                    height: 48.w,
                    child: Material(
                      color: Colors.redAccent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _enviando ? null : _enviarMensagem,
                        child: Center(
                          child: _enviando
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirMensagens() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _erro!,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _carregando = true;
                  _erro = null;
                });
                _inicializarChat();
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_mensagens.isEmpty) {
      return const Center(
        child: Text('Nenhuma mensagem nesta conversa.'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: _mensagens.length,
      itemBuilder: (context, index) {
        final mensagem = _mensagens[index];

        // Ajuste o valor conforme o enum RemetenteTipo do backend.
        final ehMinhaMensagem =
            mensagem.remetenteTipo.toUpperCase() == 'LOJISTA';

        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: BallonChat(
            texto: mensagem.conteudo,
            horario: _horario(mensagem.enviadaEm),
            ehMinhaMensagem: ehMinhaMensagem,
          ),
        );
      },
    );
  }

  Widget _respostaRapida(String texto, IconData icone) {
    return ActionChip(
      avatar: Icon(icone, size: 16.sp),
      label: Text(texto),
      onPressed: () => _usarRespostaRapida(texto),
    );
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+'));

    if (partes.isEmpty || partes.first.isEmpty) return 'C';

    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }

    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }
}
