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

_send(WebSocket socket, Message message) {
  socket.add(message.toString());
}

class ChatManager {
  static final Room lobby = new Room('Lobby');

  static final Set<Room> roomList = new Set<Room>();

  static serve(WebSocket socket) {
    User user = new User(socket);
    lobby.addUser(user);

    _send(socket, new RoomResult(room: lobby.name));
    _roomSend(lobby, new ChatMessage('${user.nickname} has joined ${lobby.name}'));
  }
}

class Room {
  static final Set<String> roomNames = new Set<String>();

  String name;

  Set<User> users = new Set<User>();

  Room([name = 'Lobby']) {
    roomNames.add(name);
  }

  addUser(User user) {
    users.add(user);
  }
}

class User {
  static final Set<String> _nicknames = new Set<String>();

  static int _guestNumber = 0;

  WebSocket socket;

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
    // TODO
  }

  _handleJoin(Map json) {
    // TODO
  }

  _handleMessage(Map json) {
    // TODO
  }
}
