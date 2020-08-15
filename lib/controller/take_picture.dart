import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:convert/convert.dart';


Future<dynamic> takePicture() async {

  Uri url = Uri.parse('http://192.168.1.1/osc/commands/execute');
  var request = http.Request('POST', url);

  Map<String, String> bodyMap = {"name": "camera.takePicture"};
  // request.bodyFields = bodyMap;
  request.body = jsonEncode(bodyMap);

  Map<String, String> headers = {
    "Content-Type": "application/json; charset=UTF-8"
  };

  http.Client client = http.Client();
  StreamSubscription videoStream;
  client.head(url, headers: headers);

  client.send(request).then(
    (response) {
      videoStream = response.stream.listen((List<int> data) {
        hex.encode(data);
        for (var i = 0; i < data.length - 1; i++) {
          print(data[i]);
        }
      }
      );
    }
  );

  @override
  void deactivate() {
    videoStream?.cancel();
    client?.close();
  }
}