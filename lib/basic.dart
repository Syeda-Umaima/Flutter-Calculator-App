import 'package:calculator/history.dart';
import 'package:flutter/material.dart';

class basic extends StatefulWidget {
  const basic({Key? key}) : super(key: key);

  @override
  State<basic> createState() => _basicState();
}

class _basicState extends State<basic> {
  var expression = "";
  var result = "";

  buildbutton(txt, color, [txtcolor = Colors.white]) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: ElevatedButton(
        onPressed: () async {
          if (txt == "C") {
            setState(() {
              expression = '';
              result = '';
            });
          } else if (txt == "DEL") {
            if (expression.isNotEmpty) {
              setState(() {
                expression = expression.substring(0, expression.length - 1);
              });
            }
          } else if (txt == '+/-') {
            if (expression.isEmpty) return;

            // Extract last number (with decimals if any)
            var lastNum = '';
            for (int i = expression.length - 1; i >= 0; i--) {
              if (RegExp(r'[0-9.]').hasMatch(expression[i])) {
                lastNum = expression[i] + lastNum; // build no. correctly
              } else {
                break;
              }
            }

            if (lastNum.isEmpty) return;

            int startIndex = expression.length - lastNum.length;

            // Check what comes before the number
            if (startIndex > 0) {
              String before = expression[startIndex - 1];
              if (before == "+") {
                // Change + to -
                setState(() {
                  expression =
                      "${expression.substring(0, startIndex - 1)}-$lastNum";
                });
              } else if (before == "-") {
                // Change - to +
                setState(() {
                  expression =
                      "${expression.substring(0, startIndex - 1)}+$lastNum";
                });
              } else {
                // Replace number with its negated value
                double toggled = -double.parse(lastNum);
                setState(() {
                  expression =
                      expression.substring(0, startIndex) + toggled.toString();
                });
              }
            } else {
              // Case: number is at start
              double toggled = -double.parse(lastNum);
              setState(() {
                expression = toggled.toString();
              });
            }
          } else if (txt == "=") {
            //TOKENIZING
            List<String> tokens = [];
            String number = '';

            for (int i = 0; i < expression.length; i++) {
              if ("+-x\u00F7%".contains(expression[i]) &&
                  !(expression[i] == '-' &&
                      (i == 0 || "+-x\u00F7%".contains(expression[i - 1])))) {
                tokens.add(number);
                tokens.add(expression[i]);
                number = "";
              } else {
                number += expression[i];
              }
            }
            tokens.add(number);

            // %
            int p = 0;
            while (p < tokens.length) {
              if (tokens[p] == '%') {
                //tokens = ["200", "+", "10", "%"] indexes: 200=0, +=1, 10=2, %=3
                // Get the number before '%'
                double? percentNum = double.tryParse(tokens[p - 1]);
                if (percentNum == null) {
                  p++;
                  continue;
                }
                // i-1 = 2 → tokens[2] = "10"
                // percentNum = 10.0

                // Operator just before this number (if exists)
                String operatorBefore = (p - 2 >= 0) ? tokens[p - 2] : '';
                // i-2 = 1 → tokens[1] = "+"

                double computed;

                // Context-aware % calculation
                if (operatorBefore == '+' || operatorBefore == '-') {
                  // % = percent of base number (the number before operator)
                  double baseNum = (p - 3 >= 0)
                      ? double.tryParse(tokens[p - 3]) ?? 0
                      : 0; //If parsing fails use 0
                  // i-3 = 0 → tokens[0] = "200"
                  // baseNum = 200.0
                  computed = baseNum * (percentNum / 100);
                } else if (operatorBefore == 'x' ||
                    operatorBefore == '\u00F7') {
                  // % = fraction for multiply/divide
                  computed = percentNum / 100; // 10 / 100 = 0.1
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

            // * and /
            int i = 0;
            while (i < tokens.length) {
              if (tokens[i] == 'x') {
                double? num1 = double.tryParse(tokens[i - 1]);
                double? num2 = double.tryParse(tokens[i + 1]);
                result = (num1! * num2!).toString();
                tokens[i - 1] = result;
                tokens.removeAt(i);
                tokens.removeAt(i);
                continue;
              }

              if (tokens[i] == '\u00F7') {
                double? num1 = double.tryParse(tokens[i - 1]);
                double? num2 = double.tryParse(tokens[i + 1]);
                if (num2 == 0) {
                  result = "ERROR";
                  expression = "";
                  break;
                } else {
                  result = (num1! / num2!).toString();
                }
                tokens[i - 1] = result;
                tokens.removeAt(i);
                tokens.removeAt(i);
                continue;
              }
              i++;
            }

            // + and -
            int j = 0;
            while (j < tokens.length) {
              if (tokens[j] == '+') {
                double? num1 = double.tryParse(tokens[j - 1]);
                double? num2 = double.tryParse(tokens[j + 1]);
                result = (num1! + num2!).toString();
                tokens[j - 1] = result;
                tokens.removeAt(j);
                tokens.removeAt(j);
                continue;
              }

              if (tokens[j] == '-') {
                double? num1 = double.tryParse(tokens[j - 1]);
                double? num2 = double.tryParse(tokens[j + 1]);
                result = (num1! - num2!).toString();
                tokens[j - 1] = result;
                tokens.removeAt(j);
                tokens.removeAt(j);
                continue;
              }
              j++;
            }
            setState(() {
              result = result.toString();
              if (result != "ERROR") {
  history.add("$expression = $result");  // Add to list
  SharedPreferencesHelper.setHistory(history);  // Save
}
            });
          } else {
            setState(() {
              if (result.isNotEmpty) {
                if ("+-x\u00F7%".contains(txt)) {
                  // Continue calculation from result
                  expression = result + txt;
                  result = "";
                } else {
                  // Restart fresh
                  expression = txt;
                  result = "";
                }
              } else {
                expression += txt;
              }
            });
          }
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(color),
          fixedSize: WidgetStateProperty.all(Size(20, 15)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
          ),
        ),
        child: Text(
          txt,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: TextStyle(
            color: txtcolor,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  dispText() {
    if (result != "") {
      return Column(
        children: [
          Text(
            "$expression",
            style: TextStyle(
              color: const Color.fromARGB(255, 72, 59, 59),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "$result",
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
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

  // To handle single operators
  // if (txt == "=") {
  //   List<String> add_parts = num.split('+');
  //   List<String> sub_parts = num.split('-');
  //   List<String> mul_parts = num.split('x');
  //   List<String> div_parts = num.split('/');

  //   if (add_parts.length == 2) {
  //     int? num1 = int.tryParse(add_parts[0]);
  //     int? num2 = int.tryParse(add_parts[1]);

  //     result = (num1! + num2!);
  //   }

  //   if (sub_parts.length == 2) {
  //     int? num1 = int.tryParse(sub_parts[0]);
  //     int? num2 = int.tryParse(sub_parts[1]);

  //     result = (num1! - num2!);
  //   }

  //   if (mul_parts.length == 2) {
  //     int? num1 = int.tryParse(mul_parts[0]);
  //     int? num2 = int.tryParse(mul_parts[1]);

  //     result = (num1! * num2!);
  //   }

  //   if (div_parts.length == 2) {
  //     double? num1 = double.tryParse(div_parts[0]);
  //     double? num2 = double.tryParse(div_parts[1]);

  //     result = (num1! / num2!);
  //   }

  //   setState(() {
  //     num = result.toString();
  //   });
  // }
  // }
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
            child: dispText(),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.black,
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 1.14,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              padding: EdgeInsets.all(8),
              children: [
                buildbutton("C", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("DEL", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("%", Color.fromARGB(255, 152, 24, 71)),
                buildbutton("\u00F7", Color.fromARGB(255, 251, 170, 8)),
                buildbutton("7", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("8", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("9", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("x", Color.fromARGB(255, 251, 170, 8)),
                buildbutton("4", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("5", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("6", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("-", Color.fromARGB(255, 251, 170, 8)),
                buildbutton("1", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("2", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("3", Color.fromARGB(255, 190, 138, 157)),
                buildbutton("+", Color.fromARGB(255, 251, 170, 8)),
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
