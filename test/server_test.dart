import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:test/test.dart';

WebSocket socket;
Process process;
List<String> guestResults = <String>[];

main(List<String> args) async {
  setUpAll(() async {
    process = await Process.start('dart', ['bin/server.dart']);
    await new Future.delayed(new Duration(seconds: 2));
    socket = await WebSocket.connect('ws://127.0.0.1:8080/ws');
    await setupResuts();
  });

  tearDownAll(() async {
    exit();
  });

  runTests();
}

Future setupResuts() {
  Completer completer = new Completer();

  socket.listen((String msg) {
    guestResults.add(msg);
    if (guestResults.length == 3) {
      completer.complete();
    }
  });

  new Timer(new Duration(seconds: 8), () {
    if (!completer.isCompleted) {
      completer.completeError('Timeout!');
    }
  });

  return completer.future;
}

runTests() {
  group("Guest tests", () {
    test("Result list length should be 3", () {
      expect(guestResults.length, equals(3));
    });

    test("First result should be nameResult", () {
      expect(guestResults.first,
          allOf([contains("nameResult"), contains("name"), contains("id")]));
    });

    test("Second result should be roomResult", () {
      expect(guestResults.elementAt(1),
          allOf([contains("roomResult"), contains("room"), contains("id")]));
    });

    test("Third result should be message", () {
      expect(guestResults.elementAt(2),
          allOf([contains("message"), contains("room"), contains("text")]));
    });
  });
}

send(WebSocket socket, Map data) {
  socket.add(JSON.encode(data));
}

exit() {
  process.kill();
}
