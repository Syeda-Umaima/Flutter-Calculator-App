import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/calculator_button.dart';
import '../utils/calculator_engine.dart';
import '../utils/shared_prefs_helper.dart';

class BasicCalculator extends StatefulWidget {
  const BasicCalculator({super.key});

  @override
  State<BasicCalculator> createState() => _BasicCalculatorState();
}

class _BasicCalculatorState extends State<BasicCalculator> {
  String _expression = '';
  String _result = '';
  bool _calculated = false;

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
            _expression = _expression.substring(0, _expression.length - 1);
            _result = '';
            _calculated = false;
          }
          break;
          
        case '=':
          if (_expression.isNotEmpty) {
            _result = CalculatorEngine.evaluateBasic(_expression);
            _calculated = true;
            
            if (_result != 'Error') {
              SharedPrefsHelper.addToHistory('$_expression = $_result');
            }
          }
          break;
          
        case '±':
          _toggleSign();
          break;
          
        default:
          _appendValue(value);
      }
    });
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
        _expression = '${_expression.substring(0, startIndex - 1)}−$lastNum';
      } else if (before == '−') {
        _expression = '${_expression.substring(0, startIndex - 1)}+$lastNum';
      } else {
        double toggled = -double.parse(lastNum);
        _expression = _expression.substring(0, startIndex) + 
            (toggled >= 0 ? toggled.toString() : '(${toggled.toString()})');
      }
    } else {
      double toggled = -double.parse(lastNum);
      _expression = toggled >= 0 ? toggled.toString() : '(${toggled.toString()})';
    }
    
    _result = '';
    _calculated = false;
  }

  void _appendValue(String value) {
    if (_calculated && !_isOperator(value)) {
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

    if (_isOperator(value) && _expression.isNotEmpty) {
      String last = _expression[_expression.length - 1];
      if (_isOperator(last.toString())) {
        _expression = _expression.substring(0, _expression.length - 1) + value;
        return;
      }
    }

    if (value == '.') {
      String lastNumber = _getLastNumber();
      if (lastNumber.contains('.')) return;
      if (_expression.isEmpty || _isOperator(_expression[_expression.length - 1])) {
        _expression += '0';
      }
    }

    _expression += value;
    _result = '';
    _calculated = false;
  }

  bool _isOperator(String char) {
    return '+-×÷%−'.contains(char);
  }

  String _getLastNumber() {
    String number = '';
    for (int i = _expression.length - 1; i >= 0; i--) {
      if (RegExp(r'[0-9.]').hasMatch(_expression[i])) {
        number = _expression[i] + number;
      } else {
        break;
      }
    }
    return number;
  }

  void _onClearLongPress() {
    HapticFeedback.heavyImpact();
    setState(() {
      _expression = '';
      _result = '';
      _calculated = false;
    });
  }

  Widget _buildButton(String text, {
    IconData? icon,
    ButtonType type = ButtonType.number,
    double fontSize = 24,
    VoidCallback? onLongPress,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: CalculatorButton(
          text: text,
          icon: icon,
          type: type,
          fontSize: fontSize,
          onPressed: () => _onButtonPressed(text == '' ? 'DEL' : text),
          onLongPress: onLongPress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Display Area - takes remaining space after buttons
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: CalculatorDisplay(
              expression: _expression,
              result: _result,
              showResult: _calculated,
            ),
          ),
        ),
        
        // Button Grid - uses Expanded rows to fit all buttons on screen
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                // Row 1: C, DEL, %, ÷
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('C', type: ButtonType.action, onLongPress: _onClearLongPress),
                      _buildButton('', icon: Icons.backspace_outlined, type: ButtonType.action),
                      _buildButton('%', type: ButtonType.function),
                      _buildButton('÷', type: ButtonType.operator, fontSize: 28),
                    ],
                  ),
                ),
                // Row 2: 7, 8, 9, ×
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('7'),
                      _buildButton('8'),
                      _buildButton('9'),
                      _buildButton('×', type: ButtonType.operator, fontSize: 28),
                    ],
                  ),
                ),
                // Row 3: 4, 5, 6, −
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('4'),
                      _buildButton('5'),
                      _buildButton('6'),
                      _buildButton('−', type: ButtonType.operator, fontSize: 28),
                    ],
                  ),
                ),
                // Row 4: 1, 2, 3, +
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('1'),
                      _buildButton('2'),
                      _buildButton('3'),
                      _buildButton('+', type: ButtonType.operator, fontSize: 28),
                    ],
                  ),
                ),
                // Row 5: ±, 0, ., =
                Expanded(
                  child: Row(
                    children: [
                      _buildButton('±', type: ButtonType.function),
                      _buildButton('0'),
                      _buildButton('.'),
                      _buildButton('=', type: ButtonType.operator, fontSize: 28),
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
}
