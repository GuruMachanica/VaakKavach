import 'package:flutter/material.dart';
import 'risk_gauge_view.dart';

export 'risk_gauge_view.dart';
export 'dual_ring_painter.dart';

/// Dual-Ring Threat Gauge matching Obsidian Aegis
class RiskGauge extends StatefulWidget {
  final double score;
  final double? innerScore;
  final double size;
  final String? centerLabel;
  final String? subLabel;

  const RiskGauge({
    super.key,
    required this.score,
    this.innerScore,
    this.size = 180,
    this.centerLabel,
    this.subLabel,
  });

  @override
  State<RiskGauge> createState() => _RiskGaugeState();
}

class _RiskGaugeState extends State<RiskGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  late Animation<double> _innerAnim;
  double _prevScore = 0;
  double _prevInner = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _anim = Tween<double>(begin: 0, end: widget.score.clamp(0.0, 1.0)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _innerAnim = Tween<double>(
      begin: 0,
      end: (widget.innerScore ?? widget.score).clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(RiskGauge old) {
    super.didUpdateWidget(old);
    if (old.score != widget.score || old.innerScore != widget.innerScore) {
      _anim = Tween<double>(
        begin: _prevScore,
        end: widget.score.clamp(0.0, 1.0),
      ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _innerAnim = Tween<double>(
        begin: _prevInner,
        end: (widget.innerScore ?? widget.score).clamp(0.0, 1.0),
      ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _prevScore = widget.score.clamp(0.0, 1.0);
      _prevInner = (widget.innerScore ?? widget.score).clamp(0.0, 1.0);
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
      animation: _controller,
      builder: (context, child) => RiskGaugeView(
        score: _anim.value,
        innerScore: _innerAnim.value,
        size: widget.size,
        centerLabel: widget.centerLabel,
        subLabel: widget.subLabel,
      ),
    );
  }
}
