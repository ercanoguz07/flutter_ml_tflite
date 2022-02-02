import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Tensorflow Machine Learning'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isloading = false;
  XFile? _image;
  List? _outputs;

  @override
  void initState() {
    super.initState();
    loadTFLiteModel();
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  loadTFLiteModel() async {
    await Tflite.loadModel(
            model: "assets/model_unquant.tflite", labels: "assets/labels.txt")
        .then((value) {
      setState(() {
        _isloading = true;
      });
    });
  }

  chooseImage() async {
    final ImagePicker _picker = ImagePicker();
    _image = await _picker.pickImage(source: ImageSource.gallery);
    if (_image == null) return;

    executeImageTFlie();
  }

  executeImageTFlie() async {
    var out = await Tflite.runModelOnImage(
        path: _image!.path,
        numResults: 2,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.5);
    setState(() {
      _outputs = out;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _isloading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Card(
                    elevation: 4,
                    color: Colors.white70,
                    shadowColor: Colors.black26,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 50),
                      height: 350,
                      width: double.infinity,
                      child: _image == null
                          ? Container()
                          : Image.file(File(_image!.path)),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    _outputs == null
                        ? "Picture is waiting!"
                        : _outputs![0]["label"].toString() +
                            "  confidence:" +
                            (double.parse(
                                        _outputs![0]["confidence"].toString()) *
                                    100)
                                .toStringAsFixed(0) +
                            "%",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: chooseImage,
        tooltip: 'add photo',
        elevation: 2,
        disabledElevation: 8,
        child: Icon(Icons.add_a_photo_rounded),
      ),
    );
  }
}
