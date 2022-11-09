import 'package:flutter/material.dart';
import 'package:http/http.dart' as HTTP;
import 'dart:convert' as convert;

import 'global.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _login();
}

class _login extends State<Login> {
  String key = "";

  Future<void> _submit() async {
    String api = '/login?key=$key';
    var url = Uri.parse(server_address + api);
    buildShowDialog(context);

    try {
      var response = await HTTP.get(url).whenComplete(() {
        Navigator.pop(context);
        Navigator.pop(context);
      });
      if (response.statusCode == 200) {
        var jsonResponse =
            convert.jsonDecode(response.body) as Map<String, dynamic>;

        if (jsonResponse["value"]) {
          login.value = 1;
        } else {
          login.value = 0;
        }
      } else {
        print("bad response");
      }
    }
    // ignore: empty_catches
    on Exception catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('There was an issue logging in'),
        backgroundColor: Colors.red,
      ));
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
          child: login.value == 0
              ? Column(
                  children: <Widget>[
                    const Text(
                      "Instituite Login",
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'key',
                          labelText: 'Key'),
                      onChanged: (value) {
                        key = value;
                      },
                    ),
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
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                )
              : Column(
                  children: <Widget>[
                    const Text(
                      "Instituite logged in",
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 15.0),
                    GestureDetector(
                      child: Container(
                        width: 150.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Theme.of(context).colorScheme.secondary),
                        child: const Center(
                          child: Text("Logout"),
                        ),
                      ),
                      onTap: () {
                        login.value = 0;
                        Navigator.pop(context);
                      },
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
        ));
  }
}
