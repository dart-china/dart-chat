import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:test/test.dart';

WebSocket socket;
Process process;
int resultCounter = 0;
List<String> guestResults = <String>[];
List<String> namingResults = <String>[];
List<String> joinResults = <String>[];
List<String> messageResults = <String>[];

main(List<String> args) async {
  setUpAll(() async {
    process = await Process.start('dart', ['bin/server.dart']);
    await new Future.delayed(new Duration(seconds: 2));
    socket = await WebSocket.connect('ws://127.0.0.1:8080/ws');

    socket.listen((data) {
      resultCounter++;
      if (resultCounter <= 3) {
        guestResults.add(data);
      } else if (resultCounter > 3 && resultCounter <= 7) {
        namingResults.add(data);
      } else if (resultCounter > 7 && resultCounter <= 9) {
        joinResults.add(data);
      } else if (resultCounter > 9 && resultCounter <= 10) {
        messageResults.add(data);
      }
    });
  });

  tearDownAll(() async {
    exit();
  });

  runTests();
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

  group("Naming tests", () {
    setUpAll(() async {
      Map nameResult = JSON.decode(guestResults[0]);
      String id = nameResult['nameResult']['id'];
      send({
        'id': id,
        'nameAttempt': {'name': 'Guestwho'}
      });
      send({
        'id': id,
        'nameAttempt': {'name': 'jaron'}
      });
      send({
        'id': id,
        'nameAttempt': {'name': 'jaron'}
      });
      await new Future.delayed(new Duration(seconds: 2));
    });

    test("Naming result list length should be 4", () {
      expect(namingResults.length, equals(4));
    });

    test("Names cannot begin with 'Guest'", () {
      expect(
          namingResults.first,
          allOf(
              [contains("nameResult"), contains("false"), contains("cannot")]));
    });

    test("Rename to jaron should be ok", () {
      expect(namingResults.elementAt(1),
          allOf([contains("nameResult"), contains("name"), contains("jaron")]));
    });

    test("Should send renaming message to current room", () {
      expect(namingResults.elementAt(2),
          allOf([contains("message"), contains("room"), contains("jaron")]));
    });

    test("That name is already in use", () {
      expect(
          namingResults.elementAt(3),
          allOf(
              [contains("nameResult"), contains("false"), contains("in use")]));
    });
  });
}

send(Map data) {
  socket.add(JSON.encode(data));
}

exit() {
  process.kill();
}
