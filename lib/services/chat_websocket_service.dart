
import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:uuid/uuid.dart';

import '../models/mensagem_chat_model.dart';

class ChatWebSocketService {
  // O backend informa que aceita WebSocket puro em /ws-native.
  // Confirme o caminho exato na configuração WebSocket do Spring.
  static const String _url =
      'wss://backend-nhac.cloud.run/ws-native';

  StompClient? _client;
  bool _conectado = false;

  bool get conectado => _conectado;

  Future<void> conectar({
    required String token,
    required String conversaId,
    required void Function(MensagemChatModel) aoReceberMensagem,
    required void Function(String) aoReceberErro,
  }) async {
    if (_conectado) return;

    final conexaoCompleta = Completer<void>();

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

          // Recebe as mensagens novas da conversa.
          _client?.subscribe(
            destination: '/topic/conversas/$conversaId',
            callback: (frame) {
              final body = frame.body;
              if (body == null || body.isEmpty) return;

              try {
                final json = jsonDecode(body);
                if (json is Map<String, dynamic>) {
                  aoReceberMensagem(
                    MensagemChatModel.fromJson(json),
                  );
                }
              } catch (e) {
                aoReceberErro(
                  'Não foi possível interpretar a mensagem recebida.',
                );
              }
            },
          );

          // Recebe erros de negócio enviados pelo controller Java.
          _client?.subscribe(
            destination: '/user/queue/erros',
            callback: (frame) {
              final body = frame.body;
              if (body == null || body.isEmpty) return;

              try {
                final json = jsonDecode(body);
                if (json is Map<String, dynamic>) {
                  aoReceberErro(
                    json['erro']?.toString() ??
                        'O servidor recusou a mensagem.',
                  );
                } else {
                  aoReceberErro('O servidor recusou a mensagem.');
                }
              } catch (_) {
                aoReceberErro('O servidor recusou a mensagem.');
              }
            },
          );

          if (!conexaoCompleta.isCompleted) {
            conexaoCompleta.complete();
          }
        },
        onStompError: (frame) {
          final detalhe = frame.body ?? 'Erro na conexão STOMP.';
          if (!conexaoCompleta.isCompleted) {
            conexaoCompleta.completeError(Exception(detalhe));
          } else {
            aoReceberErro(detalhe);
          }
        },
        onWebSocketError: (erro) {
          _conectado = false;
          if (!conexaoCompleta.isCompleted) {
            conexaoCompleta.completeError(
              Exception('Falha na conexão WebSocket: $erro'),
            );
          } else {
            aoReceberErro('Falha na conexão WebSocket.');
          }
        },
        onWebSocketDone: () {
          _conectado = false;
        },
      ),
    );

    _client!.activate();

    try {
      await conexaoCompleta.future.timeout(
        const Duration(seconds: 15),
      );
    } catch (_) {
      await desconectar();
      rethrow;
    }
  }

  void enviar({
    required String conversaId,
    required String conteudo,
  }) {
    if (!_conectado || _client == null) {
      throw Exception('O chat ainda não está conectado.');
    }

    _client!.send(
      destination: '/app/conversas/$conversaId/enviar',
      headers: {
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'conteudo': conteudo,
        'clientMessageId': const Uuid().v4(),
      }),
    );
  }

  
Future<void> desconectar() async {
    _conectado = false;

    final client = _client;
    _client = null;

    client?.deactivate();
  }

}
