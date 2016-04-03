import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:mime/mime.dart' as mime;

import 'src/chat_server.dart' as chatServer;

final String buildPath = Platform.script.resolve('../build/web').toFilePath();

main(List<String> args) async {
  var server = await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 8080);
  print("Serving at ${server.address}:${server.port}");
  await for (HttpRequest request in server) {
    var uri = request.uri.toString();

    // default fo index.html
    if (uri == '/') {
      uri = '/index.html';
    }

    var ext = path.extension(uri);
    if (ext.isNotEmpty) {
      _serveStatic(request, uri);
    } else {
      _serveNotFound(request);
    }

    if (request.uri.path == '/ws') {
      // Upgrade an HttpRequest to a WebSocket connection.
      var socket = await WebSocketTransformer.upgrade(request);
      chatServer.serve(socket);
    }
  }
}

// serve static files
_serveStatic(HttpRequest req, String filePath) {
  var file = new File(buildPath + filePath);
  file.exists().then((bool exists) {
    if (exists) {
      var mimeType = mime.lookupMimeType(file.path);
      req.response.headers.set('Content-Type', mimeType);
      file.openRead().pipe(req.response).catchError((err) => print(err));
    } else {
      _serveNotFound(req);
    }
  });
}

// serve not found
_serveNotFound(HttpRequest req) {
  req.response
    ..statusCode = HttpStatus.NOT_FOUND
    ..write('Not found!')
    ..close();
}
