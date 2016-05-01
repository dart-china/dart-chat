import 'package:args/args.dart';

import 'package:dart_chat/dart_chat.dart' as server;

void main(List<String> args) {
  var parser = new ArgParser();
  parser.addOption('port', abbr: 'p', defaultsTo: '9090');
  var results = parser.parse(args);
  server.start(int.parse(results['port']));
}
