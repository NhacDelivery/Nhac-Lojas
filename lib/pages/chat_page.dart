
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nhac_lojas/components/container_nhac.dart';
import 'package:nhac_lojas/components/filter_tag.dart';
import 'package:nhac_lojas/components/icon_container.dart';
import 'package:nhac_lojas/controllers/scroll_shell_controller.dart';

import '../models/conversa_resumo_model.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();

  List<ConversaResumoModel> _conversas = [];
  bool _carregando = true;
  String? _erro;
  String _filtroSelecionado = 'Todas';

  @override
  void initState() {
    super.initState();
    _carregarConversas();
  }

  Future<void> _carregarConversas() async {
    if (mounted) {
      setState(() {
        _carregando = true;
        _erro = null;
      });
    }

    try {
      final token = await AuthService.obterToken();

      if (token == null || token.isEmpty) {
        throw Exception('Sessão expirada. Faça login novamente.');
      }

      final conversas = await _chatService.listarConversas(
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _conversas = conversas;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
        _carregando = false;
      });
    }
  }

  List<ConversaResumoModel> get _conversasFiltradas {
    if (_filtroSelecionado == 'Pendentes') {
      return _conversas.where((c) => c.naoLidas > 0).toList();
    }

    return _conversas;
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(RegExp(r'\s+'));

    if (partes.isEmpty || partes.first.isEmpty) {
      return '?';
    }

    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }

    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }

  String _formatarHorario(DateTime? data) {
    if (data == null) return '';

    final local = data.toLocal();
    final agora = DateTime.now();

    final hoje = local.year == agora.year &&
        local.month == agora.month &&
        local.day == agora.day;

    if (hoje) {
      final hora = local.hour.toString().padLeft(2, '0');
      final minuto = local.minute.toString().padLeft(2, '0');
      return '$hora:$minuto';
    }

    final ontem = DateTime(agora.year, agora.month, agora.day)
        .difference(DateTime(local.year, local.month, local.day))
        .inDays == 1;

    if (ontem) return 'Ontem';

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final conversas = _conversasFiltradas;

    return RefreshIndicator(
      onRefresh: _carregarConversas,
      child: SingleChildScrollView(
        controller: ScrollShellController.of(context),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 46.h, 20.w, 110.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconContainer(icon: Icons.search_rounded),
                  SizedBox(width: 8.w),
                  IconContainer(icon: Icons.more_horiz),
                ],
              ),

              SizedBox(height: 24.h),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text('Todas (${_conversas.length})'),
                      selected: _filtroSelecionado == 'Todas',
                      onSelected: (_) {
                        setState(() {
                          _filtroSelecionado = 'Todas';
                        });
                      },
                    ),
                    SizedBox(width: 8.w),
                    ChoiceChip(
                      label: Text(
                        'Pendentes (${_conversas.where((c) => c.naoLidas > 0).length})',
                      ),
                      selected: _filtroSelecionado == 'Pendentes',
                      onSelected: (_) {
                        setState(() {
                          _filtroSelecionado = 'Pendentes';
                        });
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              if (_carregando)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_erro != null)
                _mensagemEstado(
                  icone: Icons.error_outline,
                  mensagem: _erro!,
                  textoBotao: 'Tentar novamente',
                  onPressed: _carregarConversas,
                )
              else if (conversas.isEmpty)
                _mensagemEstado(
                  icone: Icons.chat_bubble_outline,
                  mensagem: _filtroSelecionado == 'Pendentes'
                      ? 'Nenhuma conversa pendente.'
                      : 'Você ainda não tem conversas.',
                )
              else
                ...conversas.map(_construirItemConversa),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirItemConversa(ConversaResumoModel conversa) {
    final nome = conversa.clienteNome;
    final naoLidas = conversa.naoLidas;
    final ehEntregador = conversa.participanteTipo == 'ENTREGADOR';

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: ContainerNhac(
          letrasIcon: _iniciais(nome),
          informacao: ehEntregador ? '$nome (Entregador)' : nome,
          complemento: conversa.ultimaMensagemPreview ?? 'Nenhuma mensagem',
          horario: _formatarHorario(conversa.ultimaMensagemEm),
          formatoIcone: BoxShape.circle,
          statusMensagem: naoLidas > 0
              ? StatusMensagem.naoLida
              : StatusMensagem.visualizada,
          quantidadeMensagens: naoLidas > 0 ? naoLidas : null,
          onTap: () async {
            await context.push(
              '/chat-open',
              extra: conversa,
            );

            if (mounted) {
              _carregarConversas();
            }
          },
        ),
      ),
    );
  }

  Widget _mensagemEstado({
    required IconData icone,
    required String mensagem,
    String? textoBotao,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: Column(
          children: [
            Icon(
              icone,
              size: 42.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 12.h),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
            if (textoBotao != null && onPressed != null) ...[
              SizedBox(height: 12.h),
              TextButton(
                onPressed: onPressed,
                child: Text(textoBotao),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
