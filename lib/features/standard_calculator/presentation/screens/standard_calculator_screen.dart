import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator/features/standard_calculator/presentation/notifiers/calculator_notifier.dart';

class StandardCalculatorScreen extends ConsumerWidget {
  const StandardCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Output Screen Area
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28.0,
                  vertical: 24.0,
                ),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Expression input with Backspace button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            reverse: true,
                            child: Text(
                              state.expression.isEmpty ? '0' : state.expression,
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w200,
                                color: state.expression.isEmpty
                                    ? (isDark ? Colors.white24 : Colors.black26)
                                    : (isDark ? Colors.white70 : Colors.black54),
                                letterSpacing: -1.0,
                              ),
                            ),
                          ),
                        ),
                        if (state.expression.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.backspace_outlined),
                            color: theme.colorScheme.primary,
                            onPressed: () {
                              ref.read(calculatorProvider.notifier).backspace();
                            },
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Real-time preview (or final result if expression is empty)
                    if (state.realTimePreview.isNotEmpty)
                      Text(
                        state.realTimePreview,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white30 : Colors.black38,
                          letterSpacing: -0.5,
                        ),
                      )
                    else if (state.expression.isNotEmpty)
                      Text(
                        state.result,
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w300,
                          color: isDark ? Colors.white : theme.colorScheme.primary,
                          letterSpacing: -1.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 2. Button Pad Area
            Container(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF13111C).withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(36),
                ),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: Column(
                children: [
                  _buildButtonRow(context, ref, ['C', '(', ')', '÷']),
                  _buildButtonRow(context, ref, ['7', '8', '9', '×']),
                  _buildButtonRow(context, ref, ['4', '5', '6', '-']),
                  _buildButtonRow(context, ref, ['1', '2', '3', '+']),
                  _buildButtonRow(context, ref, ['.', '0', '%', '=']),
                ],
              ),
            ),
            const SizedBox(height: 76), // Safe spacing for nav bar
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(
    BuildContext context,
    WidgetRef ref,
    List<String> buttons,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buttons.map((btn) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: _buildCalculatorButton(context, ref, btn),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalculatorButton(
    BuildContext context,
    WidgetRef ref,
    String text,
  ) {
    final theme = Theme.of(context);
    final notifier = ref.read(calculatorProvider.notifier);

    // Determine colors
    final isOperator =
        text == '÷' || text == '×' || text == '-' || text == '+' || text == '=';
    final isAction = text == 'C' || text == '(' || text == ')' || text == '%';

    Color btnColor;
    Color textColor;

    if (isOperator) {
      btnColor = text == '='
          ? theme.colorScheme.primary
          : theme.colorScheme.primary.withValues(alpha: 0.15);
      textColor = text == '=' ? Colors.white : theme.colorScheme.primary;
    } else if (isAction) {
      btnColor = theme.brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.04);
      textColor = theme.brightness == Brightness.dark
          ? Colors.cyan
          : theme.colorScheme.secondary;
    } else {
      btnColor = theme.brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.02)
          : Colors.white;
      textColor = theme.brightness == Brightness.dark
          ? Colors.white
          : Colors.black87;
    }

    return _CalculatorButton(
      text: text,
      isOperator: isOperator,
      isAction: isAction,
      btnColor: btnColor,
      textColor: textColor,
      onTap: () {
        if (text == 'C') {
          notifier.clear();
        } else if (text == '=') {
          notifier.evaluate();
        } else {
          notifier.append(text);
        }
      },
    );
  }
}

class _CalculatorButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color btnColor;
  final Color textColor;
  final bool isOperator;
  final bool isAction;

  const _CalculatorButton({
    required this.text,
    required this.onTap,
    required this.btnColor,
    required this.textColor,
    required this.isOperator,
    required this.isAction,
  });

  @override
  State<_CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<_CalculatorButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget buttonContent;
    if (widget.isOperator) {
      buttonContent = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.text == '='
                ? [theme.colorScheme.primary, theme.colorScheme.tertiary]
                : [
                    theme.colorScheme.primary.withValues(alpha: 0.2),
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.text == '='
                ? Colors.transparent
                : theme.colorScheme.primary.withValues(alpha: 0.15),
          ),
          boxShadow: widget.text == '='
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.textColor,
            ),
          ),
        ),
      );
    } else if (widget.isAction) {
      buttonContent = Container(
        decoration: BoxDecoration(
          color: widget.btnColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: widget.textColor,
            ),
          ),
        ),
      );
    } else {
      buttonContent = Container(
        decoration: BoxDecoration(
          color: widget.btnColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.03),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
        ),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: widget.textColor,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AspectRatio(
          aspectRatio: 1.1,
          child: buttonContent,
        ),
      ),
    );
  }
}
