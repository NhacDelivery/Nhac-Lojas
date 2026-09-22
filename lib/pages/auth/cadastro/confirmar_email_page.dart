import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/services/auth_service.dart';

class ConfirmarEmailPage extends StatefulWidget {
  final String nome;
  final String email;
  final String telefone;
  final String senha;

  const ConfirmarEmailPage({
    super.key,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.senha,
  });

  @override
  State<ConfirmarEmailPage> createState() =>
      _ConfirmarEmailPageState();
}

class _ConfirmarEmailPageState extends State<ConfirmarEmailPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _carregando = false;
  bool _reenviando = false;

  String get _codigo {
    return _controllers
        .map((controller) => controller.text)
        .join();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    setState(() {});
  }

  Future<void> _confirmarCodigo() async {
    final codigo = _codigo;

    if (codigo.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Digite o código completo de 6 dígitos.',
          ),
        ),
      );
      return;
    }

    if (_carregando) return;

    setState(() {
      _carregando = true;
    });

    try {
      print('Código digitado: $codigo');
      print('E-mail: ${widget.email}');

      await AuthService.confirmarEmailCadastro(
        email: widget.email,
        codigo: codigo,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'E-mail confirmado com sucesso!',
          ),
        ),
      );

      context.push('/dados-basicos');
    } catch (e) {
      if (!mounted) return;

      final mensagem = e
          .toString()
          .replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Future<void> _reenviarCodigo() async {
    if (_reenviando) return;

    setState(() {
      _reenviando = true;
    });

    try {
      await AuthService.enviarCodigoCadastro(
        widget.email,
      );

      if (!mounted) return;

      // Limpa os campos
      for (final controller in _controllers) {
        controller.clear();
      }

      _focusNodes.first.requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Novo código enviado para seu e-mail.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final mensagem = e
          .toString()
          .replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _reenviando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE9E7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ícone
                      Stack(
                        children: [
                          Container(
                            width: 140.w,
                            height: 140.w,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(
                                255,
                                255,
                                213,
                                213,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.mail_outline_rounded,
                              size: 60.sp,
                              color: Colors.redAccent,
                            ),
                          ),

                          Positioned(
                            right: 8.w,
                            bottom: 8.h,
                            child: Container(
                              padding: EdgeInsets.all(2.r),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(
                                  255,
                                  255,
                                  231,
                                  229,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                padding: EdgeInsets.all(6.r),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 16.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // Título
                      Text(
                        'Confirme seu e-mail!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3D1B19),
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // Descrição
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  'Enviamos um código de confirmação para\n',
                            ),
                            TextSpan(
                              text: widget.email,
                              style: TextStyle(
                                color: const Color(0xFF5D201C),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  '\nDigite o código abaixo para confirmar seu e-mail.',
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 28.h),

                      // Campos do código
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          6,
                          (index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                              ),
                              child: SizedBox(
                                width: 45.w,
                                height: 55.h,
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType:
                                      TextInputType.number,
                                  textInputAction:
                                      index == 5
                                          ? TextInputAction.done
                                          : TextInputAction.next,
                                  maxLength: 1,
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color(0xFF3D1B19),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding:
                                        EdgeInsets.zero,
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        12.r,
                                      ),
                                      borderSide: BorderSide(
                                        color:
                                            Colors.grey.shade300,
                                      ),
                                    ),
                                    enabledBorder:
                                        OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        12.r,
                                      ),
                                      borderSide: BorderSide(
                                        color:
                                            Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder:
                                        OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        12.r,
                                      ),
                                      borderSide:
                                          const BorderSide(
                                        color: Colors.redAccent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _onChanged(
                                      value,
                                      index,
                                    );

                                    if (index == 5 &&
                                        value.isNotEmpty) {
                                      FocusScope.of(context)
                                          .unfocus();
                                    }
                                  },
                                  onSubmitted: (_) {
                                    if (index == 5) {
                                      _confirmarCodigo();
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 16.h),

                      Text(
                        'O código expira em 15 minutos',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13.sp,
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Reenviar
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(20.r),
                        ),
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Não recebeu o código? ',
                              ),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: _reenviando
                                      ? null
                                      : _reenviarCodigo,
                                  child: Text(
                                    _reenviando
                                        ? 'Enviando...'
                                        : 'Reenviar código',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Botão
                      ButtonNhac(
                        texto: _carregando
                            ? 'Validando...'
                            : 'Confirmar código',
                        onTap: _carregando
                            ? null
                            : _confirmarCodigo,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}