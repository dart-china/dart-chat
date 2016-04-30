import 'dart:io';
import 'dart:convert';

import 'chat_client_interface.dart';

class ChatClientIo implements  ChatClient {
  WebSocket _socket;

  MessageCallback onMessage;

  MessageCallback onNameResult;

  MessageCallback onRoomResult;

  init(String url, MessageCallback onMessage, MessageCallback onNameResult, MessageCallback onRoomResult) {
    this.onMessage = onMessage;
    this.onNameResult = onNameResult;
    this.onRoomResult = onRoomResult;
    _setup(url);
  }

  _setup (String url) async {
    _socket = await WebSocket.connect(url);
    _socket.listen(_handleData);
  }

  _handleData(String data) {
    Map json = JSON.decode(data);
    if (json.containsKey('nameResult')) {
      onNameResult(json['nameResult']['name']);
    } else if (json.containsKey('roomResult')) {
      onRoomResult(json['roomResult']['room']);
    } else if (json.containsKey('message') && onMessage != null) {
      onMessage(json['message']['text']);
    }
  }

  _send(Map data) {
    _socket.add(JSON.encode(data));
  }

  rename(String name) {
    _send({
      'nameAttempt': {
        'name': name
      }
    });
  }

  join(String room) {
    _send({
      'join': {
        'room': room
      }
    });
  }

  sendMessage(String text) {
    _send({
      'message': {
        'text': text
      }
    });
  }
}
