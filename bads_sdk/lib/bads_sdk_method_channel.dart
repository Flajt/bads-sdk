import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bads_sdk_platform_interface.dart';

/// An implementation of [BadsSdkPlatform] that uses method channels.
class MethodChannelBadsSdk extends BadsSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bads_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
