import 'dart:convert';
import 'dart:io';

import 'message2.dart';

_roomSend(Room room, Message message) {
  for (User user in room.users) {
    if (user.socket != null) {
      user.socket.add(message.toString());
    }
  }
}

_userSend(User user, Message message) {
  user.socket.add(message.toString());
}

class ChatManager {
  static final Room lobby = new Room.create('Lobby');

  static final Set<Room> roomList = new Set<Room>();

  static serve(WebSocket socket) {
    User user = new User(socket);
    lobby.addUser(user);

    _userSend(user, new RoomResult(room: lobby.name));
    _roomSend(lobby, new ChatMessage('${user.nickname} has joined ${lobby.name}'));
  }
}

class Room {
  static final Set<String> roomNames = new Set<String>();

  static final Map<String, Room> rooms = <String, Room>{};

  Set<User> users = new Set<User>();

  String name;

  factory Room.create(String name) {
    roomNames.add(name);

    Room room;
    if (rooms.containsKey(name)) {
      room = rooms[name];
    } else {
      room = new Room._internal(name);
      rooms[name] = room;
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

    socket.listen(_handleData);
  }

  _handleData(String data) {
    Map json = JSON.decode(data);
    if (json != null) {
      _handleNameAttempt(json);
      _handleJoin(json);
      _handleMessage(json);
    }
  }

  _handleNameAttempt(Map json) {
    if (json.containsKey('nameAttempt')) {
      String name = json['nameAttempt']['name'];
      if (name != null) {
        if (name.startsWith('Guest')) {
          _userSend(this, new NameResult(
              success: false, message: 'Names cannot begin with "Guest".'));
        } else {
          if (_nicknames.contains(name)) {
            _userSend(this, new NameResult(
                success: false, message: 'That name is already in use.'));
          } else {
            _nicknames.remove(nickname);
            _userSend(this, new NameResult(name: name));
            _roomSend(room, new ChatMessage('$nickname is now known as $name'));
            nickname = name;
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

        _userSend(this, new RoomResult(room: roomName));
        _roomSend(room, new ChatMessage('$nickname has joined $roomName'));
      }
    }
  }

  _handleMessage(Map json) {
    if (json.containsKey('message')) {
      String text = json['message']['text'];
      if (text != null) {
        _roomSend(room, new ChatMessage(text));
      }
    }
  }
}
