import 'dart:io';
import 'dart:convert';

class ChatManager {
  static int _guestNumber = 1;

  static final Map<String, String> _nickNames = <String, String>{};

  static final List<String> _nameUsed = <String>[];

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
    _nameUsed.add(name);
    _guestNumber++;

    _send({
      'nameResult': {'success': true, 'name': name, 'id': id}
    });

    return id;
  }

  _handleJoinRoom(String guestId, String room) {
    _currentRoom[guestId] = room;
    _send({
      'roomResult': {'success': true, 'room': room}
    });
    _send({
      'message': {
        'room': room,
        'text': '${_nickNames[guestId]} has joined $room'
      }
    });
  }

  _handleNameAttempt(String id, Map json) {
    if (json.containsKey('nameAttempt')) {
      String name = json['nameAttemp']['name'];
      if (name != null) {
        if (name.startsWith('Guest')) {
          _send({
            'nameResult': {
              'success': false,
              'message': 'Names cannot begin with "Guest".'
            }
          });
        } else {
          if (_nameUsed.contains(name)) {
            _send({
              'nameResult': {
                'success': false,
                'message': 'That name is already in use.'
              }
            });
          } else {
            var previousName = _nickNames[id];
            var previousIndex = _nameUsed.indexOf(id);
            _nameUsed.add(name);
            _nameUsed.removeAt(previousIndex);
            _nickNames[id] = name;
            _send({
              'nameResult': {'success': true, 'name': name, 'id': id}
            });

            var currentRoom = _currentRoom[id];
            _send({
              'message': {
                'room': currentRoom,
                'text': '$previousName is now known as $name'
              }
            });
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
      String room = json['message']['room'] ?? _defaultRoom;
      if (id != null && text != null) {
        _send({
          'message': {'room': room, 'text': text}
        });
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

  _send(Map data) {
    socket.add(JSON.encode(data));
  }

  static String _generateId() {
    return new DateTime.now().millisecondsSinceEpoch.toString();
  }
}
