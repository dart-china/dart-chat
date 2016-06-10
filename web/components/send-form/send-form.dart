import 'package:angular2/core.dart';

@Component(selector: 'send-form', templateUrl: './send-form.html')
class SendForm {
  static final String _nickCommand = '/nick';
  static final String _joinCommand = '/join';

  String message;

  @Output()
  EventEmitter onSendJoin = new EventEmitter();

  @Output()
  EventEmitter onSendNickname = new EventEmitter();

  @Output()
  EventEmitter onSendMessage = new EventEmitter();

  sendMessage() {
    var commandData;
    if (message.startsWith(_nickCommand)) {
      commandData = message.substring(_nickCommand.length).trim();
      onSendNickname.add(commandData);
    } else if (message.startsWith(_joinCommand)) {
      commandData = message.substring(_joinCommand.length).trim();
      onSendJoin.add(commandData);
    } else {
      onSendMessage.add(message);
    }
    message = '';
  }
}
