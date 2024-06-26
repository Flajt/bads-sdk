import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ignore: constant_identifier_names
enum SecretType { PROFILE, INTERACTION }

class SecretService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<bool> hasSecrets() async {
    final hasProfile = await secureStorage.containsKey(key: "ad_profile");
    final hasInteraction =
        await secureStorage.containsKey(key: "ad_interaction");
    return hasProfile && hasInteraction;
  }

  Future<void> saveSecret(SecretType type, String secret, int counter) async {
    String key = "ad_profile";
    switch (type) {
      case SecretType.PROFILE:
        key = "ad_profile";
        break;
      case SecretType.INTERACTION:
        key = "ad_interaction";
        break;
    }
    await secureStorage.write(key: key, value: "$secret::$counter");
  }

  Future setLastUpdate(DateTime date) async {
    await secureStorage.write(key: "last_update", value: date.toString());
  }

  Future<DateTime?> getLastUpdate() async {
    final data = await secureStorage.read(key: "last_update");
    if (data == null) {
      return null;
    }
    return DateTime.parse(data);
  }

  Future<String> getSecret(SecretType type) async {
    switch (type) {
      case SecretType.PROFILE:
        final data = await secureStorage.read(key: "ad_profile");
        return data!;
      case SecretType.INTERACTION:
        final data = await secureStorage.read(key: "ad_interaction");
        return data!;
    }
  }
}
