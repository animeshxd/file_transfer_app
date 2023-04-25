import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'model/file.dart';

class Client {
  Future<Map<String, File>> files(String ip, int port) async {
    try {
      var res = await http.get(Uri.http('$ip:$port', '/files'));
      if (res.statusCode == 404) return {};
      return (json.decode(res.body) as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, File.fromMap(value)));
    } on SocketException {
      throw ClientException();
    } catch (e) {
      return {};
    }
  }
}

class ClientException extends Error {}
