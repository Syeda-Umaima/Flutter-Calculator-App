import 'dart:math' as math;

class CalculatorEngine {
  /// Evaluates a basic mathematical expression
  /// Supports: +, -, ×, ÷, %
  static String evaluateBasic(String expression) {
    if (expression.isEmpty) return '';
    
    try {
      // Replace display symbols with calculation symbols
      String exp = expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('−', '-');
      
      // Tokenize the expression
      List<String> tokens = _tokenize(exp);
      
      // Handle percentage
      tokens = _handlePercentage(tokens);
      
      // Evaluate multiplication and division first
      tokens = _evaluateMultDiv(tokens);
      
      // Evaluate addition and subtraction
      String result = _evaluateAddSub(tokens);
      
      return _formatResult(result);
    } catch (e) {
      return 'Error';
    }
  }
  
  /// Tokenizes the expression into numbers and operators
  static List<String> _tokenize(String expression) {
    List<String> tokens = [];
    String number = '';
    
    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];
      
      if ('+-*/%'.contains(char)) {
        // Handle negative numbers at start or after operator
        if (char == '-' && (i == 0 || '+-*/%'.contains(expression[i - 1]))) {
          number += char;
        } else {
          if (number.isNotEmpty) {
            tokens.add(number);
            number = '';
          }
          tokens.add(char);
        }
      } else {
        number += char;
      }
    }
    
    if (number.isNotEmpty) {
      tokens.add(number);
    }
    
    return tokens;
  }
  
  /// Handles percentage calculations
  static List<String> _handlePercentage(List<String> tokens) {
    int i = 0;
    while (i < tokens.length) {
      if (tokens[i] == '%') {
        if (i > 0) {
          double? percentNum = double.tryParse(tokens[i - 1]);
          if (percentNum != null) {
            String operatorBefore = (i - 2 >= 0) ? tokens[i - 2] : '';
            double computed;
            
            if (operatorBefore == '+' || operatorBefore == '-') {
              double baseNum = (i - 3 >= 0) ? double.tryParse(tokens[i - 3]) ?? 0 : 0;
              computed = baseNum * (percentNum / 100);
            } else {
              computed = percentNum / 100;
            }
            
            tokens[i - 1] = computed.toString();
            tokens.removeAt(i);
            continue;
          }
        }
      }
      i++;
    }
    return tokens;
  }
  
  /// Evaluates multiplication and division
  static List<String> _evaluateMultDiv(List<String> tokens) {
    int i = 0;
    while (i < tokens.length) {
      if (tokens[i] == '*' || tokens[i] == '/') {
        double num1 = double.parse(tokens[i - 1]);
        double num2 = double.parse(tokens[i + 1]);
        
        double result;
        if (tokens[i] == '*') {
          result = num1 * num2;
        } else {
          if (num2 == 0) throw Exception('Division by zero');
          result = num1 / num2;
        }
        
        tokens[i - 1] = result.toString();
        tokens.removeAt(i);
        tokens.removeAt(i);
        continue;
      }
      i++;
    }
    return tokens;
  }
  
  /// Evaluates addition and subtraction
  static String _evaluateAddSub(List<String> tokens) {
    int i = 0;
    while (i < tokens.length) {
      if (tokens[i] == '+' || tokens[i] == '-') {
        double num1 = double.parse(tokens[i - 1]);
        double num2 = double.parse(tokens[i + 1]);
        
        double result = tokens[i] == '+' ? num1 + num2 : num1 - num2;
        
        tokens[i - 1] = result.toString();
        tokens.removeAt(i);
        tokens.removeAt(i);
        continue;
      }
      i++;
    }
    return tokens.isNotEmpty ? tokens[0] : '0';
  }
  
  /// Formats the result for display
  static String _formatResult(String result) {
    double? value = double.tryParse(result);
    if (value == null) return result;
    
    // Check if the result is an integer
    if (value == value.toInt().toDouble()) {
      return value.toInt().toString();
    }
    
    // Limit decimal places to 10
    String formatted = value.toStringAsFixed(10);
    
    // Remove trailing zeros
    formatted = formatted.replaceAll(RegExp(r'0+$'), '');
    formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    
    return formatted;
  }
  
  /// Scientific calculator functions
  static double sin(double value, {bool isDegrees = true}) {
    if (isDegrees) value = value * math.pi / 180;
    return math.sin(value);
  }
  
  static double cos(double value, {bool isDegrees = true}) {
    if (isDegrees) value = value * math.pi / 180;
    return math.cos(value);
  }
  
  static double tan(double value, {bool isDegrees = true}) {
    if (isDegrees) value = value * math.pi / 180;
    return math.tan(value);
  }
  
  static double log10(double value) {
    return math.log(value) / math.ln10;
  }
  
  static double ln(double value) {
    return math.log(value);
  }
  
  static double sqrt(double value) {
    return math.sqrt(value);
  }
  
  static double power(double base, double exponent) {
    return math.pow(base, exponent).toDouble();
  }
  
  static int factorial(int n) {
    if (n < 0) throw Exception('Factorial of negative number');
    if (n <= 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }
  
  static double exp(double value) {
    return math.exp(value);
  }
}

/// Unit conversion utilities
class UnitConverter {
  // Length conversions (base: meters)
  static const Map<String, double> lengthUnits = {
    'Millimeter': 0.001,
    'Centimeter': 0.01,
    'Meter': 1.0,
    'Kilometer': 1000.0,
    'Inch': 0.0254,
    'Foot': 0.3048,
    'Yard': 0.9144,
    'Mile': 1609.344,
  };
  
  // Weight conversions (base: kilograms)
  static const Map<String, double> weightUnits = {
    'Milligram': 0.000001,
    'Gram': 0.001,
    'Kilogram': 1.0,
    'Pound': 0.453592,
    'Ounce': 0.0283495,
    'Ton': 1000.0,
  };
  
  // Volume conversions (base: liters)
  static const Map<String, double> volumeUnits = {
    'Milliliter': 0.001,
    'Liter': 1.0,
    'Gallon (US)': 3.78541,
    'Quart': 0.946353,
    'Pint': 0.473176,
    'Cup': 0.236588,
  };
  
  // Area conversions (base: square meters)
  static const Map<String, double> areaUnits = {
    'Sq Centimeter': 0.0001,
    'Sq Meter': 1.0,
    'Sq Kilometer': 1000000.0,
    'Sq Inch': 0.00064516,
    'Sq Foot': 0.092903,
    'Acre': 4046.86,
    'Hectare': 10000.0,
  };
  
  // Speed conversions (base: meters per second)
  static const Map<String, double> speedUnits = {
    'm/s': 1.0,
    'km/h': 0.277778,
    'mph': 0.44704,
    'knots': 0.514444,
    'ft/s': 0.3048,
  };
  
  // Time conversions (base: seconds)
  static const Map<String, double> timeUnits = {
    'Millisecond': 0.001,
    'Second': 1.0,
    'Minute': 60.0,
    'Hour': 3600.0,
    'Day': 86400.0,
    'Week': 604800.0,
    'Month': 2592000.0,
    'Year': 31536000.0,
  };
  
  // Data conversions (base: bytes)
  static const Map<String, double> dataUnits = {
    'Bit': 0.125,
    'Byte': 1.0,
    'Kilobyte': 1024.0,
    'Megabyte': 1048576.0,
    'Gigabyte': 1073741824.0,
    'Terabyte': 1099511627776.0,
  };
  
  static double convert(double value, String fromUnit, String toUnit, Map<String, double> units) {
    if (!units.containsKey(fromUnit) || !units.containsKey(toUnit)) {
      throw Exception('Unknown unit');
    }
    
    double baseValue = value * units[fromUnit]!;
    return baseValue / units[toUnit]!;
  }
  
  static double convertTemperature(double value, String from, String to) {
    // Convert to Celsius first
    double celsius;
    switch (from) {
      case 'Celsius':
        celsius = value;
        break;
      case 'Fahrenheit':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'Kelvin':
        celsius = value - 273.15;
        break;
      default:
        throw Exception('Unknown temperature unit');
    }
    
    // Convert from Celsius to target
    switch (to) {
      case 'Celsius':
        return celsius;
      case 'Fahrenheit':
        return celsius * 9 / 5 + 32;
      case 'Kelvin':
        return celsius + 273.15;
      default:
        throw Exception('Unknown temperature unit');
    }
  }
  
  static String formatResult(double value) {
    if (value == value.toInt().toDouble()) {
      return value.toInt().toString();
    }
    
    String formatted = value.toStringAsFixed(6);
    formatted = formatted.replaceAll(RegExp(r'0+$'), '');
    formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    
    return formatted;
  }
}
