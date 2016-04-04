import 'dart:io';
import 'dart:convert';
import 'dart:async';

main(List<String> args) async {
  Process.start('dart', ['bin/server.dart']).then(_runTest);
}

_runTest(Process process) async {
  process.stdout.transform(UTF8.decoder).listen((data) {
    print(data);
    _setup();
  });

  process.stderr.transform(UTF8.decoder).listen((data) {
    print(data);
    process.kill();
  });

  new Timer(new Duration(seconds: 6), () {
    process.kill();
  });
}

_setup() {
  new Timer(new Duration(seconds: 3), () async {
    var socket = await WebSocket.connect('ws://127.0.0.1:8080/ws');
    socket.listen((msg) => print('Received $msg'));
    _socketSend(socket, {
      'message': {'text': 'test'}
    });
  });
}

_socketSend(WebSocket socket, Map data) {
  socket.add(JSON.encode(data));
}
