import 'package:angular2/angular2.dart';

import '../message-panel/message-panel.dart';
import '../send-form/send-form.dart';

@Component(
    selector: 'dart-chat',
    templateUrl: './dart-chat.html',
    directives: const [MessagePanel, SendForm])
class DartChat {
  static final String _defaultRoom = 'Lobby';
  List<String> roomList = [_defaultRoom];
  List<String> messageList = [];

  String get defaultRoom => _defaultRoom;

  DartChat() {}
}
