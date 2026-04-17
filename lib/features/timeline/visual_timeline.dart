import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VisualTimelineTask {
  const VisualTimelineTask({
    required this.title,
    required this.description,
    required this.duration,
    this.svgAsset,
  });

  final String title;
  final String description;
  final Duration duration;
  final String? svgAsset;
}

class VisualTimeline extends StatelessWidget {
  const VisualTimeline({
    super.key,
    required this.tasks,
    required this.activeTaskIndex,
    required this.dopamineBoosted,
  });

  final List<VisualTimelineTask> tasks;
  final int activeTaskIndex;
  final bool dopamineBoosted;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isActive = index == activeTaskIndex;

        return Card(
          color: isActive
              ? (dopamineBoosted ? const Color(0xFFFFF2B3) : const Color(0xFFE8F5E9))
              : null,
          child: ListTile(
            leading: task.svgAsset != null
                ? SvgPicture.asset(task.svgAsset!, width: 28, height: 28)
                : CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
            title: Text(task.title),
            subtitle: Text(task.description),
            trailing: isActive
                ? VisualCountdown(duration: task.duration)
                : Text('${task.duration.inMinutes}m'),
          ),
        );
      },
    );
  }
}

class VisualCountdown extends StatefulWidget {
  const VisualCountdown({super.key, required this.duration});

  final Duration duration;

  @override
  State<VisualCountdown> createState() => _VisualCountdownState();
}

class _VisualCountdownState extends State<VisualCountdown> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remaining <= const Duration(seconds: 1)) {
        timer.cancel();
        setState(() => _remaining = Duration.zero);
      } else {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const maxSafeDurationSeconds = Duration.secondsPerDay * 365;
    final totalSeconds = widget.duration.inSeconds.clamp(1, maxSafeDurationSeconds);
    final ratio = _remaining.inSeconds / totalSeconds;

    return SizedBox(
      width: 54,
      height: 54,
      child: CustomPaint(
        painter: _TimeTimerPainter(progress: ratio),
        child: Center(
          child: Text(
            _remaining.inMinutes.toString(),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
    );
  }
}

class _TimeTimerPainter extends CustomPainter {
  _TimeTimerPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final bgPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFE0E0E0);

    final fgPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF4CAF50);

    canvas.drawCircle(center, radius, bgPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(rect, startAngle, sweepAngle, true, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _TimeTimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
