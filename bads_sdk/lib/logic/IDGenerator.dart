import 'package:dart_dash_otp/dart_dash_otp.dart';

class IDGenerator {
  // Base32 encoded secret
  final String secret;
  IDGenerator({required this.secret});
  // Returns new ID based on the counter, you need to increase it afterwards by 1
  String generateId(int counter) {
    HOTP otp = HOTP(secret: secret, digits: 8);
    return otp.at(counter: counter)!;
  }
}
