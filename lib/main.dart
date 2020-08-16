import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './controller/take_picture.dart';
import './controller/get_live_preview.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:convert/convert.dart';
import 'dart:typed_data';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'THETA MotionJPEG'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Image frameImage = Image(
    image: NetworkImage(
        'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
  );

  bool playing = false;

  void _playThetaPreview() {
    int duration = 300;

    int counter = 0;

    Duration ts;
    Stopwatch timer = Stopwatch();

    timer.start();

    Uri url = Uri.parse('http://192.168.1.1/osc/commands/execute');
    var request = http.Request('POST', url);

    Map<String, String> bodyMap = {"name": "camera.getLivePreview"};
    // request.bodyFields = bodyMap;
    request.body = jsonEncode(bodyMap);

    Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8"
    };

    http.Client client = http.Client();
    StreamSubscription videoStream;
    client.head(url, headers: headers);

    if (!playing ) {
      playing = true;
      client.send(request).then(
            (response) {
          var startIndex = -1;
          var endIndex = -1;
          List<int> buf = List<int>();
          videoStream = response.stream.listen((List<int> data) {
            if (playing) {
              hex.encode(data);
              for (var i = 0; i < data.length - 1; i++) {
                // print(data[i]);
                if (data[i] == 0xff && data[i + 1] == 0xd8) {
                  startIndex = buf.length + i;
                }
                if (data[i] == 0xff && data[i + 1] == 0xd9) {
                  endIndex = buf.length + i;
                }
              }
              buf.addAll(data);
              if (startIndex != -1 && endIndex != -1) {
                // print('$startIndex, $endIndex, ${buf.length}');
                timer.stop();
                ts = timer.elapsed;
                if (ts.inMilliseconds > 100) {
                  timer.reset();
                  print("100 ms elapsed: $counter");
//              if (counter < duration) {
                  print('writing frame $counter at 6fps');
                  setState(() {
                    frameImage = Image.memory(
                        Uint8List.fromList(buf.sublist(73, buf.length)));
                    // frameImage = Image.network(
                    //     'https://picsum.photos/seed/$counter/300/200');
                  });
//                counter++;
                }
                startIndex = -1;
                endIndex = -1;
                buf = List<int>();
                timer.start();
              } else {
                // print('start index is -1');
              }
            } else {
              // not playing at this point
              timer?.stop();
              videoStream?.cancel();
              client?.close();
            }
          });
        },
      );
    }
  }

  void _stopThetaPreview() {
    setState(() {
      playing = false;
    });

    print("stopping stream");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            frameImage,
          ],
        ),
      ),
      floatingActionButton: !playing ? FloatingActionButton(
        onPressed: _playThetaPreview,
        child: Icon(Icons.play_arrow),
      ) :
      FloatingActionButton(
        onPressed: _stopThetaPreview,
        child: Icon(Icons.stop),
      ),
    );
  }
}
