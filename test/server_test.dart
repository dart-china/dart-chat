import 'dart:io';
import 'dart:async';

import 'package:test/test.dart';
import 'package:dart_chat/chat_client_io.dart';

ChatClientIo client;
Process process;
List<String> namingResults = <String>[];
List<String> joinResults = <String>[];
List<String> messageResults = <String>[];

main(List<String> args) async {
  setUpAll(() async {
    process = await Process.start('dart', ['bin/server.dart']);

    // Uncomment to see server logs
    // stdout.addStream(process.stdout);
    // stderr.addStream(process.stderr);

    await new Future.delayed(new Duration(seconds: 2));

    client = new ChatClientIo();
    client.init('ws://127.0.0.1:9090/ws', onMessage: (String message) {
      messageResults.add(message);
    }, onRoomResult: (bool success, String data) {
      joinResults.add(data);
    }, onNameResult: (bool success, String data) {
      namingResults.add(data);
    });

    await new Future.delayed(new Duration(seconds: 2));
  });

  tearDownAll(() async {
    exit();
  });

  runTests();
}

runTests() {
  group("Guest tests", () {
    test("Result list length should be 3", () {
      expect(namingResults.length + joinResults.length + messageResults.length,
          equals(3));
    });

    test("NameResult should be Guest1", () {
      expect(namingResults.first, equals("Guest1"));
    });

    test("RoomResult should be Lobby", () {
      expect(joinResults.first, equals('Lobby'));
    });

    test("Message should contains Guest1, joined, Lobby", () {
      expect(messageResults.first,
          allOf([contains("Guest1"), contains("joined"), contains("Lobby")]));
    });
  });

  group("Naming tests", () {
    setUpAll(() async {
      clearResults();
      client.rename('Guestwho');
      client.rename('jaron');
      client.rename('jaron');
      await new Future.delayed(new Duration(seconds: 2));
    });

    test("Naming result list length should be 4", () {
      expect(namingResults.length + messageResults.length, equals(4));
    });

    test("Names cannot begin with 'Guest'", () {
      expect(
          namingResults.first, allOf([contains("cannot"), contains('Guest')]));
    });

    test("Rename to jaron should be ok", () {
      expect(namingResults.elementAt(1), equals("jaron"));
    });

    test("Should send renaming message to current room", () {
      expect(
          messageResults.first, allOf([contains("Guest1"), contains("jaron")]));
    });

    test("That name is already in use", () {
      expect(namingResults.elementAt(2), allOf([contains("in use")]));
    });
  });

  group("Join tests", () {
    setUpAll(() async {
      clearResults();
      client.join('darty');
      await new Future.delayed(new Duration(seconds: 2));
    });

    test("Join result list length should be 2", () {
      expect(joinResults.length + messageResults.length, equals(2));
    });

    test("Join should return room result", () {
      expect(joinResults.first, equals('darty'));
    });

    test("Message for join a room", () {
      expect(
          messageResults.first, allOf([contains("jaron"), contains("darty")]));
    });
  });

  group("Message tests", () {
    setUpAll(() async {
      clearResults();
      client.sendMessage('I\'m in darty');
      await new Future.delayed(new Duration(seconds: 2));
    });

    test("Message result list length should be 1", () {
      expect(messageResults.length, equals(1));
    });

    test("Send message to current room", () {
      expect(messageResults.first, allOf([contains("darty")]));
    });
  });
}

exit() {
  process.kill();
}

clearResults() {
  namingResults.clear();
  joinResults.clear();
  messageResults.clear();
}
