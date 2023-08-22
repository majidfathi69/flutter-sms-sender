import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:get/get.dart';

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

  final total = 0.obs;
  final count = 0.obs;
  final cPhone = 'cPhone'.obs;
  final cMsg = 'cMsg'.obs;
  bool stop = false;
  final delayed = 0.obs;

  uploadXlsxFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      readXLSXFile(file);
    } else {
      // User canceled the picker
    }
  }

  readXLSXFile(File file) async {
    // var fileAddr = '/Users/majid/Projects/sen_sms/lib/assets/test.xlsx';
    // var bytes = File(fileAddr).readAsBytesSync();
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      if (kDebugMode) {
        print(table);
        //sheet Name
        print(excel.tables[table]?.maxCols);
        print(excel.tables[table]?.maxRows);
      }

      total.value = excel.tables[table]!.maxRows;
      for (var row in excel.tables[table]!.rows) {
        if (kDebugMode) {
          print('${row[0]!.value}');
          print(row[1]!.value.toString());
          print('${row[2]!.value}');
        }
        String phone = row[0]!.value.toString();
        String msg = row[1]!.value.toString();
        int delay = row[2]!.value;

        cMsg.value = msg;
        cPhone.value = phone;
        if (stop) {
          stop = false;
          return;
        }
        sendSms(phone, msg);
        var counter = delay;

        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (kDebugMode) {
            print(timer.tick);
          }
          counter--;
          delayed.value = counter;
          if (counter == 0) {
            if (kDebugMode) {
              print('Cancel timer');
            }
            timer.cancel();
          }
        });
        await Future.delayed(Duration(seconds: delay));
      }
    }
  }

  Future<void> sendSms(String phone, String msg) async {
    if (kDebugMode) {
      print("SendSMS");
    }
    try {
      final String result =
          await platform.invokeMethod('send', <String, dynamic>{
        "phone": phone,
        "msg": msg,
      });
      count.value += 1;
      if (kDebugMode) {
        print(result);
      }
    } on PlatformException catch (e) {
      Get.snackbar(
        'error',
        e.toString(),
        colorText: Colors.red,
        backgroundColor: Colors.lightBlue,
        icon: const Icon(Icons.add_alert),
      );
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      total.value = 0;
                      count.value = 0;
                      uploadXlsxFile();
                    },
                    child: const Text('upload xlsx file'),
                  ),
                  const SizedBox(width: 50),
                  ElevatedButton(
                    onPressed: () {
                      stop = true;
                    },
                    child: const Text('Stop'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Obx(() => Text('${count.value} / ${total.value}')),
              const SizedBox(height: 20),
              Obx(() => Text('next: ${delayed.value}')),
              const SizedBox(height: 20),
              Obx(
                () => Column(
                  children: [
                    Row(
                      children: [
                        const Text('Current: '),
                        Text(cPhone.value),
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 50,
                      child: Text(
                        cMsg.value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
