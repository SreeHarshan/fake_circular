import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:http/http.dart' as HTTP;
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:convert' as convert;

import 'check.dart';
import 'create.dart';
import 'global.dart' as global;
import 'global.dart';
import 'login.dart';

Future<void> main() async {
  await FlutterDownloader.initialize(
      debug:
          true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl:
          true // option: set to false to disable working with http links (default: false)
      );
  runApp(const MyApp());
}

/*
Future<void> main() async {
  await FlutterDownloader.initialize(
      debug:
          true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl:
          true // option: set to false to disable working with http links (default: false)
      );
  runApp(DevicePreview(builder: (context) => const MyApp()));
}
*/
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
              color: Colors.white,
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
  // ignore: non_constant_identifier_names
  String pdf_path = "Select file", name = "";

  // ignore: non_constant_identifier_names
  Future<void> select_file() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      File file = File((result.files.single.path)!);
      pdf_path = file.path;
      name = path.basename(file.path);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Selected file:" + name),
        backgroundColor: Colors.green,
      ));
    }
  }

  Future<int> _upload() async {
    if (pdf_path != "Select file") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("uploading file " + name),
        backgroundColor: Colors.green,
      ));
      global.buildShowDialog(context);
      String api = global.server_address + "/upload";
      var uri = Uri.parse(api);
      var request = HTTP.MultipartRequest("POST", uri);
      request.files.add(await HTTP.MultipartFile.fromPath('file', pdf_path));
      var res = await request.send();
      res.stream.transform(utf8.decoder).listen((value) {
        print(value);
      });
      pdf_path = "Select file";
      return res.statusCode;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a valid file'),
        backgroundColor: Colors.red,
      ));
      return 0;
    }
  }

  Future<void> _create() async {
    if (login.value == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You need to login to add circular'),
        backgroundColor: Colors.red,
      ));
    } else {
      //upload pdf and go to create circular page
      int res = 0;
      try {
        res = await _upload();
      } on Exception catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('There was an issue in server'),
          backgroundColor: Colors.red,
        ));
      }

      if (res == 200 || res == 302) {
        print("create page");
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Create(
                      fname: name,
                    )));
      }
    }
  }

  Future<void> _qr() async {
    //upload file to db
    int res = 0;
    int rnum = 0;
    try {
      res = await _upload();
      //calculate the rno
      name = name.replaceAll(" ", "_");
      print(name);
      String api = global.server_address + "/decodeQR?fname=$name";
      var uri = Uri.parse(api);
      var response = await HTTP.get(uri);
      if (response.statusCode == 200) {
        var jsonResponse =
            convert.jsonDecode(response.body) as Map<String, dynamic>;
        rnum = int.parse(jsonResponse["value"]);
      } else {
        print("bad response");
      }
    } on Exception catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('There was an issue in server'),
        backgroundColor: Colors.red,
      ));
    }

    //Delete the file path
    if (res == 200 || res == 302 && rnum != 0) {
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Check_page(
                    rno: rnum,
                  )));
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Unable to upload the pdf'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Fake Circular Detector"),
          actions: <Widget>[
            Center(
                child: ValueListenableBuilder(
                    valueListenable: global.login,
                    builder: (context, value, child) {
                      return Text(value == 0 ? "Student" : "Instituite");
                    })),
            IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Login()));
                },
                icon: const Icon(Icons.school))
          ],
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
              child: Text(pdf_path,
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                  )),
              onTap: () => select_file(),
            ),
            const SizedBox(
              height: 15,
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
              onTap: () => _qr(),
            ),
            const SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              child: Container(
                width: 150.0,
                height: 50.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Theme.of(context).colorScheme.secondary),
                child: const Center(
                  child: Text("Create"),
                ),
              ),
              onTap: () => _create(),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        )));
  }
}
