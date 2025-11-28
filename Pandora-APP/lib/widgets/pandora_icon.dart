// lib/widgets/pandora_icon.dart

import 'package:flutter/material.dart';

class PandoraIcon extends StatelessWidget {
  final double size;
  const PandoraIcon({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PandoraIconPainter()),
    );
  }
}

class _PandoraIconPainter extends CustomPainter {
  // Cores do seu SVG
  final Color boxFill = const Color(0xFFF59E0B); // Amarelo (F59E0B)
  final Color boxStroke = const Color(0xFFD97706); // Laranja Escuro (D97706)
  final Color lidFill = const Color(0xFFFBBF24); // Amarelo Claro (FBBF24)

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 40.0; // Baseado no viewBox 40x40

    // Escalas de Posição
    double scaleX(double x) => x * scale;
    double scaleY(double y) => y * scale;

    // Configuração dos Pincéis
    final strokePaint = Paint()
      ..color = boxStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 * scale;

    final fillPaint = Paint()
      ..color = boxFill
      ..style = PaintingStyle.fill;

    // --- 1. Caixa Principal (retângulo) ---
    final boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(scaleX(6), scaleY(12), scaleX(28), scaleY(20)),
      Radius.circular(scaleX(2)),
    );
    canvas.drawRRect(boxRect, fillPaint);
    canvas.drawRRect(boxRect, strokePaint);

    // --- 2. Tampa da Caixa (path) ---
    final lidPath = Path()
      ..moveTo(scaleX(6), scaleY(14))
      ..lineTo(scaleX(20), scaleY(8))
      ..lineTo(scaleX(34), scaleY(14))
      ..lineTo(scaleX(34), scaleY(12))
      // Canto Arredondado Direito
      ..arcToPoint(
        Offset(scaleX(32), scaleY(10)),
        radius: Radius.circular(scaleX(2)),
        clockwise: true,
      )
      ..lineTo(scaleX(8), scaleY(10))
      // Canto Arredondado Esquerdo
      ..arcToPoint(
        Offset(scaleX(6), scaleY(12)),
        radius: Radius.circular(scaleX(2)),
        clockwise: true,
      )
      ..close();

    final lidFillPaint = Paint()..color = lidFill;
    canvas.drawPath(lidPath, lidFillPaint);
    canvas.drawPath(lidPath, strokePaint); // Contorno da tampa

    // --- 3. Fechadura ---
    final lockPaint = Paint()..color = boxStroke;
    canvas.drawCircle(
      Offset(scaleX(20), scaleY(20)),
      scaleX(2),
      lockPaint,
    ); // Círculo
    canvas.drawRect(
      Rect.fromLTWH(scaleX(19), scaleY(21), scaleX(2), scaleY(4)),
      lockPaint,
    ); // Retângulo

    // --- 4. Sombra (Ellipse) ---
    final shadowPaint = Paint()..color = const Color.fromARGB(25, 0, 0, 0);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(scaleX(20), scaleY(34)),
        width: scaleX(24),
        height: scaleY(4),
      ),
      shadowPaint,
    );

    // Os detalhes de linha fina (retângulos) são mais difíceis de desenhar
    // com alta precisão de opacidade sem CustomPainter complexo, então vamos omitir
    // para manter a simplicidade e focar no visual principal.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
