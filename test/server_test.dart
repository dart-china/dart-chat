import 'dart:io';
import 'dart:convert';

main(List<String> args) async {
  var socket = await WebSocket.connect('ws://127.0.0.1:8080/ws');
  socket.listen((msg) => print('Received $msg'));
  _socketSend(socket, {
    'message': {'text': 'test'}
  });
}

_socketSend(WebSocket socket, Map data) {
  socket.add(JSON.encode(data));
}
