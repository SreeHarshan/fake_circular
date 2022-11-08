import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as HTTP;
import 'dart:convert' as convert;

import 'result.dart';
import 'global.dart';

bool isDigit(String s) {
  return int.tryParse(s) != null;
}

class Check_page extends StatefulWidget {
  const Check_page({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _check_page();
}

// ignore: camel_case_types
class _check_page extends State<Check_page> {
  int no = 0;
  String date = "", title = "";
  bool _done = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController dateController = TextEditingController();
  void _sendError() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Please enter values properly"),
      backgroundColor: Colors.red,
    ));
  }

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

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save our form now.

      String api = '/check?title="$title"&no=$no&date="$date"&rno=5';
      print(server_address + api);
      var url = Uri.parse(server_address + api);
      buildShowDialog(context);

      bool real = false;
      try {
        var response = await HTTP.get(url);
        if (response.statusCode == 200) {
          var jsonResponse =
              convert.jsonDecode(response.body) as Map<String, dynamic>;
          print(jsonResponse);

          real = jsonResponse["value"];
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
      //Switch to results page
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResultPage(
                    real: real,
                  )));
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

  buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}