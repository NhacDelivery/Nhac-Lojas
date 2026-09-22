import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/nhac_input_field.dart';
import '../../../services/auth_service.dart';


class CriarContaPage extends StatefulWidget {
  const CriarContaPage({super.key});

  @override
  State<CriarContaPage> createState() => _CriarContaPageState();
}



class _CriarContaPageState extends State<CriarContaPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _carregando = false;
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;
  


Future<void> _continuar() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final telefone = _telefoneController.text.trim();
    final senha = _senhaController.text;
    final confirmarSenha = _confirmarSenhaController.text;

    if (nome.isEmpty) {
      _mostrarErro('Digite seu nome completo.');
      return;
    }

    if (email.isEmpty) {
      _mostrarErro('Digite seu e-mail.');
      return;
    }

    if (telefone.isEmpty) {
      _mostrarErro('Digite seu telefone.');
      return;
    }

    if (senha.isEmpty) {
      _mostrarErro('Digite uma senha.');
      return;
    }

    if (senha.length < 8) {
      _mostrarErro('A senha deve ter no mínimo 8 caracteres.');
      return;
    }

    if (senha != confirmarSenha) {
      _mostrarErro('As senhas não coincidem.');
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      await AuthService.enviarCodigoCadastro(email);

      if (!mounted) return;

      context.push(
        '/confirmar-email',
        extra: {
          'nome': nome,
          'email': email,
          'telefone': telefone,
          'senha': senha,
        },
      );
    } catch (e) {
      if (!mounted) return;

      _mostrarErro(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }



   @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const BackArrow(),
                    SizedBox(width: 12.w),
                    Text(
                      'Criar conta',
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Text(
                  'Crie seu acesso',
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Esse e-mail e senha serão usados para você entrar na sua conta depois.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'Nome completo',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 4.h),
                
              NhacInputField(
                hintText: 'Nome',
                controller: _nomeController,
              ),
                SizedBox(height: 16.h),
                Text(
                  'E-mail',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),

                NhacInputField(
                  hintText: 'E-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: 16.h),
                Text(
                  'Telefone',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),

                NhacInputField(
                  hintText: '(00) 00000-0000',
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                ),

                SizedBox(height: 16.h),

                Text(
                  'Nova senha',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 4.h),

                NhacInputField(
                  hintText: 'Mínimo 8 caracteres',
                  controller: _senhaController,
                  obscureText: !_senhaVisivel,
                  suffixIcon: IconButton(
                    icon: _senhaVisivel
                        ? Icon(Icons.visibility, color: const Color(0xFFFF6961), size: 24.sp)
                        : SvgPicture.asset(
                            'assets/images/olho-fechado.svg',
                            width: 24.w,
                            height: 24.h,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFC9BCBC),
                              BlendMode.srcIn,
                            ),
                          ),
                    onPressed: () {
                      setState(() {
                        _senhaVisivel = !_senhaVisivel;
                      });
                    },
                  ),
                ),

                SizedBox(height: 16.h),

                Text(
                  'Confirmar nova senha',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 4.h),

                NhacInputField(
                  hintText: 'Repita a senha',
                  controller: _confirmarSenhaController,
                  obscureText: !_confirmarSenhaVisivel,
                  suffixIcon: IconButton(
                    icon: _confirmarSenhaVisivel
                        ? Icon(Icons.visibility, color: const Color(0xFFFF6961), size: 24.sp)
                        : SvgPicture.asset(
                            'assets/images/olho-fechado.svg',
                            width: 24.w,
                            height: 24.h,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFC9BCBC),
                              BlendMode.srcIn,
                            ),
                          ),
                    onPressed: () {
                      setState(() {
                        _confirmarSenhaVisivel = !_confirmarSenhaVisivel;
                      });
                    },
                  ),
                ),

                SizedBox(height: 32.h),

               ButtonNhac(
                texto: _carregando ? 'Enviando...' : 'Continuar',
                onTap: _carregando ? null : _continuar,
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}