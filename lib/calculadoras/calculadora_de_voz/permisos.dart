import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  await Permission.microphone.request();
}
