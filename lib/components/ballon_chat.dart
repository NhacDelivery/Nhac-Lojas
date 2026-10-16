import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum StatusLeitura { enviada, lida }

class BallonChat extends StatelessWidget {
  final String texto;
  final String horario;
  final bool ehMinhaMensagem;
  final StatusLeitura? status;

  const BallonChat({
    super.key,
    required this.texto,
    required this.horario,
    required this.ehMinhaMensagem,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final corFundo = ehMinhaMensagem
        ? Colors.redAccent
        : Colors.white;

    final corTexto = ehMinhaMensagem ? Colors.white : Colors.black87;

    final corHorario = Colors.grey;

    final borderRadius = ehMinhaMensagem
        ? BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(2.r),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(2.r),
            bottomRight: Radius.circular(16.r),
          );

    return Align(
      alignment: ehMinhaMensagem ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: ehMinhaMensagem
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: corFundo,
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Text(
                texto,
                style: TextStyle(
                  color: corTexto,
                  fontSize: 14.sp,
                  height: 1.3,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            SizedBox(height: 4.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    horario,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: corHorario,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (ehMinhaMensagem && status != null) ...[
                    SizedBox(width: 4.w),
                    Icon(
                      status == StatusLeitura.lida
                          ? Icons.done_all_rounded
                          : Icons.check_rounded,
                      size: 14.sp,
                      color: status == StatusLeitura.lida
                          ? Colors.redAccent
                          : Colors.grey,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}