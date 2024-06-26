import 'IDGenerator.dart';
import 'SecretService.dart';

//TODO: Shared package for both app and SDK since the three classes: IDService, IDGenerator and SecretService are used in both the app and the SDK!
class IDService {
  late final int _amount;
  late final SecretService secretService = SecretService();
  IDService({int amount = 3}) {
    _amount = amount;
  }
  Future<List<String>> generateIDs(
      {SecretType type = SecretType.PROFILE}) async {
    bool hasSecrets = await secretService.hasSecrets();
    if (!hasSecrets) {
      throw Exception("Secrets are missing");
    }

    List<String> ids = [];
    String rawSecret = await secretService.getSecret(type);
    List secretComponents = rawSecret.split("::");
    String secret = secretComponents[0];
    int counter = int.parse(secretComponents[1]);
    final IDGenerator idGenerator = IDGenerator(secret: secret);
    for (int i = 0; i < _amount; i++) {
      String id = idGenerator.generateId(counter);
      ids.add(id);
      counter++;
    }
    counter += 1;
    secretService.saveSecret(type, secret, counter);
    return ids;
  }

  void undoLastCountIncrease(SecretType type) async {
    String rawSecret = await secretService.getSecret(type);
    List secretComponents = rawSecret.split("::");
    String secret = secretComponents[0];
    int counter = int.parse(secretComponents[1]);
    counter -= _amount + 1;
    secretService.saveSecret(type, secret, counter);
  }

  Future<List<String>> fetchAdProfileIDs() async {
    List<String> ids = [];
    String rawSecret = await secretService.getSecret(SecretType.PROFILE);
    List secretComponents = rawSecret.split("::");
    print(secretComponents);
    String secret = secretComponents[0];
    int counter = int.parse(secretComponents[1]);
    final IDGenerator idGenerator = IDGenerator(secret: secret);
    for (int i = 0; i < _amount; i++) {
      String id = idGenerator.generateId(counter);
      ids.add(id);
      counter++;
    }
    return ids;
  }

  Future<List<String>> fetchInteractionIDs() async {
    List<String> ids = [];
    String rawSecret = await secretService.getSecret(SecretType.INTERACTION);
    List secretComponents = rawSecret.split("::");
    String secret = secretComponents[0];
    int counter = int.parse(secretComponents[1]);
    final IDGenerator idGenerator = IDGenerator(secret: secret);
    for (int i = 0; i < _amount; i++) {
      String id = idGenerator.generateId(counter);
      ids.add(id);
      counter++;
    }
    return ids;
  }
}
