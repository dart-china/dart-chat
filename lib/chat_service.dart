import 'dart:html';
import 'dart:convert';

import 'package:angular2/core.dart';

import 'src/client/client_interface.dart';

@Injectable()
class ChatService implements ChatClient {
  WebSocket _socket;

  MessageCallback onMessage;

  ResultCallback onNameResult;

  ResultCallback onRoomResult;

  init(String url,
      {MessageCallback onMessage,
      ResultCallback onNameResult,
      ResultCallback onRoomResult}) {
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
    _socket.sendString(JSON.encode(data));
  }

  /// Attempt to rename
  rename(String name) {
    _send({
      'nameAttempt': {'name': name}
    });
  }

  /// Join room
  join(String room) {
    _send({
      'join': {'room': room}
    });
  }

  /// Send chat text message
  sendMessage(String text) {
    _send({
      'message': {'text': text}
    });
  }
}
