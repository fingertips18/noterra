import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'IOS_CLIENT_ID')
  static const String iosClientID = _Env.iosClientID;

  @EnviedField(varName: 'GEMINI_API_KEY')
  static const String geminiAPIKey = _Env.geminiAPIKey;
}
