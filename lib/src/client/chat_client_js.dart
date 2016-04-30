import 'dart:html';
import 'dart:convert';

import 'chat_client_interface.dart';

class ChatClientJs implements ChatClient {
  WebSocket _socket;

  MessageCallback onMessage;

  MessageCallback onNameResult;

  MessageCallback onRoomResult;

  init(String url, MessageCallback onMessage, MessageCallback onNameResult, MessageCallback onRoomResult) {
    _socket = new WebSocket(url);
    this.onMessage = onMessage;
    this.onNameResult = onNameResult;
    this.onRoomResult = onRoomResult;
    _setup();
  }

  _setup() {
    _socket.onOpen.listen((data) {
      print('Socket open');
    });

    _socket.onError.listen((data) {
      print('Socket error');
    });

    _socket.onClose.listen((data) {
      print('Socket close');
    });

    _socket.onMessage.listen((message) {
      _handleMessage(message.data);
    });
  }

  _handleMessage(String data) {
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
    _socket.sendString(JSON.encode(data));
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
