import 'dart:io';

int _guestNumber = 1;
Map<String, String> _nickNames = <String, String>{};
List<String> _nameUsed = <String>[];
Map<String, String> _currentRoom = <String, String>{};

final _defaultRoom = 'Lobby';

String _handleGuestIn(WebSocket socket) {
  String name = 'Guest$_guestNumber';
  String id = '$_defaultRoom#$name';
  _nickNames[id] = name;
  _nameUsed.add(name);
  _guestNumber++;

  socket.add({
    'nameResult': {'success': true, 'name': name}
  });

  return id;
}

_handleJoinRoom(WebSocket socket, String guestId, String room) {
  _currentRoom[guestId] = room;
  socket.add({
    'roomResult': {'success': true, 'room': room}
  });
  socket.add({
    'message': {'room': room, 'text': '$_nickNames[guestId] has joined $room'}
  });
}

serve(WebSocket socket) {
  var guestId = _handleGuestIn(socket);

  _handleJoinRoom(socket, guestId, _defaultRoom);

  socket.listen(_handleMsg);
}

_handleMsg(String msg) {
  print('Message received: $msg');
  // TODO - nameAttempt, join, message
}
