import 'package:angular2/core.dart';
import 'package:dart_chat/chat_client_js.dart';

import '../message-panel/message-panel.dart';
import '../send-form/send-form.dart';

@Component(
    selector: 'dart-chat',
    templateUrl: './dart-chat.html',
    directives: const [MessagePanel, SendForm])
class DartChat {
  static final String _defaultRoom = 'Lobby';
  static String _currentRoom = '';
  List<String> roomList = [_defaultRoom];
  List<String> messageList = [];

  String get currentRoom => _currentRoom;

  ChatClientJs client = new ChatClientJs();

  DartChat() {
    client.init('ws://127.0.0.1:9090/ws',
        onMessage: _onMessage,
        onRoomResult: _onRoomResult,
        onNameResult: _onNameResult);
  }

  _onMessage(String message) {
    messageList.add('$message');
  }

  _onRoomResult(bool success, String room) {
    if (success) {
      _currentRoom = room;
      messageList.add('You joined $room');
    }
  }

  _onNameResult(bool success, String name) {
    if (success) {
      messageList.add('You are known as $name');
    }
  }

  onSendJoin(String data) {
    client.join(data);
  }

  onSendNickname(String data) {
    client.rename(data);
  }

  onSendMessage(String msg) {
    print('send $msg');
    client.sendMessage(msg);
  }
}
