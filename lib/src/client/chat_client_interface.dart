typedef void MessageCallback(String msg);

abstract class ChatClient {
  MessageCallback onMessage;

  MessageCallback onNameResult;

  MessageCallback onRoomResult;

  init(String url, MessageCallback onMessage, MessageCallback onNameResult, MessageCallback onRoomResult);

  rename(String name);

  join(String room);

  sendMessage(String text);
}
