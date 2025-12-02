import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'IOS_CLIENT_ID')
  static const String iosClientID = _Env.iosClientID;
}
