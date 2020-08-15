import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:convert/convert.dart';
import 'dart:typed_data';

Future<Image> getLivePreview() async {
  int counter = 0;
  Image frameImage;

  Duration ts = null;
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

  client.send(request).then((response) {
    var startIndex = -1;
    var endIndex = -1;
    List<int> buf = List<int>();
    videoStream = response.stream.listen((List<int> data) {
      hex.encode(data);
      for (var i = 0; i < data.length - 1; i++) {
        if (data[i] == 0xff && data[i + 1] == 0xd8) {
          startIndex = buf.length + i;
        }
        if (data[i] == 0xff && data[i + 1] == 0xd9) {
          endIndex = buf.length + i;
        }
      }
      buf.addAll(data);
      if (startIndex != -1 && endIndex != -1) {
        print('$startIndex, $endIndex, ${buf.length}');
        timer.stop();
        ts = timer.elapsed;
        if (ts.inMilliseconds > 1000) {
          timer.reset();
          print("1 second elapsed: $counter");
          if (counter < 10) {
            print('writing frame $counter');
            // TODO: create image here
            frameImage = Image.memory(Uint8List.fromList(buf));
            counter++;

            return frameImage;
          }
        }
        startIndex = -1;
        endIndex = -1;
        buf = List<int>();
        timer.start();
      }
    });

    @override
    void deactivate() {
      videoStream?.cancel();
      client?.close();
    }
  });
  return frameImage;
}
