import 'dart:io';

main() async {
  var server = await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 8080);
  print("Serving at ${server.address}:${server.port}");
  await for (HttpRequest request in server) {
    if (request.uri.path == '/ws') {
      // Upgrade an HttpRequest to a WebSocket connection.
      var socket = await WebSocketTransformer.upgrade(request);
      socket.listen(handleMsg);
    }

    request.response
      ..headers.contentType = new ContentType("text", "plain", charset: "utf-8")
      ..write('Hello, world')
      ..close();
  }
}

handleMsg(msg) {
  print('Message received: $msg');
}
