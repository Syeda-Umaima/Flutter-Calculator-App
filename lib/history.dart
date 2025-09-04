import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper{  
  static SharedPreferences? _sharedPreferences;

  static Future<void> init() async{
    _sharedPreferences ??= await SharedPreferences.getInstance(); //if sharedPreferences is null, initialize it
  }

  static Future<bool> setHistory(List<String> history){
    return _sharedPreferences!.setStringList('history', history);  
  }

  static List<String>? getHistory(){
    return _sharedPreferences!.getStringList('history') ?? []; // Return empty list if null
  }
}
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> history=[];

  @override
  void initState(){
    super.initState();
    history= SharedPreferencesHelper.getHistory() ?? [];
  }
  @override
  Widget build(BuildContext context) {
    //history = [    "1+2 = 3",    // index 0
                //   "4*5 = 20",   // index 1
                //   "6-3 = 3",    // index 2
                //   "10/2 = 5"    // index 3
                // ];
    final reversedHistory= List.from(history.reversed);
//     reversedHistory = [
//   "10/2 = 5",   // displayed at index 0
//   "6-3 = 3",    // displayed at index 1
//   "4*5 = 20",   // displayed at index 2
//   "1+2 = 3"     // displayed at index 3
// ];
    return ListView.builder(
      itemCount: reversedHistory.length,
      itemBuilder: 
    (context, index){

      final entry= reversedHistory[index];
      final parts=entry.split(' = ');
      final expression=parts.length>0?parts[0].trim():'';
      final result=parts.length>1?parts[1].trim():'';

      return ListTile(
        leading: IconButton(
          icon: Icon(Icons.delete, color: Colors.black),
          onPressed: () {
            setState(() {
              //if user deletes the item at UI index 2 (which is "4*5 = 20"):
              history.removeAt(history.length - 1 - index); // Adjust index for reversed list (4 - 1 - 2 = 1 got removed)
              SharedPreferencesHelper.setHistory(history); // Update storage
            });
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(expression, style: TextStyle(fontSize: 18,),),
            SizedBox(height: 4,),
            Text('= $result', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
            Divider(), //for Horizontal line
          ],
        )
      );
    });
  }
}