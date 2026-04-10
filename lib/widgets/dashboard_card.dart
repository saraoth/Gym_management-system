import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _counterAnimation;
  bool _isHovered = false;
  double _targetValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _parseAndAnimateValue();
  }
  
  void _parseAndAnimateValue() {
    // Extract numeric value from the string
    final numericString = widget.value.replaceAll(RegExp(r'[^0-9.]'), '');
    _targetValue = double.tryParse(numericString) ?? 0;
    
    _counterAnimation = Tween<double>(begin: 0, end: _targetValue).animate(
      CurvedAnimation(
        parent: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1500),
        )..forward(),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _counterAnimation.status == AnimationStatus.forward
        ? (_counterAnimation as Animation).removeListener(() {})
        : null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: _isHovered ? 8 : 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  widget.color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: widget.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.color.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.icon,
                                color: widget.color,
                                size: 28,
                              ),
                            ),
                          );
                        },
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(20 * (1 - value), 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: widget.trend.startsWith('+')
                                      ? Colors.green.withOpacity(0.15)
                                      : Colors.red.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: widget.trend.startsWith('+')
                                        ? Colors.green.withOpacity(0.3)
                                        : Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      widget.trend.startsWith('+')
                                          ? Icons.trending_up
                                          : Icons.trending_down,
                                      size: 14,
                                      color: widget.trend.startsWith('+')
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.trend,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: widget.trend.startsWith('+')
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: _counterAnimation,
                    builder: (context, child) {
                      final prefix = widget.value.contains('E£') ? 'E£' : '';
                      final displayValue = _counterAnimation.value.toStringAsFixed(0);
                      return Text(
                        '$prefix$displayValue',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      );
                    },
                  ),
                  Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
