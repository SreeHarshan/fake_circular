import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  bool real;
  ResultPage({Key? key, required this.real}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _resultpage(real);
}

class _resultpage extends State<ResultPage> {
  // add the String in center text
  late String value;
  _resultpage(bool real) {
    if (real) {
      value = "Original Circular";
    } else {
      value = "Fake circular";
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
          child: Column(
            children: <Widget>[
              const Text(
                "Detected Circular is",
                style: TextStyle(fontSize: 20),
              ),
              Text(value),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
        ));
  }
}
