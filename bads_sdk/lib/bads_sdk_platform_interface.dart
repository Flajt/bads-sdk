import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bads_sdk_method_channel.dart';

abstract class BadsSdkPlatform extends PlatformInterface {
  /// Constructs a BadsSdkPlatform.
  BadsSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static BadsSdkPlatform _instance = MethodChannelBadsSdk();

  /// The default instance of [BadsSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelBadsSdk].
  static BadsSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BadsSdkPlatform] when
  /// they register themselves.
  static set instance(BadsSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
