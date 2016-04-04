import 'dart:io';
import 'dart:convert';

int _guestNumber = 1;
Map<String, String> _nickNames = <String, String>{};
List<String> _nameUsed = <String>[];
Map<String, String> _currentRoom = <String, String>{};

final _defaultRoom = 'Lobby';

String _handleGuestIn(WebSocket socket) {
  String name = 'Guest$_guestNumber';
  String id = _generateId();
  _nickNames[id] = name;
  _nameUsed.add(name);
  _guestNumber++;

  _socketSend(socket, {
    'nameResult': {'success': true, 'name': name, 'id': id}
  });

  return id;
}

_handleJoinRoom(WebSocket socket, String guestId, String room) {
  _currentRoom[guestId] = room;
  _socketSend(socket, {
    'roomResult': {'success': true, 'room': room}
  });
  _socketSend(socket, {
    'message': {'room': room, 'text': '${_nickNames[guestId]} has joined $room'}
  });
}

serve(WebSocket socket) {
  var guestId = _handleGuestIn(socket);

  _handleJoinRoom(socket, guestId, _defaultRoom);

  socket.listen((msg) {
    _handleMsg(socket, msg);
  });
}

_handleMsg(WebSocket socket, String msg) {
  Map json = JSON.decode(msg) ?? {};
  String id = json['id'];
  if (json != null && id.isNotEmpty) {
    if (json.containsKey('nameAttempt')) {
      String name = json['nameAttemp']['name'];
      if (name != null) {
        if (name.startsWith('Guest')) {
          _socketSend(socket, {
            'nameResult': {
              'success': false,
              'message': 'Names cannot begin with "Guest".'
            }
          });
        } else {
          if (_nameUsed.contains(name)) {
            _socketSend(socket, {
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
            _socketSend(socket, {
              'nameResult': {'success': true, 'name': name, 'id': id}
            });

            var currentRoom = _currentRoom[id];
            _socketSend(socket, {
              'message': {
                'room': currentRoom,
                'text': '$previousName is now known as $name'
              }
            });
          }
        }
      }
    } else if (json.containsKey('join')) {
      String room = json['join']['room'];
      if (room != null) {
        _handleJoinRoom(socket, id, room);
      }
    } else if (json.containsKey('message')) {
      String text = json['message']['text'];
      String room = json['message']['room'] ?? _defaultRoom;
      if (id != null && text != null) {
        _socketSend(socket, {
          'message': {'room': room, 'text': text}
        });
      }
    }
  }
}

_socketSend(WebSocket socket, Map data) {
  socket.add(JSON.encode(data));
}

String _generateId() {
  return new DateTime.now().millisecondsSinceEpoch.toString();
}
