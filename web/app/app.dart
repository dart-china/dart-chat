import 'package:angular2/angular2.dart';

@Component(selector: 'dartlang-downloads', templateUrl: './app.html')
class App {
  List<Map<String, String>> channelList = [
    {'name': '稳定版', 'value': 'stable'},
    {'name': 'dev版', 'value': 'dev'}
  ];

  List<String> platformList = ['windows', 'mac', 'linux'];

  List<String> versionList = ['1.15.0', '1.14.2', '1.13.0'];

  List<String> architectureList = ['64', '32'];

  _Model model = new _Model();

  App() {
    model.channel = channelList[0]['value'];
    model.platform = platformList[0];
    model.version = versionList[0];
    model.architecture = architectureList[0];
  }

  build() {
    print(model);
  }

  onChannelChange(channel) {
    model.channel = channel;
  }

  onPlatformChange(platform) {
    model.platform = platform;
  }

  onVersionChange(version) {
    model.version = version;
  }

  onArchitectureChange(architecture) {
    model.architecture = architecture;
  }
}

class _Model {
  static String downloadUrl = '''https://storage.googleapis.com/dart-archive/
  channels/<channel>/release/<release>/sdk/dartsdk-<platform>-<architecture>-release.zip''';
  String channel;
  String version;
  String platform;
  String architecture;

  String buildDownloadUrl() {
    return downloadUrl;
  }

  String toString() {
    return '$channel $version $platform $architecture';
  }
}
