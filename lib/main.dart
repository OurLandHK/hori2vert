import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '中文橫轉直',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: MyHomePage(title: '中文橫轉直'),
      )
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final int _initWidth = 10;
  static final int _initHeight = 20;
  String _host = 'https://hori2vert.web.app/';
  String _inputText = '';
  int _width = _initWidth;
  int _height = _initHeight;
  TextEditingController _outputTextController = TextEditingController(text: '');
  TextEditingController _inputTextController = TextEditingController(text: '');
  TextEditingController _widthTextController =
      TextEditingController(text: _initWidth.toString());
  TextEditingController _heightTextController =
      TextEditingController(text: _initHeight.toString());
  void _convert() {
    setState(() {
      _outputTextController.text = _translate(_inputText, _width, _height);
    });
  }

  String _translate(String text, int width, int height) {
    String translatedText = _charReplace(text, height);
    String formatText = _formatText(translatedText, width, height);
    return formatText + _host;
  }

  String _charReplace(String originalText, int height) {
    String rv = "";
    for (int i = 0; i < originalText.length; i++) {
      String newChar = originalText[i];
      int ic = newChar.codeUnitAt(0);
      // half character change to full
      if (ic >= 33 && ic <= 126) {
        newChar = String.fromCharCode(ic + 65248);
      } else if (ic == 32) {
        newChar = String.fromCharCode(12288);
      }
      // TODO change from veritical to horizontal char like :

      // Add space for newline
      if (ic == 10) {
        int addSpace = rv.length % height;
        if (addSpace > 0) {
          addSpace = height - addSpace;
          for (int j = 0; j < addSpace; j++) {
            rv += String.fromCharCode(12288);
          }
        }
      } else {
        rv += newChar;
      }
    }
    return rv;
  }

  String _formatText(String originalText, int width, int height) {
    int numberOfCharPerPage = width * height;
    int totalChar = originalText.length;
    int page = (totalChar / numberOfCharPerPage + 1).toInt();
    String rv = "";
    // format per page
    for (int i = 0; i < page; i++) {
      int renederWidth = width;
      if (page == 1) {
        renederWidth = (originalText.length / height + 1).toInt();
      }
      int pageOffset = numberOfCharPerPage * i;
      for (int j = 0; j < height; j++) {
        for (int k = 0; k < renederWidth; k++) {
          int lineOffset = (renederWidth - k - 1) * height;
          // pick char
          int charIndex = pageOffset + lineOffset + j;
          if (charIndex < totalChar) {
            rv += originalText[charIndex];
          } else {
            rv += String.fromCharCode(12288);
          }
        }
        rv += String.fromCharCode(10);
      }
      rv += String.fromCharCode(10);
    }
    return rv;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              child: Row(children: [
                RaisedButton(
                  child: Text('剪貼簿貼上'),
                  onPressed: () async {
                    ClipboardData data = await Clipboard.getData('text/plain');
                    setState(() {
                      _inputTextController.text = data.text;
                      _inputText = data.text;
                    });
                  },
                ),
                SizedBox(child: Container(), width: 10),
                RaisedButton(
                  child: Text('清除輸入文字'),
                  onPressed: () async {
                    setState(() {
                      _inputTextController.text = '';
                      _inputText = '';
                    });
                  },
                ),
                SizedBox(child: Container(), width: 10),
              ]),
              width: (MediaQuery.of(context).size.width - 84),
            ),
            SizedBox(
              //child: Scrollbar(
              child:
              TextField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  filled: true,
                  //icon: Icon(Icons.live_help),
                  hintText: '輸入或貼上橫寫文字（可以入半形文字）',
                  //labelText: textRes.LABEL_QUESTION,
                ),
                expands: true,
                minLines: null,
                maxLines: null,
                controller: _inputTextController,
                onChanged: (value) {
                  setState(() {
                    this._inputText = value;
                  });
                },
                //  scrollController: ScrollController(),
              ),
              //),
              height: (MediaQuery.of(context).size.height - 134) / 2,
            ),
            SizedBox(
              child: Row(children: [
                Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _widthTextController,
                      decoration: new InputDecoration(labelText: "行"),
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      onChanged: (value) {
                        setState(() {
                          this._width = int.parse(value);
                        });
                      }, // Only numbers can be entered
                    )),
                SizedBox(child: Container(), width: 10),
                Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _heightTextController,
                      decoration: new InputDecoration(labelText: "列"),
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      onChanged: (value) {
                        setState(() {
                          this._height = int.parse(value);
                        });
                      }, // Only numbers can be entered
                    )),
                SizedBox(child: Container(), width: 10),
                RaisedButton(onPressed: _convert, child: Text('橫轉直')),
                SizedBox(child: Container(), width: 10),
                RaisedButton(
                  child: Text('抄去剪貼簿'),
                  onPressed: () async {
                    Clipboard.setData(
                            ClipboardData(text: _outputTextController.text))
                        .then((reult) {
                      final snackBar = SnackBar(
                        content: Text('抄咗'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {},
                        ),
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                    });
                  },
                )
              ]),
              width: (MediaQuery.of(context).size.width - 84),
            ),
            SizedBox(
              child: Scrollbar(
                  child: TextField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  filled: true,
                  //icon: Icon(Icons.live_help),
                  hintText: '直寫預覽',
                  //labelText: textRes.LABEL_QUESTION,
                ),
                expands: true,
                minLines: null,
                maxLines: null,
                controller: _outputTextController,
                scrollController: ScrollController(),
              )),
              height: (MediaQuery.of(context).size.height - 134) / 2,
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
