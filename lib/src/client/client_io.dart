import 'dart:io';
import 'dart:convert';

import 'client_interface.dart';

class ChatClientIo implements ChatClient {
  WebSocket _socket;

  MessageCallback onMessage;

  ResultCallback onNameResult;

  ResultCallback onRoomResult;

  init(String url,
      {MessageCallback onMessage,
      ResultCallback onNameResult,
      ResultCallback onRoomResult}) {
    this.onMessage = onMessage;
    this.onNameResult = onNameResult;
    this.onRoomResult = onRoomResult;
    _setup(url);
  }

  _setup(String url) async {
    _socket = await WebSocket.connect(url);
    _socket.listen(_handleData);
  }

  _handleData(String data) {
    Map json = JSON.decode(data);
    bool success = false;
    if (json.containsKey('nameResult') && onNameResult != null) {
      success = json['nameResult']['success'];
      if (success) {
        onNameResult(true, json['nameResult']['name']);
      } else {
        onNameResult(false, json['nameResult']['message']);
      }
    } else if (json.containsKey('roomResult') && onRoomResult != null) {
      success = json['roomResult']['success'];
      if (success) {
        onRoomResult(true, json['roomResult']['room']);
      } else {
        onRoomResult(false, json['roomResult']['message']);
      }
    } else if (json.containsKey('message') && onMessage != null) {
      onMessage(json['message']['text']);
    }
  }

  _send(Map data) {
    _socket.add(JSON.encode(data));
  }

  rename(String name) {
    _send({
      'nameAttempt': {'name': name}
    });
  }

  join(String room) {
    _send({
      'join': {'room': room}
    });
  }

  sendMessage(String text) {
    _send({
      'message': {'text': text}
    });
  }
}
