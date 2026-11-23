import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nhac_lojas/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'cadastro usa a prova de e-mail e salva a identidade do servidor',
    () async {
      SharedPreferences.setMockInitialValues({});
      final chamadas = <String>[];
      await http.runWithClient(
        () async {
          await AuthService.enviarCodigoCadastro('novo@example.org');
          final prova = await AuthService.confirmarEmailCadastro(
            email: 'novo@example.org',
            codigo: '123456',
          );
          await AuthService.registrar(
            id: 'local',
            nome: 'Teste',
            email: 'novo@example.org',
            telefone: '11999990000',
            senha: 'Teste1234',
            tokenCadastro: prova,
          );
          expect(await AuthService.obterUsuarioId(), 'servidor');
          expect(await AuthService.obterToken(), 'sessao');
        },
        () => MockClient((req) async {
          chamadas.add(req.url.pathSegments.last);
          switch (chamadas.last) {
            case 'enviar-codigo-cadastro':
              expect(jsonDecode(req.body)['email'], 'novo@example.org');
              return http.Response('', 200);
            case 'confirmar-email-cadastro':
              return http.Response('{"tokenCadastro":"prova"}', 200);
            case 'registrar':
              expect(jsonDecode(req.body)['tokenCadastro'], 'prova');
              return http.Response(
                '{"token":"sessao","usuarioId":"servidor"}',
                201,
              );
            default:
              throw StateError(req.url.path);
          }
        }),
      );
      expect(chamadas, [
        'enviar-codigo-cadastro',
        'confirmar-email-cadastro',
        'registrar',
      ]);
    },
  );
  test('uma recusa do provedor de e-mail chega ao formulário', () async {
    await http.runWithClient(
      () async {
        await expectLater(
          AuthService.enviarCodigoCadastro('novo@example.org'),
          throwsA(
            predicate((e) => e.toString().contains('envio indisponível')),
          ),
        );
      },
      () => MockClient(
        (_) async => http.Response.bytes(
          utf8.encode('{"message":"envio indisponível"}'),
          503,
        ),
      ),
    );
  });
}
