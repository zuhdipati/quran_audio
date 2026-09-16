import 'package:flutter/material.dart';

/// Fades and lifts a list row into place the first time it is built.
///
/// Only the first [maxAnimatedIndex] rows animate — later rows appear at once
/// so long lists stay cheap — and the animation is one-shot, so search
/// filtering and scroll recycling never replay it.
class StaggeredEntrance extends StatefulWidget {
  final int index;
  final Widget child;
  final int maxAnimatedIndex;
  final Duration duration;
  final Duration step;
  final double offset;

  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
    this.maxAnimatedIndex = 10,
    this.duration = const Duration(milliseconds: 320),
    this.step = const Duration(milliseconds: 40),
    this.offset = 12,
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  late Animation<double> _progress = kAlwaysCompleteAnimation;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    if (widget.index > widget.maxAnimatedIndex ||
        MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }

    // the delay lives in the curve rather than a Timer, so the row has no
    // pending work to cancel if it scrolls out and is disposed early
    final delay = widget.step.inMilliseconds * widget.index;
    final total = widget.duration.inMilliseconds + delay;

    _controller.duration = Duration(milliseconds: total);
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) {
        final value = _progress.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * widget.offset),
            child: child,
          ),
        );
      },
    );
  }
}
