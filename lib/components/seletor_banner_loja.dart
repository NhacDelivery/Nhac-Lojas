import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class SeletorBannerLoja extends StatefulWidget {
  const SeletorBannerLoja({super.key, this.arquivo, this.url, this.onChanged});

  final File? arquivo;
  final String? url;
  final ValueChanged<File?>? onChanged;

  @override
  State<SeletorBannerLoja> createState() => _SeletorBannerLojaState();
}

class _SeletorBannerLojaState extends State<SeletorBannerLoja> {
  bool _selecionando = false;

  Future<void> _escolher() async {
    setState(() => _selecionando = true);
    try {
      final foto = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1440,
        maxHeight: 1440,
        imageQuality: 85,
      );
      if (foto == null || !mounted) return;

      const formatos = {'jpg', 'jpeg', 'png', 'webp'};
      final extensao = foto.path.split('.').last.toLowerCase();
      if (!formatos.contains(extensao)) {
        throw const FormatException('Escolha uma imagem JPG, PNG ou WebP.');
      }
      if (await foto.length() > 5 * 1024 * 1024) {
        throw const FormatException('Escolha uma imagem de até 5 MB.');
      }
      if (mounted) widget.onChanged?.call(File(foto.path));
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            erro is FormatException
                ? erro.message
                : 'Não foi possível selecionar o banner. Tente novamente.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _selecionando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arquivo = widget.arquivo;
    final url = widget.url;
    final temBanner = url != null && url.isNotEmpty;
    final editavel = widget.onChanged != null && !_selecionando;
    final tema = Theme.of(context);
    final espacoVazio = ColoredBox(
      color: tema.colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.image_outlined, size: 32)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Banner da loja',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4.h),
        const Text(
          'Imagem horizontal exibida na página da loja para clientes.',
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: AspectRatio(
            aspectRatio: 2,
            child: arquivo != null
                ? Image.file(
                    arquivo,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => espacoVazio,
                  )
                : temBanner
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => espacoVazio,
                  )
                : espacoVazio,
          ),
        ),
        Wrap(
          spacing: 8.w,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.photo_library_outlined),
              onPressed: editavel ? _escolher : null,
              label: Text(
                arquivo != null || temBanner
                    ? 'Trocar banner'
                    : 'Adicionar banner',
              ),
            ),
            if (arquivo != null)
              TextButton(
                onPressed: editavel ? () => widget.onChanged?.call(null) : null,
                child: const Text('Descartar seleção'),
              ),
          ],
        ),
      ],
    );
  }
}
