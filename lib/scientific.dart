import 'dart:math' as math;
import 'package:calculator/history.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class Scientific extends StatefulWidget {
  const Scientific({super.key});

  @override
  State<Scientific> createState() => _ScientificState();
}

class _ScientificState extends State<Scientific> {
String expression = "";  
String result = "";      

  buildbutton(text, color, [textcolor = Colors.white]) {
    return ElevatedButton(
      onPressed: () {
        if (text == 'C') {
          setState(() {
            expression = '';
            result = '';
          });
        } else if (text == 'DEL') {
          if (expression.isNotEmpty) {
            setState(() {
              expression = expression.substring(0, expression.length - 1);
            });
          }
        }
        // Special mappings
        else if (text == "x²") {
          setState(() {
            expression += "^2";
          });
        } else if (text == "xʸ") {
          setState(() {
            expression += "^";
          });
        } else if (text == "√x") {
          setState(() {
            expression += "sqrt(";
          });
        } else if (text == "x") {
          setState(() {
            expression += "*";
          });
        } else if (text == "\u00F7") {
          setState(() {
            expression += "/";
          });
        } else if (text == "π") {
          setState(() {
            expression += "pi";
          });
        } else if (text == "sin") {
          setState(() {
            expression += "sin(";
          });
        } else if (text == "cos") {
          setState(() {
            expression += "cos(";
          });
        } else if (text == "tan") {
          setState(() {
            expression += "tan(";
          });
        } else if (text == "log") {
          setState(() {
            expression += "log(10, ";
          });
        } else if (text == "ln") {
          setState(() {
            expression += "ln(";
          });
        } else if (text == "n!") {
          //4!=24 (1*2*3*4)
          int factorial = 1;
          int? string_expression = int.tryParse(expression);
          if (expression.contains(RegExp(r'^[0-9]+$'))) {
            for (int i = 2; i <= string_expression!; i++) {
              factorial *= i;
            }
            setState(() {
              expression = factorial.toString();
              factorial = 1;
            });
          } else {
            var opp_expression = '';
            var corr_expression = '';

            for (int i = expression.length - 1; i >= 0; i--) {
              if (RegExp(r'^[0-9]+$').hasMatch(expression[i])) {
                opp_expression += expression[i];
              } else {
                break;
              }
            }

            for (int j = opp_expression.length - 1; j >= 0; j--) {
              corr_expression += opp_expression[j];
            }

            int? string_corr_expression = int.tryParse(corr_expression);

            if (string_corr_expression != null) {
              for (int i = 2; i <= string_corr_expression; i++) {
                factorial *= i;
              }

              setState(() {
                //cut based on length of corr_expression, not its value.
                expression = expression.substring(0, expression.length - corr_expression.length);
                expression += factorial.toString();
              });
            }
          }
        } else if (text == "e") {
          setState(() {
            // Check if we need to add multiplication before adding e
            if (expression.isNotEmpty &&
                RegExp(r'[\d)$]').hasMatch(expression[expression.length - 1])) {
              expression += "*e";
            } else {
              expression += "e";
            }
          });
        } else if (text == "exp") {
          setState(() {
            expression += "exp(";
          });
        } else if (text == "10^x") {
          setState(() {
            expression += "10^";
          });
        } else if (text == '+/-') {
          if (expression.isEmpty) return;

          //Find the last number
          var opp_expression = '';
          for (int i = expression.length - 1; i >= 0; i--) {
            if (RegExp(r'[0-9]').hasMatch(expression[i])) {
              opp_expression = expression[i] + opp_expression; // build the number correctly
            } else {
              break;
            }
          }

          if (opp_expression.isEmpty) return; // no number found

          //Find where the number starts in the string
          int startIndex = expression.length - opp_expression.length;

          //Check operator before the number (if any)
          if (startIndex > 0) {
            String before = expression[startIndex - 1];
            if (before == "+") {
              // Change + to -
              setState(() {
                expression = "${expression.substring(0, startIndex - 1)}-$opp_expression";
              });
            } else if (before == "-") {
              // Change - to +
              setState(() {
                expression = "${expression.substring(0, startIndex - 1)}+$opp_expression";
              });
            } else {
              // No operator (e.g. "(6" or at start) → just negate
              int toggled = -int.parse(opp_expression);
              setState(() {
                expression = expression.substring(0, startIndex) + toggled.toString();
              });
            }
          } else {
            // Case: number is at start of expression
            int toggled = -int.parse(opp_expression);
            setState(() {
              expression = toggled.toString();
            });
          }
        }
        // Evaluate
        else if (text == "=") {// Preprocess for %
          List<String> tokens = [];
          String number = '';
          for (int k = 0; k < expression.length; k++) {
            if ("+-*/%".contains(expression[k]) &&
                !(expression[k] == '-' &&
                    (k == 0 || "+-*/%".contains(expression[k - 1])))) {
              if (number.isNotEmpty) {
                tokens.add(number);
              }
              tokens.add(expression[k]);
              number = "";
            } else {
              number += expression[k];
            }
          }
          if (number.isNotEmpty) {
            tokens.add(number);
          }

          // Handle %
          int p = 0;
          while (p < tokens.length) {
            if (tokens[p] == '%') {
              // Get the number before '%'
              double? percentNum = double.tryParse(tokens[p - 1]);
              if (percentNum == null) {
                p++;
                continue;
              }

              // Operator just before this number (if exists)
              String operatorBefore = (p - 2 >= 0) ? tokens[p - 2] : '';

              double computed;

              // Context-aware % calculation
              if (operatorBefore == '+' || operatorBefore == '-') {
                // % = percent of base number (the number before operator)
                double baseNum = (p - 3 >= 0)
                    ? double.tryParse(tokens[p - 3]) ?? 0
                    : 0; //If parsing fails use 0
                computed = baseNum * (percentNum / 100);
              } else if (operatorBefore == '*' || operatorBefore == '/') {
                // % = fraction for multiply/divide
                computed = percentNum / 100;
              } else {
                // Default: treat as fraction
                computed = percentNum / 100;
              }

              // Replace number with computed %, remove '%'
              tokens[p - 1] = computed.toString();
              tokens.removeAt(p);
              // Stay on same index after removal
              continue;
            }
            p++;
          }

          // Reconstruct processed expression
          String processedExpression = tokens.join('');

          try {
            // Preprocess the expression to handle special cases
            String processedexpression = processedExpression;
            // Handle the case where e is followed by a number without operator (e10 -> e*10)
            processedexpression = processedexpression.replaceAllMapped(RegExp(r'e(\d)'), ( match ) {
              return 'e*${match.group(1)}';
            });
            // Handle the case where a number is followed by e without operator (10e -> 10*e)
            processedexpression = processedexpression.replaceAllMapped(RegExp(r'(\d)e'), ( match ) {
              return '${match.group(1)}*e';
            });

            // 1. Create a parser
            Parser p = Parser();

            String expressionToParse = processedexpression.replaceAll('e', math.e.toString());
            Expression exp = p.parse(expressionToParse);

            // // 2. Parse a string expression
            // Expression exp = p.parse(num);

            // 3. Create a context (in case you use variables)
            ContextModel cm = ContextModel();
            //pi is not a built-in keyword string like "pi" thus we need to define it as a variable constant in the ContextModel.
            // cm.bindVariable(Variable('pi'), Number(math.pi));
            cm.bindVariable(Variable('e'), Number(math.e));

            // 4. Evaluate the expression
            setState(() {
              result = exp
                  .evaluate(EvaluationType.REAL, ContextModel())
                  .toString();
                  if (result != "ERROR") {
  history.add("$expression = $result");  // Add to list
  SharedPreferencesHelper.setHistory(history);  // Save
}
            });
          } catch (e) {
            setState(() {
              result = "Error";
            });
          }
        } else {
          setState(() {
            // Check if we need to add multiplication before adding a digit after e
            if (text.length == 1 && RegExp(r'\d').hasMatch(text)) {
              if (expression.isNotEmpty && expression.endsWith('e')) {
                expression += "*$text";
              } else {
                expression += text;
              }
            } else {
              expression += text;
            }
          });
        }
      },

      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(color),
        fixedSize: WidgetStateProperty.all(Size(20, 15)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        ),
      ),
      child: Text(
        text,
        softWrap: false,
        overflow: TextOverflow.visible,
        style: TextStyle(
          color: textcolor,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
    );
  }
dispText(){
  if(result!=""){
    return Column(
      children: [
        Text("$expression", style: TextStyle(color: const Color.fromARGB(255, 72, 59, 59), fontSize: 20, fontWeight: FontWeight.bold),),
        SizedBox(height: 10,),
        Text("$result", style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),)
      ],
    );
  }
  else{
    return Text(
              "$expression",
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            );
  }
}
List<String> history=[];
@override
  void initState(){
    super.initState();
    // history= SharedPreferncesHelper().getHistory();
    history = SharedPreferencesHelper.getHistory() ?? [];
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 130,
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.only(top: 30, right: 30),
            child:dispText()
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.black,
            child: GridView.count(
              crossAxisCount: 5,
              childAspectRatio: 1.13, // Adjusted for better button shape
              mainAxisSpacing: 2, // vertical spacing between buttons
              crossAxisSpacing: 2, // horizontal spacing between buttons
              children: [
                //First Row
                buildbutton("x²", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("xʸ", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("sin", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("cos", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("tan", Color.fromARGB(255, 152, 24, 71)),
                //Second Row
                buildbutton("√x", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("10^x", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("log", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("ln", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("e", Color.fromARGB(255, 152, 24, 71)),
                //Third Row
                buildbutton("exp", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("C", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("DEL", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("%", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("\u00F7", Color.fromARGB(255, 251, 170, 8)),
                //Fourth Row
                buildbutton("π", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("7", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("8", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("9", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("x", Color.fromARGB(255, 251, 170, 8)),
                //Fifth Row
                buildbutton("n!", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("4", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("5", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("6", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("-", Color.fromARGB(255, 251, 170, 8)),
                //Fifth Row
                buildbutton("(", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("1", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("2", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("3", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("+", Color.fromARGB(255, 251, 170, 8)),
                //Sixth Row
                buildbutton(")", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("+/-", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("0", Color.fromARGB(255, 190, 138, 157)),
                buildbutton(".", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("=", Color.fromARGB(255, 251, 170, 8)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
