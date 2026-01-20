import 'package:easy_budget/utils/currency_utils.dart';
import 'package:flutter/material.dart';

/// 금액이 0에서 목표값까지 카운트업되는 애니메이션 위젯
class AnimatedAmount extends StatefulWidget {
  final int amount;
  final TextStyle? style;
  final Duration duration;

  const AnimatedAmount({
    super.key,
    required this.amount,
    this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedAmount> createState() => _AnimatedAmountState();
}

class _AnimatedAmountState extends State<AnimatedAmount>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.amount.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedAmount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.amount.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Text(
        CurrencyUtils.formatWithSymbol(_animation.value.round()),
        style: widget.style,
      ),
    );
  }
}
