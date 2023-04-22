import 'package:network_info_plus/network_info_plus.dart';

extension IntExt on int {
  String get H {
    if (this < 1024) return '$this B';
    if(this > 999999999) return "${(this / (1024 * 1024 * 1024)).roundToDouble()}GB";
    if (this > 999999) return "${(this / (1024 * 1024)).roundToDouble()}MB";
    return '${(this / 1024).roundToDouble()}KB';
  }
}
Future<String?> getPin(int port) async {
  final info = NetworkInfo();
  var ip = await info.getWifiIP();
  var gateway = await info.getWifiGatewayIP();
  ip!;
  gateway!;
  var pin = '';
  var ip0 = ip.split('.');
  var gateway0 = gateway.split('.');
  for (int i = 3; i >= 0; i--) {
    if (gateway0[i] != ip0[i]) {
      pin = ip0[i];
    }
  }
  
  return "$pin$port";
}
