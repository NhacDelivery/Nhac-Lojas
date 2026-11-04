import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:uuid/uuid.dart';

import '../models/mensagem_chat_model.dart';

class ChatWebSocketService {
  static const String _url =
      'wss://backend-nhac.cloud.run/ws-native';

  StompClient? _client;

  bool _conectado = false;
  bool _conectando = false;

  bool get conectado => _conectado;

  Future<void> conectar({
    required String token,
    required String conversaId,
    required void Function(MensagemChatModel) aoReceberMensagem,
    required void Function(String) aoReceberErro,
  }) async {
    if (_conectado) return;

    if (_conectando) {
      throw Exception('Conexão já está sendo iniciada.');
    }

    _conectando = true;

    final conexaoCompleta = Completer<void>();

    try {
      _client = StompClient(
        config: StompConfig(
          url: _url,

          reconnectDelay: const Duration(seconds: 5),

          heartbeatIncoming: const Duration(seconds: 10),
          heartbeatOutgoing: const Duration(seconds: 10),

          stompConnectHeaders: {
            'Authorization': 'Bearer $token',
          },

          onConnect: (frame) {
            _conectado = true;

            // TÓPICO DE MENSAGENS.
            _client?.subscribe(
              destination: '/topic/conversas/$conversaId',
              callback: (frame) {
                final body = frame.body;

                if (body == null || body.isEmpty) return;

                try {
                  final json = jsonDecode(body);

                  if (json is Map<String, dynamic>) {
                    final mensagem =
                        MensagemChatModel.fromJson(json);

                    aoReceberMensagem(mensagem);
                  }
                } catch (e) {
                  aoReceberErro(
                    'Erro ao interpretar mensagem recebida.',
                  );
                }
              },
            );

            // FILA DE ERROS.
            _client?.subscribe(
              destination: '/user/queue/erros',
              callback: (frame) {
                final body = frame.body;

                if (body == null || body.isEmpty) return;

                try {
                  final json = jsonDecode(body);

                  aoReceberErro(
                    json is Map<String, dynamic>
                        ? json['erro']?.toString() ??
                            'Erro ao enviar mensagem.'
                        : 'Erro ao enviar mensagem.',
                  );
                } catch (_) {
                  aoReceberErro('Erro ao enviar mensagem.');
                }
              },
            );

            if (!conexaoCompleta.isCompleted) {
              conexaoCompleta.complete();
            }
          },

          onStompError: (frame) {
            final erro =
                frame.body ?? 'Erro de comunicação STOMP.';

            if (!conexaoCompleta.isCompleted) {
              conexaoCompleta.completeError(Exception(erro));
            } else {
              aoReceberErro(erro);
            }
          },

          onWebSocketError: (erro) {
            _conectado = false;

            if (!conexaoCompleta.isCompleted) {
              conexaoCompleta.completeError(
                Exception('Erro WebSocket: $erro'),
              );
            } else {
              aoReceberErro('Conexão WebSocket perdida.');
            }
          },

          onWebSocketDone: () {
            _conectado = false;
          },
        ),
      );

      _client!.activate();

      await conexaoCompleta.future.timeout(
        const Duration(seconds: 15),
      );
    } catch (e) {
      await desconectar();
      rethrow;
    } finally {
      _conectando = false;
    }
  }

  // ENVIO DE MENSAGEM.
  void enviar({
    required String conversaId,
    required String conteudo,
  }) {
    if (!_conectado || _client == null) {
      throw Exception('WebSocket desconectado.');
    }

    final texto = conteudo.trim();

    if (texto.isEmpty) {
      throw Exception('Digite uma mensagem.');
    }

    if (texto.length > 4000) {
      throw Exception(
        'A mensagem deve ter no máximo 4000 caracteres.',
      );
    }

    _client!.send(
      destination: '/app/conversas/$conversaId/enviar',
      headers: {
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'conteudo': texto,
        'clientMessageId': const Uuid().v4(),
      }),
    );
  }

  Future<void> desconectar() async {
    _conectado = false;
    _conectando = false;

    final client = _client;
    _client = null;

    client?.deactivate();
  }
}