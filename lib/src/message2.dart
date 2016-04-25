import 'dart:convert';

abstract class Message {}

class NameResult extends Message {
  bool success = false;
  String name;
  String message;

  NameResult({this.name, this.success: true, this.message});

  String toString() {
    Map result;
    if (success) {
      result = {
        'nameResult': {'success': true, 'name': name}
      };
    } else {
      result = {
        'nameResult': {'success': false, 'message': message}
      };
    }
    return JSON.encode(result);
  }
}

class RoomResult extends Message {
  bool success = false;
  String room;
  String message;

  RoomResult({this.room, this.success: true, this.message});

  String toString() {
    Map result;
    if (success) {
      result = {
        'roomResult': {'success': true, 'room': room}
      };
    } else {
      result = {
        'roomResult': {'success': false, 'message': message}
      };
    }
    return JSON.encode(result);
  }
}

class ChatMessage extends Message {
  String text;

  ChatMessage(this.text);

  String toString() {
    Map result = {
      'message': {'text': text}
    };
    return JSON.encode(result);
  }
}
