import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:test/test.dart';

main(List<String> args) async {
  Process.start('dart', ['bin/server.dart']).then(run);
}

WebSocket socket;
Process mainProcess;
List<String> guestResults = <String>[];

run(Process process) async {
  mainProcess = process;

  process.stdout.transform(UTF8.decoder).listen((data) {
    print('Start chat server...');
    // OK to run test
    runTest();
  });

  process.stderr.transform(UTF8.decoder).listen((data) {
    print(data);
    exit();
  });
}

runTest() {
  new Timer(new Duration(seconds: 3), () async {
    print('Connecting to chat server...');
    socket = await WebSocket.connect('ws://127.0.0.1:8080/ws');
    socket.listen(onData);

    print('Run tests...');
    new Timer(new Duration(seconds: 3), () {
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

      exit();
    });
  });
}

onData(String msg) {
  guestResults.add(msg);
}

send(WebSocket socket, Map data) {
  socket.add(JSON.encode(data));
}

exit() {
  mainProcess.kill();
}
