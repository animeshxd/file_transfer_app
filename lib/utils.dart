import 'package:connectivity_plus/connectivity_plus.dart';
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

class HostPort {
  final String ip;
  final int port;

  HostPort(this.ip, this.port);
}

Future<HostPort> getHostPort(String pin) async {
  final info = NetworkInfo();
  var ip = await info.getWifiIP();
  var gateway = await info.getWifiGatewayIP();
  ip!;
  gateway!;
  // print(ip);
  var port = pin.substring(pin.length - 4, pin.length);
  // print(port);
  var ip0 = ip.split('.');
  var gateway0 = gateway.split('.');

  List<String> ips = [];

  for (int i = 0; i < 4; i++) {
    if (gateway0[i] == ip0[i]) ips.add(ip0[i]);
  }
  var pins = pin.substring(0, pin.length - 4).split('.');
  ips.addAll(pins);

  for (var ip in ips) {
    if (int.parse(ip) > 254) throw Exception();
  }
  if (pins.length > 4) throw Exception();

  if (ips.length >= 5) {
    List<String> result = [];
    if (ips.length + pins.length > 4) {
      ips = ips.sublist(0, ips.length - (ips.length + pins.length - 4));
    }
    result.addAll(ips);
    result.addAll(pins.sublist(0, 4 - ips.length));
    return HostPort(result.join('.'), int.parse(port));
  }
  return HostPort(ips.join('.'), int.parse(port));
}

Future<bool> checkForWifi() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  switch (connectivityResult) {
    case ConnectivityResult.ethernet:
    case ConnectivityResult.wifi:
      return true;

    default:
      return false;
  }
}
