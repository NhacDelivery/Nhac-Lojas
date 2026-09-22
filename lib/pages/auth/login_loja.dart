import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac_lojas/components/back_arrow.dart';
import 'package:nhac_lojas/components/button_nhac.dart';
import 'package:nhac_lojas/components/nhac_input_field.dart';
import 'package:nhac_lojas/services/auth_service.dart';

class LoginLoja extends StatefulWidget {
  const LoginLoja({super.key});

  @override
  State<LoginLoja> createState() => _LoginLojaState();
}

class _LoginLojaState extends State<LoginLoja> {
final _emailController = TextEditingController();
final _senhaController = TextEditingController();

bool _senhaVisivel = false;
bool _carregando = false;

@override
void dispose() {
  _emailController.dispose();
  _senhaController.dispose();
  super.dispose();
}
Future<void> _fazerLogin() async {
  final email = _emailController.text.trim();
  final senha = _senhaController.text;

  if (email.isEmpty) {
    _mostrarErro('Digite seu e-mail ou telefone.');
    return;
  }

  if (senha.isEmpty) {
    _mostrarErro('Digite sua senha.');
    return;
  }

  setState(() {
    _carregando = true;
  });

  try {
    final resultado = await AuthService.login(
      email: email,
      senha: senha,
    );

    debugPrint('LOGIN REALIZADO: $resultado');

    if (!mounted) return;

    context.go('/home');
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
                    const BackArrow(targetRoute: '/bem-vindo'),
                    SizedBox(width: 12.w),
                    Text(
                      'Entrar',
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                Text(
                  'Acesse sua conta',
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Digite seus dados para entrar.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'E-mail ou telefone',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                 NhacInputField(
                  hintText: 'Email',
                  controller: _emailController
                  ),
                SizedBox(height: 16.h),
                Text(
                  'Senha',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                NhacInputField(
                  hintText: 'Senha',
                  obscureText: !_senhaVisivel,
                  controller: _senhaController,
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
                SizedBox(
                  height: 35.h,
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: Text(
                        'Esqueceu sua senha?',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFFFF6961),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        context.push('/recuperar-senha');
                      },
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        indent: 30.w,
                        endIndent: 10.w,
                      ),
                    ),
                    Text(
                      "Ou",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color.fromARGB(255, 99, 99, 99),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        indent: 10.w,
                        endIndent: 30.w,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                ButtonNhac(
                  texto: 'Continuar com o Google',
                  isSecundario: true,
                  icone: SvgPicture.asset(
                    'assets/images/google-logo.svg',
                    height: 24.h,
                    width: 24.w,
                  ),
                  onTap: () => context.go('/home'),
                ),
                SizedBox(height: 32.h),
                ButtonNhac(
                  texto: 'Continuar',
             //      onTap: _fazerLogin,
                  onTap: () => context.go('/home'),

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
