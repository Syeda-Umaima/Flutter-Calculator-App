import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ButtonType { number, operator, function, action }

class CalculatorButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final ButtonType type;
  final double? fontSize;
  final IconData? icon;
  final bool isWide;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.onLongPress,
    this.type = ButtonType.number,
    this.fontSize,
    this.icon,
    this.isWide = false,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    switch (widget.type) {
      case ButtonType.number:
        return colorScheme.surfaceContainerHighest;
      case ButtonType.operator:
        return colorScheme.primaryContainer;
      case ButtonType.function:
        return colorScheme.tertiaryContainer;
      case ButtonType.action:
        return colorScheme.errorContainer;
    }
  }

  Color _getTextColor(ColorScheme colorScheme) {
    switch (widget.type) {
      case ButtonType.number:
        return colorScheme.onSurface;
      case ButtonType.operator:
        return colorScheme.onPrimaryContainer;
      case ButtonType.function:
        return colorScheme.onTertiaryContainer;
      case ButtonType.action:
        return colorScheme.onErrorContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          _controller.forward();
          HapticFeedback.lightImpact();
        },
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () {
          _controller.reverse();
        },
        onLongPress: widget.onLongPress != null
            ? () {
                HapticFeedback.mediumImpact();
                widget.onLongPress!();
              }
            : null,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _getBackgroundColor(colorScheme),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: widget.icon != null
                ? Icon(
                    widget.icon,
                    color: _getTextColor(colorScheme),
                    size: 24,
                  )
                : Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: widget.fontSize ?? 22,
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(colorScheme),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Display widget for showing expression and result
class CalculatorDisplay extends StatelessWidget {
  final String expression;
  final String result;
  final bool showResult;

  const CalculatorDisplay({
    super.key,
    required this.expression,
    required this.result,
    this.showResult = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Expression
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: showResult ? 18 : 30,
                fontWeight: FontWeight.w500,
                color: showResult
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface,
              ),
              child: Text(
                expression.isEmpty ? '0' : expression,
              ),
            ),
          ),
          // Result
          if (showResult && result.isNotEmpty) ...[
            const SizedBox(height: 0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                '= $result',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Animated gradient card background
class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientCard({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultColors = [
      colorScheme.primaryContainer.withOpacity(0.3),
      colorScheme.tertiaryContainer.withOpacity(0.3),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? defaultColors,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}
