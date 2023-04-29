// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_info_windows/network_info_windows.dart';

const IF_TYPE_ETHERNET_CSMACD = 6;
const IF_TYPE_IEEE80211 = 71;
const IfOperStatusUp = 1;

typedef VoidCallback = void Function();

extension IntExt on int {
  String get H {
    if (this < 1024) return '$this B';
    if (this > 999999999) {
      return "${(this / (1024 * 1024 * 1024)).roundToDouble()}GB";
    }
    if (this > 999999) return "${(this / (1024 * 1024)).roundToDouble()}MB";
    return '${(this / 1024).roundToDouble()}KB';
  }
}

extension ListExt<T> on List<T> {
  T? get firstOrNull {
    if (length == 0) {
      return null;
    } else {
      return first;
    }
  }
}

Future<String?> getPin(int port) async {
  String? ip;
  String? gateway;
  if (Platform.isWindows) {
    final infos = await NetworkInfoWindows().GetAdaptersInfo();
    var info = infos.entries.where((element) {
      var OperStatus = element.value["OperStatus"];
      var IfType = element.value["IfType"];

      return OperStatus == IfOperStatusUp &&
          (IfType == IF_TYPE_ETHERNET_CSMACD || IfType == IF_TYPE_IEEE80211);
    }).first;
    ip = List<String>.from(info.value["UnicastAddress"]?["AF_INET"] ?? [])
        .firstOrNull;
    gateway = List<String>.from(info.value["GatewayAddress"]?["AF_INET"] ?? [])
        .firstOrNull;
  } else {
    final info = NetworkInfo();
    ip = await info.getWifiIP();
    gateway = await info.getWifiGatewayIP();
  }
  if (ip == null || gateway == null) return null;
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

void runOnAndroid(VoidCallback fn, [VoidCallback? elseFn]) {
  Platform.isAndroid ? fn() : elseFn?.call();
}

void runOnWindows(VoidCallback fn, [VoidCallback? elseFn]) {
  Platform.isWindows ? fn() : elseFn?.call();
}
