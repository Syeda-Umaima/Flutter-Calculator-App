import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import '../widgets/calculator_button.dart';
import '../utils/shared_prefs_helper.dart';

class ScientificCalculator extends StatefulWidget {
  const ScientificCalculator({super.key});

  @override
  State<ScientificCalculator> createState() => _ScientificCalculatorState();
}

class _ScientificCalculatorState extends State<ScientificCalculator> {
  String _expression = '';
  String _result = '';
  bool _calculated = false;
  bool _isRadians = false;
  bool _isInverse = false;

  void _onButtonPressed(String value) {
    setState(() {
      switch (value) {
        case 'C':
          _expression = '';
          _result = '';
          _calculated = false;
          break;

        case 'DEL':
          if (_expression.isNotEmpty) {
            final functions = [
              'sin(',
              'cos(',
              'tan(',
              'log(',
              'ln(',
              'sqrt(',
              'asin(',
              'acos(',
              'atan(',
              'exp('
            ];
            bool deleted = false;
            for (String func in functions) {
              if (_expression.endsWith(func)) {
                _expression =
                    _expression.substring(0, _expression.length - func.length);
                deleted = true;
                break;
              }
            }
            if (!deleted) {
              _expression = _expression.substring(0, _expression.length - 1);
            }
            _result = '';
            _calculated = false;
          }
          break;

        case '=':
          _evaluateExpression();
          break;

        case 'sin':
          _expression += _isInverse ? 'asin(' : 'sin(';
          break;

        case 'cos':
          _expression += _isInverse ? 'acos(' : 'cos(';
          break;

        case 'tan':
          _expression += _isInverse ? 'atan(' : 'tan(';
          break;

        case 'log':
          _expression += 'log(10,';
          break;

        case 'ln':
          _expression += 'ln(';
          break;

        case '√':
          _expression += 'sqrt(';
          break;

        case 'x²':
          _expression += '^2';
          break;

        case 'xʸ':
          _expression += '^';
          break;

        case '10ˣ':
          _expression += '10^';
          break;

        case 'eˣ':
          _expression += 'exp(';
          break;

        case 'π':
          _appendValue('pi');
          break;

        case 'e':
          _appendValue('e');
          break;

        case 'n!':
          _calculateFactorial();
          break;

        case '±':
          _toggleSign();
          break;

        case 'RAD':
          _isRadians = !_isRadians;
          break;

        case 'INV':
          _isInverse = !_isInverse;
          break;

        default:
          _appendValue(value);
      }
    });
  }

  void _appendValue(String value) {
    if (_calculated && !_isOperator(value) && value != '(' && value != ')') {
      _expression = value;
      _result = '';
      _calculated = false;
      return;
    }

    if (_calculated && _isOperator(value)) {
      _expression = _result + value;
      _result = '';
      _calculated = false;
      return;
    }

    _expression += value;
    _result = '';
    _calculated = false;
  }

  bool _isOperator(String char) {
    return '+-*/^%'.contains(char);
  }

  void _toggleSign() {
    if (_expression.isEmpty) return;

    String lastNum = '';
    int startIndex = _expression.length;

    for (int i = _expression.length - 1; i >= 0; i--) {
      if (RegExp(r'[0-9.]').hasMatch(_expression[i])) {
        lastNum = _expression[i] + lastNum;
        startIndex = i;
      } else {
        break;
      }
    }

    if (lastNum.isEmpty) return;

    if (startIndex > 0) {
      String before = _expression[startIndex - 1];
      if (before == '+') {
        _expression = '${_expression.substring(0, startIndex - 1)}-$lastNum';
      } else if (before == '-') {
        _expression = '${_expression.substring(0, startIndex - 1)}+$lastNum';
      } else {
        double toggled = -double.parse(lastNum);
        _expression = _expression.substring(0, startIndex) + toggled.toString();
      }
    } else {
      double toggled = -double.parse(lastNum);
      _expression = toggled.toString();
    }

    _result = '';
    _calculated = false;
  }

  void _calculateFactorial() {
    if (_expression.isEmpty) return;

    String lastNum = '';
    int startIndex = _expression.length;

    for (int i = _expression.length - 1; i >= 0; i--) {
      if (RegExp(r'[0-9]').hasMatch(_expression[i])) {
        lastNum = _expression[i] + lastNum;
        startIndex = i;
      } else {
        break;
      }
    }

    if (lastNum.isEmpty) return;

    int? n = int.tryParse(lastNum);
    if (n == null || n < 0) return;

    int factorial = 1;
    for (int i = 2; i <= n; i++) {
      factorial *= i;
    }

    _expression = _expression.substring(0, startIndex) + factorial.toString();
    _result = '';
    _calculated = false;
  }

  void _evaluateExpression() {
    if (_expression.isEmpty) return;

    try {
      String exp = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('−', '-')
          .replaceAll('pi', math.pi.toString())
          .replaceAll('e', math.e.toString());

      exp = exp.replaceAllMapped(
        RegExp(r'(\d)([a-z(])'),
        (match) => '${match.group(1)}*${match.group(2)}',
      );

      Parser p = Parser();
      Expression parsedExp = p.parse(exp);
      ContextModel cm = ContextModel();

      double result = parsedExp.evaluate(EvaluationType.REAL, cm);

      _result = _formatResult(result);
      _calculated = true;

      if (_result != 'Error') {
        SharedPrefsHelper.addToHistory('$_expression = $_result');
      }
    } catch (e) {
      _result = 'Error';
      _calculated = true;
    }
  }

  String _formatResult(double value) {
    if (value.isNaN || value.isInfinite) return 'Error';

    if (value == value.toInt().toDouble()) {
      return value.toInt().toString();
    }

    String formatted = value.toStringAsFixed(10);
    formatted = formatted.replaceAll(RegExp(r'0+$'), '');
    formatted = formatted.replaceAll(RegExp(r'\.$'), '');

    return formatted;
  }

  Widget _buildButton(
    String text, {
    IconData? icon,
    ButtonType type = ButtonType.number,
    double fontSize = 18,
  }) {
    String actualText = text;
    if (text == 'sin⁻¹') actualText = 'sin';
    if (text == 'cos⁻¹') actualText = 'cos';
    if (text == 'tan⁻¹') actualText = 'tan';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: CalculatorButton(
          text: text,
          icon: icon,
          type: type,
          fontSize: fontSize,
          onPressed: () =>
              _onButtonPressed(actualText == '' ? 'DEL' : actualText),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Mode indicators
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _buildModeChip('RAD', _isRadians, () => _onButtonPressed('RAD'),
                  colorScheme),
              const SizedBox(width: 8),
              _buildModeChip('INV', _isInverse, () => _onButtonPressed('INV'),
                  colorScheme),
            ],
          ),
        ),

        // Display Area
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: _buildDisplay(colorScheme),
          ),
        ),

        // Button Grid - fully responsive
        Expanded(
          flex: 7,
          child: Container(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Row 1 - Scientific functions
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('x²',
                          type: ButtonType.function, fontSize: 14),
                      _buildButton('xʸ',
                          type: ButtonType.function, fontSize: 14),
                      _buildButton(_isInverse ? 'sin⁻¹' : 'sin',
                          type: ButtonType.function, fontSize: 14),
                      _buildButton(_isInverse ? 'cos⁻¹' : 'cos',
                          type: ButtonType.function, fontSize: 14),
                      _buildButton(_isInverse ? 'tan⁻¹' : 'tan',
                          type: ButtonType.function, fontSize: 14),
                    ],
                  ),
                ),
                // Row 2
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('√',
                          type: ButtonType.function, fontSize: 16),
                      _buildButton('10ˣ',
                          type: ButtonType.function, fontSize: 14),
                      _buildButton('log',
                          type: ButtonType.function, fontSize: 14),
                      _buildButton('ln',
                          type: ButtonType.function, fontSize: 14),
                      _buildButton('eˣ',
                          type: ButtonType.function, fontSize: 14),
                    ],
                  ),
                ),
                // Row 3
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('(',
                          type: ButtonType.function, fontSize: 18),
                      _buildButton(')',
                          type: ButtonType.function, fontSize: 18),
                      _buildButton('n!',
                          type: ButtonType.function, fontSize: 14),
                      _buildButton('π',
                          type: ButtonType.function, fontSize: 16),
                      _buildButton('e',
                          type: ButtonType.function, fontSize: 16),
                    ],
                  ),
                ),
                // Row 4
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('C', type: ButtonType.action, fontSize: 18),
                      _buildButton('',
                          icon: Icons.backspace_outlined,
                          type: ButtonType.action),
                      _buildButton('%',
                          type: ButtonType.function, fontSize: 18),
                      _buildButton('÷',
                          type: ButtonType.operator, fontSize: 20),
                      _buildButton('×',
                          type: ButtonType.operator, fontSize: 20),
                    ],
                  ),
                ),
                // Row 5
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('7', fontSize: 20),
                      _buildButton('8', fontSize: 20),
                      _buildButton('9', fontSize: 20),
                      _buildButton('−',
                          type: ButtonType.operator, fontSize: 22),
                      _buildButton('+',
                          type: ButtonType.operator, fontSize: 22),
                    ],
                  ),
                ),
                // Row 6
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('4', fontSize: 20),
                      _buildButton('5', fontSize: 20),
                      _buildButton('6', fontSize: 20),
                      _buildButton('±',
                          type: ButtonType.function, fontSize: 18),
                      _buildButton('=',
                          type: ButtonType.operator, fontSize: 22),
                    ],
                  ),
                ),
                // Row 7
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('1', fontSize: 20),
                      _buildButton('2', fontSize: 20),
                      _buildButton('3', fontSize: 20),
                      _buildButton('0', fontSize: 20),
                      _buildButton('.', fontSize: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeChip(String label, bool isActive, VoidCallback onTap,
      ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color:
                isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildDisplay(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Text(
              _expression.isEmpty ? '0' : _expression,
              style: TextStyle(
                fontSize: _calculated ? 14 : 24,
                fontWeight: FontWeight.w500,
                color: _calculated
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface,
              ),
            ),
          ),
          if (_calculated && _result.isNotEmpty) ...[
            const SizedBox(height: 0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                '= $_result',
                style: TextStyle(
                  fontSize: 24,
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
