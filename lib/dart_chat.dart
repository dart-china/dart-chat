import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:mime/mime.dart' as mime;

final String buildPath = Platform.script.resolve('../build/web').toFilePath();

main(List<String> args) async {
  var server = await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 8080);
  print("Serving at ${server.address}:${server.port}");
  await for (HttpRequest request in server) {
    var uri = request.uri.toString();

    if (uri == '/') {
      uri = '/index.html';
    }

    if (uri != '/favicon.ico') {
      var ext = path.extension(uri);
      if (ext.isNotEmpty) {
        _serveStatic(request, uri);
      }
    }

    if (request.uri.path == '/ws') {
      // Upgrade an HttpRequest to a WebSocket connection.
      var socket = await WebSocketTransformer.upgrade(request);
      socket.listen(_handleMsg);
    }
  }
}

_handleMsg(msg) {
  print('Message received: $msg');
}

_serveStatic(HttpRequest req, String filePath) {
  var file = new File(buildPath + filePath);
  file.exists().then((bool exists) {
    if (exists) {
      var mimeType = mime.lookupMimeType(file.path);
      req.response.headers.set('Content-Type', mimeType);
      file.openRead().pipe(req.response).catchError((err) => print(err));
    } else {
      req.response
        ..statusCode = HttpStatus.NOT_FOUND
        ..write('Not found!')
        ..close();
    }
  });
}
