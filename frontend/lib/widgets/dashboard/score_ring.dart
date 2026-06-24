
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class ScoreRing extends StatefulWidget {
  final int score; final double size;
  const ScoreRing({super.key, required this.score, this.size = 120});
  @override State<ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<ScoreRing> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _anim = Tween<double>(begin: 0, end: widget.score / 100).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(widget.score);
    return AnimatedBuilder(animation: _anim, builder: (_, __) {
      return SizedBox(width: widget.size, height: widget.size,
        child: Stack(alignment: Alignment.center, children: [
          CustomPaint(size: Size(widget.size, widget.size),
            painter: _RingPainter(progress: _anim.value, color: color, strokeWidth: widget.size * 0.09)),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${widget.score}', style: TextStyle(color: color, fontSize: widget.size * 0.22, fontWeight: FontWeight.w700)),
            Text(getScoreLabel(widget.score), style: TextStyle(color: AppColors.textMuted, fontSize: widget.size * 0.1, fontWeight: FontWeight.w500)),
          ]),
        ]),
      );
    });
  }
}

class _RingPainter extends CustomPainter {
  final double progress, strokeWidth; final Color color;
  _RingPainter({required this.progress, required this.strokeWidth, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final trackPaint = Paint()..color = AppColors.surface3..strokeWidth = strokeWidth..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);
    final progressPaint = Paint()..color = color..strokeWidth = strokeWidth..style = PaintingStyle.stroke..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 0.3);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, 2 * math.pi * progress, false, progressPaint);
  }
  @override bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
