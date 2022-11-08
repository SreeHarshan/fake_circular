import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:http/http.dart' as HTTP;
import 'dart:convert' as convert;

import 'check.dart';
import 'global.dart';

/*
void main() {
  runApp(const MyApp());
}
*/

void main() => runApp(DevicePreview(builder: (context) => const MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Fake circular detector',
        theme: ThemeData.light(),
        darkTheme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            color: Colors.blue,
            iconTheme: IconThemeData(
              color: Colors.blue,
            ),
          ),
          colorScheme: const ColorScheme.dark(
            primary: Colors.blue,
            onPrimary: Colors.blue,
            primaryVariant: Colors.blue,
            secondary: Colors.blueAccent,
          ),
          cardTheme: const CardTheme(
            color: Colors.black,
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        home: const MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String pdf_path = "Select file", name = "";

  // ignore: non_constant_identifier_names
  Future<void> select_file() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      File file = File((result.files.single.path)!);
      pdf_path = file.toString();
      name = path.basename(file.path);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Selected file:" + name),
        backgroundColor: Colors.green,
      ));
    }
  }

  Future<void> _upload() async {
    if (pdf_path != "Select file") {
      // Change to !=
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("uploading file " + name),
        backgroundColor: Colors.green,
      ));
      buildShowDialog(context);

      //upload file to db
      var uri = Uri.parse(server_address + "/upload");
      var request = HTTP.MultipartRequest("POST", uri);
      request.files.add(await HTTP.MultipartFile.fromPath(name, pdf_path));
      var res = await request.send();

      //Delete the file path
      pdf_path = "Select file";

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Check_page()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a file'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Fake Circular Detector"),
        ),
        body: Center(
            child: Column(
          children: <Widget>[
            const Text(
              "Upload the circular",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              child: Text(pdf_path),
              onTap: () => select_file(),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              child: Container(
                width: 150.0,
                height: 50.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Theme.of(context).colorScheme.secondary),
                child: const Center(
                  child: Text("Upload"),
                ),
              ),
              onTap: () => _upload(),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        )));
  }
}
