import 'dart:convert';
import 'dart:io';

import 'message.dart';

class ChatManager {
  static final Room lobby = new Room.create('Lobby');

  static final Set<Room> roomList = new Set<Room>();

  static serve(WebSocket socket) {
    User user = new User(socket);
    lobby.addUser(user);

    new NameMessage(user.nickname).send(user);
    new RoomMessage(lobby.name).send(user);
    new ChatMessage('${user.nickname} has joined ${lobby.name}').send(user);
  }
}

class Room {
  static final Map<String, Room> roomMap = <String, Room>{};

  Set<User> users = new Set<User>();

  String name;

  factory Room.create(String name) {
    Room room;
    if (roomMap.containsKey(name)) {
      room = roomMap[name];
    } else {
      room = new Room._internal(name);
      roomMap[name] = room;
    }
    return room;
  }

  Room._internal(this.name);

  addUser(User user) {
    users.add(user);
    user.room = this;
  }

  removeUser(User user) {
    users.remove(user);
    user.room = null;
  }

  List<String> get roomNames {
    return roomMap.keys;
  }

  List<Room> get roomList {
    return roomMap.values;
  }
}

class User {
  static final Set<String> _nicknames = new Set<String>();

  static int _guestNumber = 0;

  WebSocket socket;

  Room room;

  String nickname;

  User(this.socket) {
    _guestNumber++;
    nickname = 'Guest$_guestNumber';
    _nicknames.add(nickname);

    socket.listen(_handleData, onDone: _handleDone);
  }

  _handleData(String data) {
    Map json = JSON.decode(data);
    if (json != null) {
      _handleNameAttempt(json);
      _handleJoin(json);
      _handleMessage(json);
    }
  }

  _handleDone() {
    _nicknames.remove(nickname);
    room.removeUser(this);
  }

  _handleNameAttempt(Map json) {
    if (json.containsKey('nameAttempt')) {
      String name = json['nameAttempt']['name'];
      if (name != null) {
        if (name.startsWith('Guest')) {
          new NameMessage.fail('Names cannot begin with "Guest".').send(this);
        } else {
          if (_nicknames.contains(name)) {
            new NameMessage('That name is already in use.').send(this);
          } else {
            _nicknames.remove(nickname);
            new NameMessage(name).send(this);
            new ChatMessage('$nickname is now known as $name').send(this);
            nickname = name;
            _nicknames.add(nickname);
          }
        }
      }
    }
  }

  _handleJoin(Map json) {
    if (json.containsKey('join')) {
      String roomName = json['join']['room'];
      if (roomName != null) {
        room.removeUser(this);
        room = new Room.create(roomName);
        room.addUser(this);

        new RoomMessage(roomName).send(this);
        new ChatMessage('$nickname has joined $roomName').send(this);
      }
    }
  }

  _handleMessage(Map json) {
    if (json.containsKey('message')) {
      String text = json['message']['text'];
      if (text != null) {
        new ChatMessage('$nickname: $text').send(this);
      }
    }
  }
}
