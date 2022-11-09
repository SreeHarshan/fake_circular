import 'dart:io';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as HTTP;
import 'dart:convert' as convert;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'global.dart';

class Create extends StatefulWidget {
  String fname;
  Create({Key? key, required this.fname}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _createpage(fname);
}

// ignore: camel_case_types
class _createpage extends State<Create> {
  @override
  void initState() {
    super.initState();

    initPlatformState();
  }

  late String path;
  Future<void> initPlatformState() async {
    _setPath();
    if (!mounted) return;
  }

  void _setPath() async {
    Directory _path = await getApplicationDocumentsDirectory();
    String _localPath = _path.path + Platform.pathSeparator + 'Download';
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    path = _localPath;
  }

  String name;
  _createpage(this.name);
  int no = 0;
  String date = "", title = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController dateController = TextEditingController();
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));
    if (pickedDate != null) {
      print(pickedDate);
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      date = formattedDate;

      setState(() {
        dateController.text = formattedDate;
      });
    } else {
      print("Date is not selected");
    }
  }

  Future<String> downloadFile(String url, String fileName, String dir) async {
    HttpClient httpClient = HttpClient();
    File file;
    String filePath = '';
    String myUrl = '';

    try {
      myUrl = url + '/' + fileName;
      var request = await httpClient.getUrl(Uri.parse(myUrl));
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '$dir/$fileName';
        file = File(filePath);
        await file.writeAsBytes(bytes);
      } else
        filePath = 'Error code: ' + response.statusCode.toString();
    } catch (ex) {
      print(ex);
      filePath = 'Can not fetch url';
    }
    print(filePath);
    return filePath;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save our form now.
      name = name.replaceAll(" ", "_");
      String api = '/generateQR?title=$title&no=$no&date=$date&fname=$name';
      print(server_address + api);
      var url = Uri.parse(server_address + api);
      buildShowDialog(context);

      try {
        var response = await HTTP.get(url);
        if (response.statusCode == 200) {
          //display pdf
          String pdf_link = "";
          pdf_link = response.body;
          final dir = await getApplicationDocumentsDirectory();
          var _localPath = dir.path + name;
          final savedDir = Directory(_localPath);
          List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
          path = storageInfo[0].rootDir;
          print(path);
          await savedDir.create(recursive: true).then((value) async {
            String? _taskid = await FlutterDownloader.enqueue(
              url: pdf_link,
              fileName: name,
              savedDir: path,
              showNotification: true,
              openFileFromNotification: true,
            );
            print(_taskid);

//            var value = await downloadFile(server_address + api, name, path);
            //           OpenFile.open(value);
          });
        } else {
          print("bad response");
        }
      }
      // ignore: empty_catches
      on Exception catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('There was an issue in server'),
          backgroundColor: Colors.red,
        ));
      }
      Navigator.pop(context);
      //Display the pdf
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Fake Circular Detector"),
          leading: IconButton(
            icon: IconTheme(
              data: Theme.of(context).iconTheme,
              child: const Icon(Icons.arrow_back),
            ),
            tooltip: 'Back',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
            child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text(
                    "Enter Circular details",
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Title',
                          labelText: 'Title'),
                      onSaved: (String? value) {
                        title = value!;
                      }),
                  const SizedBox(height: 15),
                  TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Number',
                          labelText: 'Circular number'),
                      onSaved: (String? value) {
                        no = int.parse(value!);
                      }),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          labelText: "Enter Date"),
                      readOnly: true,
                      onTap: () => _pickDate()),
                  const SizedBox(height: 15.0),
                  GestureDetector(
                    child: Container(
                      width: 150.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Theme.of(context).colorScheme.secondary),
                      child: const Center(
                        child: Text("Submit"),
                      ),
                    ),
                    onTap: () => _submit(),
                  )
                ]))));
  }
}
