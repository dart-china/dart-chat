import 'dart:convert';

import 'manager.dart';

abstract class Message {
  send(User user);

  String build();
}

class NameMessage implements Message {
  bool success = false;
  String name;
  String message;

  NameMessage(this.name) : success = true;

  NameMessage.fail(this.message) : success = false;

  send(User user) {
    user.socket.add(build());
  }

  String build() {
    Map result;
    if (success) {
      result = {
        'nameResult': {'success': success, 'name': name}
      };
    } else {
      result = {
        'nameResult': {'success': success, 'message': message}
      };
    }
    return JSON.encode(result);
  }
}

class RoomMessage implements Message {
  bool success = false;
  String room;
  String message;

  RoomMessage(this.room) : success = true;

  RoomMessage.fail(this.message) : success = false;

  send(User user) {
    user.socket.add(build());
  }

  String build() {
    Map result;
    if (success) {
      result = {
        'roomResult': {'success': success, 'room': room}
      };
    } else {
      result = {
        'roomResult': {'success': success, 'message': message}
      };
    }
    return JSON.encode(result);
  }
}

class ChatMessage implements Message {
  String text;

  ChatMessage(this.text);

  send(User user) {
    Room room = user.room;
    for (User user in room.users) {
      if (user.socket != null) {
        user.socket.add(build());
      }
    }
  }

  String build() {
    Map result = {
      'message': {'text': text}
    };
    return JSON.encode(result);
  }
}
