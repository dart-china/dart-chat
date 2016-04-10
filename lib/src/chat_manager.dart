import 'dart:io';
import 'dart:convert';

import 'chat_message.dart';

class ChatManager {
  static int _guestNumber = 1;

  static final Map<String, String> _nickNames = <String, String>{};

  static final Map<String, String> _currentRoom = <String, String>{};

  static final String _defaultRoom = 'Lobby';

  WebSocket socket;

  ChatManager(this.socket);

  start() {
    String guestId = _handleGuestIn(socket);

    _handleJoinRoom(guestId, _defaultRoom);

    socket.listen(_handleData);
  }

  String _handleGuestIn(WebSocket socket) {
    String name = 'Guest$_guestNumber';
    String id = _generateId();
    _nickNames[id] = name;
    _guestNumber++;

    _send(new NameResult(name: name, id: id));

    return id;
  }

  _handleJoinRoom(String guestId, String room) {
    _currentRoom[guestId] = room;
    _send(new RoomResult(room: room, id: guestId));
    _send(new ChatMessage(room, '${_nickNames[guestId]} has joined $room'));
  }

  _handleNameAttempt(String id, Map json) {
    if (json.containsKey('nameAttempt')) {
      String name = json['nameAttempt']['name'];
      if (name != null) {
        if (name.startsWith('Guest')) {
          _send(new NameResult(
              success: false, message: 'Names cannot begin with "Guest".'));
        } else {
          if (_nickNames.containsValue(name)) {
            _send(new NameResult(
                success: false, message: 'That name is already in use.'));
          } else {
            var previousName = _nickNames[id];
            _nickNames[id] = name;
            _send(new NameResult(name: name, id: id));
            var currentRoom = _currentRoom[id];
            _send(new ChatMessage(
                currentRoom, '$previousName is now known as $name'));
          }
        }
      }
    }
  }

  _handleJoin(String id, Map json) {
    if (json.containsKey('join')) {
      String room = json['join']['room'];
      if (room != null) {
        _handleJoinRoom(id, room);
      }
    }
  }

  _handleMessage(String id, Map json) {
    if (json.containsKey('message')) {
      String text = json['message']['text'];
      String room = _currentRoom[id] ?? _defaultRoom;
      if (id != null && text != null) {
        _send(new ChatMessage(room, text));
      }
    }
  }

  _handleData(String data) {
    Map json = JSON.decode(data) ?? {};
    String id = json['id'];
    if (json != null && id != null) {
      _handleNameAttempt(id, json);
      _handleJoin(id, json);
      _handleMessage(id, json);
    }
  }

  _send(Message message) {
    socket.add(message.toString());
  }

  static String _generateId() {
    return new DateTime.now().millisecondsSinceEpoch.toString();
  }
}
