import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/container_nhac.dart';
import 'package:nhac_lojas/components/icon_container.dart';

import 'package:nhac_lojas/services/chat_websocket_service.dart';
import 'package:nhac_lojas/models/conversa_resumo_model.dart';
import 'package:nhac_lojas/models/mensagem_chat_model.dart';
import 'package:nhac_lojas/services/chat_service.dart';
import 'package:nhac_lojas/services/auth_service.dart';

class ChatOpen extends StatefulWidget {
  final ConversaResumoModel conversa;

  const ChatOpen({super.key, required this.conversa});

  @override
  State<ChatOpen> createState() => _ChatOpenState();
}

class _ChatOpenState extends State<ChatOpen> {
  static const int _tamanhoPagina = 30;

  final ChatService _chatService = ChatService();
  final ChatWebSocketService _webSocketService = ChatWebSocketService();
  final TextEditingController _mensagemController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<MensagemChatModel> _mensagens = [];

  String? _token;

  bool _carregando = true;
  bool _enviando = false;
  bool _conectando = false;
  String? _erro;

  // Paginação do histórico.
  int _paginaHistorico = 0;
  bool _temMensagensAntigas = true;
  bool _carregandoAntigas = false;

  @override
  void initState() {
    super.initState();
    _inicializarChat();
  }

  // INICIALIZA O CHAT.
  Future<void> _inicializarChat() async {
    try {
      setState(() {
        _carregando = true;
        _erro = null;
      });

      final token = await AuthService.obterToken();
      if (token == null || token.isEmpty) {
        throw Exception('Sessão expirada. Entre novamente.');
      }
      _token = token;

      final historico = await _chatService.listarMensagens(
        token: token,
        conversaId: widget.conversa.id,
      );

      if (!mounted) return;

      setState(() {
        _mensagens
          ..clear()
          ..addAll(historico.reversed);
        _paginaHistorico = 1;
        _temMensagensAntigas = historico.length >= _tamanhoPagina;
        _carregando = false;
      });

      _irParaUltimaMensagem();

      await _chatService.marcarComoLida(
        token: token,
        conversaId: widget.conversa.id,
      );

      if (!mounted) return;
      await _conectarWebSocket();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.toString().replaceAll('Exception: ', '');
        _carregando = false;
      });
    }
  }

  // CONECTA AO WEBSOCKET.
  Future<void> _conectarWebSocket() async {
    if (_token == null || _conectando) return;

    setState(() => _conectando = true);

    try {
      await _webSocketService.conectar(
        token: _token!,
        conversaId: widget.conversa.id,
        aoReceberMensagem: _aoReceberMensagem,
        aoReceberErro: (erro) => _mostrarErro(erro),
      );

      // Ao (re)conectar, busca o que pode ter chegado enquanto estava offline.
      await _atualizarHistorico();
    } catch (e) {
      _mostrarErro(
        'Não foi possível conectar ao chat. '
        'Verifique sua conexão e tente novamente.',
      );
    } finally {
      if (mounted) setState(() => _conectando = false);
    }
  }

  // MENSAGEM RECEBIDA PELO SOCKET.
  void _aoReceberMensagem(MensagemChatModel mensagem) {
    if (!mounted) return;

    // Deduplica (o socket pode reentregar após reconectar).
    if (_mensagens.any((m) => _mesmaMensagem(m, mensagem))) return;

    setState(() => _mensagens.add(mensagem));

    // Se a mensagem veio do outro lado, marca como lida.
    if (!_ehMinhaMensagem(mensagem) && _token != null) {
      _chatService.marcarComoLida(
        token: _token!,
        conversaId: widget.conversa.id,
      );
    }

    _irParaUltimaMensagem();
  }

  // REBUSCA O HISTÓRICO E MESCLA SEM DUPLICAR.
  Future<void> _atualizarHistorico() async {
    final token = _token;
    if (token == null) return;

    try {
      final historico = await _chatService.listarMensagens(
        token: token,
        conversaId: widget.conversa.id,
      );
      if (!mounted) return;

      setState(() {
        for (final mensagem in historico) {
          if (!_mensagens.any((m) => _mesmaMensagem(m, mensagem))) {
            _mensagens.add(mensagem);
          }
        }
        _mensagens.sort(_comparar);
      });
    } catch (_) {
      // Mantém o histórico já exibido; a próxima reconexão tenta de novo.
    }
  }

  // CARREGA MENSAGENS MAIS ANTIGAS.
  Future<void> _carregarMensagensAntigas() async {
    final token = _token;
    if (token == null || !_temMensagensAntigas || _carregandoAntigas) return;

    setState(() => _carregandoAntigas = true);

    try {
     final anteriores = await _chatService.listarMensagens(
        token: token,
        conversaId: widget.conversa.id,
        page: _paginaHistorico,
        size: _tamanhoPagina,
      );
      if (!mounted) return;

      final novas = anteriores.reversed
          .where((n) => !_mensagens.any((m) => _mesmaMensagem(m, n)))
          .toList();

      setState(() {
        _mensagens.insertAll(0, novas);
        _paginaHistorico++;
        _temMensagensAntigas = anteriores.length >= _tamanhoPagina;
      });
    } catch (_) {
      _mostrarErro(
        'Não foi possível carregar mensagens antigas. Tente novamente.',
      );
    } finally {
      if (mounted) setState(() => _carregandoAntigas = false);
    }
  }

  int _comparar(MensagemChatModel a, MensagemChatModel b) {
    final da = a.enviadaEm;
    final db = b.enviadaEm;
    if (da == null || db == null) return 0;
    return da.compareTo(db);
  }

  // COMPARA POR ID (o backend envia id).
  bool _mesmaMensagem(MensagemChatModel a, MensagemChatModel b) {
    return a.id == b.id;
  }

  // QUEM ENVIOU.
  bool _ehMinhaMensagem(MensagemChatModel m) {
    final tipo = m.remetenteTipo.toUpperCase().trim();
    return tipo == 'LOJISTA' || tipo == 'LOJA';
  }

  String _nomeRemetente(MensagemChatModel m) {
    switch (m.remetenteTipo.toUpperCase()) {
      case 'LOJISTA':
        return 'Você';
      case 'CLIENTE':
        return widget.conversa.clienteNome;
      default:
        final tipo = m.remetenteTipo.toLowerCase();
        if (tipo.isEmpty) return 'Desconhecido';
        return tipo[0].toUpperCase() + tipo.substring(1);
    }
  }

  Color _corDoRemetente(MensagemChatModel m) {
    switch (m.remetenteTipo.toUpperCase()) {
      case 'LOJISTA':
      case 'LOJA':
        return const Color(0xFFFF6961);
      case 'CLIENTE':
        return const Color(0xFF5D201C);
      default:
        return const Color(0xFF3B7DD8);
    }
  }

  // ENVIA MENSAGEM.
  Future<void> _enviarMensagem() async {
    final conteudo = _mensagemController.text.trim();
    if (conteudo.isEmpty || _enviando) return;

    if (!_webSocketService.conectado) {
      _mostrarErro('Chat desconectado. Reconecte para enviar.');
      return;
    }

    setState(() => _enviando = true);

    try {
      _webSocketService.enviar(
        conversaId: widget.conversa.id,
        conteudo: conteudo,
      );

      if (!mounted) return;
      _mensagemController.clear();
    } catch (e) {
      _mostrarErro('Não foi possível enviar a mensagem.');
    } finally {
      if (mounted) setState(() => _enviando = false);
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

  void _usarRespostaRapida(String texto) {
    _mensagemController.text = texto;
    _mensagemController.selection =
        TextSelection.collapsed(offset: texto.length);
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
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
    unawaited(_webSocketService.desconectar());
    _mensagemController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversa = widget.conversa;
    final conectado = _webSocketService.conectado;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F5),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          child: Column(
            children: [
              // CABEÇALHO.
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.035),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const BackArrow(),
                    SizedBox(width: 12.w),
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
              ),

              SizedBox(height: 14.h),

              // STATUS DA CONEXÃO.
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: conectado
                      ? const Color(0xFFEAF7EF)
                      : const Color(0xFFFFF1DF),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      conectado ? Icons.wifi : Icons.wifi_off,
                      size: 14.sp,
                      color: conectado
                          ? const Color(0xFF269653)
                          : Colors.orange.shade800,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      conectado
                          ? 'Conectado ao chat'
                          : (_conectando
                              ? 'Conectando ao chat...'
                              : 'Chat desconectado'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: conectado
                            ? const Color(0xFF269653)
                            : Colors.orange.shade800,
                      ),
                    ),
                    if (!conectado && !_conectando) ...[
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: _conectarWebSocket,
                        child: Text(
                          'Reconectar',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFFE65F59),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              Expanded(child: _construirMensagens()),

              SizedBox(height: 10.h),

              // RESPOSTAS RÁPIDAS.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _respostaRapida('Combinado'),
                    SizedBox(width: 8.w),
                    _respostaRapida('Pedido a caminho'),
                    SizedBox(width: 8.w),
                    _respostaRapida('Vou verificar'),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              // CAMPO DE ENVIO.
              Container(
                padding: EdgeInsets.fromLTRB(10.w, 6.h, 6.w, 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.045),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _mensagemController,
                        minLines: 1,
                        maxLines: 5,
                        maxLength: 4000,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _enviarMensagem(),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Escreva sua mensagem...',
                          hintStyle: TextStyle(
                            color: const Color(0xFFB9ADAD),
                            fontSize: 13.sp,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    SizedBox(
                      width: 46.w,
                      height: 46.w,
                      child: Material(
                        color: const Color(0xFFFF6961),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _enviando ? null : _enviarMensagem,
                          child: Center(
                            child: _enviando
                                ? SizedBox(
                                    width: 19.w,
                                    height: 19.w,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // LISTA DE MENSAGENS.
  Widget _construirMensagens() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48.sp,
                color: const Color(0xFFC9BCBC),
              ),
              SizedBox(height: 16.h),
              Text(
                _erro!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF5D201C),
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: _inicializarChat,
                child: const Text(
                  'Tentar novamente',
                  style: TextStyle(color: Color(0xFFFF6961)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_mensagens.isEmpty) {
      return Center(
        child: Text(
          'Ainda não há mensagens.\nMande a primeira ao cliente.',
          textAlign: TextAlign.center,
          style: TextStyle(color: const Color(0xFF8A8A8A), fontSize: 15.sp),
        ),
      );
    }

    final deslocamento = _temMensagensAntigas ? 1 : 0;

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 2.w),
      itemCount: _mensagens.length + deslocamento,
      itemBuilder: (context, index) {
        if (_temMensagensAntigas && index == 0) {
          return TextButton(
            onPressed: _carregandoAntigas ? null : _carregarMensagensAntigas,
            child: Text(
              _carregandoAntigas ? 'Carregando...' : 'Ver mensagens anteriores',
            ),
          );
        }

        final i = index - deslocamento;
        final mensagem = _mensagens[i];

        // Mostra nome/avatar só na primeira mensagem de uma sequência
        // do mesmo remetente.
        final primeiraDoGrupo =
            i == 0 || _mensagens[i - 1].remetenteTipo != mensagem.remetenteTipo;

        return _balao(mensagem, primeiraDoGrupo);
      },
    );
  }

  // BALÃO COM IDENTIFICAÇÃO DO REMETENTE.
  Widget _balao(MensagemChatModel mensagem, bool primeiraDoGrupo) {
    final minha = _ehMinhaMensagem(mensagem);
    final nome = _nomeRemetente(mensagem);
    final corNome = _corDoRemetente(mensagem);
    final larguraAvatar = 28.w;

    final avatar = primeiraDoGrupo
        ? CircleAvatar(
            radius: 14.r,
            backgroundColor: corNome.withOpacity(0.15),
            child: Text(
              _iniciais(nome),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: corNome,
              ),
            ),
          )
        : SizedBox(width: larguraAvatar);

    final conteudoBalao = Container(
      constraints: BoxConstraints(maxWidth: 0.68.sw),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: minha ? const Color(0xFFFF6961) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
          bottomLeft: Radius.circular(minha ? 16.r : 4.r),
          bottomRight: Radius.circular(minha ? 4.r : 16.r),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            minha ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (primeiraDoGrupo) ...[
            Text(
              nome,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: minha ? const Color(0xE6FFFFFF) : corNome,
              ),
            ),
            SizedBox(height: 3.h),
          ],
          Text(
            mensagem.conteudo,
            style: TextStyle(
              color: minha ? Colors.white : const Color(0xFF5D201C),
              fontSize: 15.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            _horario(mensagem.enviadaEm),
            style: TextStyle(
              color: minha ? const Color(0xCCFFFFFF) : Colors.grey,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: 6.h,
        top: primeiraDoGrupo ? 6.h : 0,
      ),
      child: Row(
        mainAxisAlignment:
            minha ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: minha
            ? [conteudoBalao, SizedBox(width: 6.w), avatar]
            : [avatar, SizedBox(width: 6.w), conteudoBalao],
      ),
    );
  }

  Widget _respostaRapida(String texto) {
    return ActionChip(
      avatar: const Icon(
        Icons.chat_bubble_rounded,
        size: 15,
        color: Color(0xFFE65F59),
      ),
      label: Text(
        texto,
        style: TextStyle(
          color: const Color(0xFF725B59),
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFF2DAD7)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      onPressed: () => _usarRespostaRapida(texto),
    );
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+'));

    if (partes.isEmpty || partes.first.isEmpty) return 'C';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();

    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }
}