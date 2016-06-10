import 'package:angular2/core.dart';

@Component(selector: 'send-form', templateUrl: './send-form.html')
class SendForm {
  static final String _nickCommand = '/nick';
  static final String _joinCommand = '/join';

  @Output()
  EventEmitter onSendJoin = new EventEmitter();

  @Output()
  EventEmitter onSendNickname = new EventEmitter();

  @Output()
  EventEmitter onSendMessage = new EventEmitter();

  sendMessage(String msg) {
    var commandData;
    if (msg.startsWith(_nickCommand)) {
      commandData = msg.substring(_nickCommand.length).trim();
      onSendNickname.add(commandData);
    } else if (msg.startsWith(_joinCommand)) {
      commandData = msg.substring(_joinCommand.length).trim();
      onSendNickname.add(commandData);
    } else {
      onSendMessage.add(msg);
    }
  }
}
