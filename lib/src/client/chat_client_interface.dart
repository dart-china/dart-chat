typedef void MessageCallback(String msg);
typedef void ResultCallback(bool success, String msg);

abstract class ChatClient {
  MessageCallback onMessage;

  ResultCallback onNameResult;

  ResultCallback onRoomResult;

  init(String url,
      {MessageCallback onMessage,
      ResultCallback onNameResult,
      ResultCallback onRoomResult});

  rename(String name);

  join(String room);

  sendMessage(String text);
}
