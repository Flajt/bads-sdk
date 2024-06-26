import 'package:package_info_plus/package_info_plus.dart';

// Returns the apps ID so that it can be send to the Bads App
class AppIDManager {
  static Future<String> getAppID() async {
    final info = await PackageInfo.fromPlatform();
    return info.packageName;
  }
}
