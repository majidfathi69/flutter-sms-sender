import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:io';
import 'package:path/path.dart';
import 'package:excel/excel.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  static const platform = MethodChannel('sendSms');

  readXLSXFile() {
    var file = '/Users/majid/Projects/sen_sms/lib/assets/test.xlsx';
    var bytes = File(file).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      if (kDebugMode) {
        print(table);
        //sheet Name
        print(excel.tables[table]?.maxCols);
        print(excel.tables[table]?.maxRows);
      }
      for (var row in excel.tables[table]!.rows) {
        if (kDebugMode) {
          print('${row[0]!.value}');
          print(row[1]!.value.toString());
          print('${row[2]!.value}');
        }
      }
    }
  }

  Future<void> sendSms() async {
    if (kDebugMode) {
      print("SendSMS");
    }
    try {
      final String result = await platform.invokeMethod(
          'send', <String, dynamic>{
        "phone": "09199795867",
        "msg": "Hello! I'm sent programatically."
      }); //Replace a 'X' with 10 digit phone number
      if (kDebugMode) {
        print(result);
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => readXLSXFile(),
                child: const Text('test xlsx file'),
              ),
              ElevatedButton(
                onPressed: () => sendSms(),
                child: const Text("Send SMS"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
