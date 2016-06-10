import 'dart:io';

import 'src/server/manager.dart';

start(int port) async {
  var server = await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port);
  print("Serving at ${server.address}:${server.port}");
  await for (HttpRequest request in server) {
    if (request.uri.path == '/ws') {
      // Upgrade an HttpRequest to a WebSocket connection.
      var socket = await WebSocketTransformer.upgrade(request);
      ChatManager.serve(socket);
    } else {
      _serveNotFound(request);
    }
  }
}

// serve not found
_serveNotFound(HttpRequest req) {
  req.response
    ..statusCode = HttpStatus.NOT_FOUND
    ..write('Not found!')
    ..close();
}
