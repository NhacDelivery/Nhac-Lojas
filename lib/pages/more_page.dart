import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac_lojas/components/container_nhac.dart';
import 'package:nhac_lojas/controllers/scroll_shell_controller.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  Widget _item({
    required BuildContext context,
    required IconData icon,
    required String titulo,
    required String descricao,
    required String rota,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      child: ContainerNhac(
        icon: icon,
        informacao: titulo,
        complemento: descricao,
        exibirSeta: true,
        onTap: () => context.push(rota),
      ),
    );
  }

  Widget _secao(String titulo) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h, bottom: 4.h, left: 4.w),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          titulo,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5D201C),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: ScrollShellController.of(context),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 110.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Mais',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            _secao('Gerenciamento da loja'),
            _item(context: context, icon: Icons.inventory_2_outlined, titulo: 'Produtos', descricao: 'Gerencie seu cardápio e produtos', rota: '/cardapio-vazio'),
            const Divider(),
            _item(context: context, icon: Icons.people_outline, titulo: 'Funcionários', descricao: 'Gerencie sua equipe', rota: '/funcionarios'),
            const Divider(),
            _item(context: context, icon: Icons.bar_chart_rounded, titulo: 'Financeiro', descricao: 'Acompanhe faturamento e repasses', rota: '/financeiro'),
            _secao('Configurações'),
            _item(context: context, icon: Icons.store_outlined, titulo: 'Informações da loja', descricao: 'Nome, descrição e dados da loja', rota: '/informacao-loja'),
            const Divider(),
            _item(context: context, icon: Icons.location_on_outlined, titulo: 'Endereço da loja', descricao: 'Consulte e edite o endereço', rota: '/endereco-edicao'),
            const Divider(),
            _item(context: context, icon: Icons.payment_outlined, titulo: 'Formas de pagamento', descricao: 'Configure os pagamentos aceitos', rota: '/formas-pagamento-edicao'),
            const Divider(),
            _item(context: context, icon: Icons.manage_accounts_outlined, titulo: 'Configurações da conta', descricao: 'Dados de acesso e preferências', rota: '/configuracoes-conta'),
            _secao('Recursos adicionais do aplicativo'),
            _item(context: context, icon: Icons.discount_outlined, titulo: 'Cupons e promoções', descricao: 'Crie e gerencie promoções', rota: '/cupom'),
            const Divider(),
            _item(context: context, icon: Icons.print_outlined, titulo: 'Impressoras', descricao: 'Gerencie suas impressoras', rota: '/impressoras'),
            const Divider(),
            _item(context: context, icon: Icons.star_outline_rounded, titulo: 'Avaliações', descricao: 'Acompanhe as avaliações dos clientes', rota: '/avaliacoes'),
            const Divider(),
            _item(context: context, icon: Icons.tune_rounded, titulo: 'Configurações do aplicativo', descricao: 'Preferências de som e alertas', rota: '/configuracoes-app'),
          ],
        ),
      ),
    );
  }
}
