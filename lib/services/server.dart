import 'dart:convert';
import 'dart:io' as io;

import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as sio;
import 'package:shelf_router/shelf_router.dart';

import '../model/file.dart';

class Server {
  static final instance = Server._();
  factory Server() {
    return instance;
  }

  bool started = false;
  var app = Router();
  io.HttpServer? _server;
  Map<String, File> files = {};

  Server._() {
    app
      ..get('/file/<id>', _getFile)
      ..get('/files', _getFiles);
  }

  Response _getFiles(Request request) {
    return Response.ok(
      json.encode(files.map((key, value) => MapEntry(key.toString(), value))),
      headers: {
        io.HttpHeaders.contentTypeHeader: io.ContentType.json.toString()
      },
    );
  }

  Response _getFile(Request request, String id) {
    var f = files[id];
    if (f == null) return Response.notFound('not found');
    var file = io.File(f.path!);
    var filename = p.basename(file.path);
    var contentType =
        MimeTypeResolver().lookup(file.path) ?? io.ContentType.binary;
    var headers = {
      io.HttpHeaders.contentTypeHeader: contentType.toString(),
      io.HttpHeaders.contentLengthHeader: file.lengthSync().toString(),
      'Content-Disposition':
          'attachment; filename="${Uri.encodeComponent(filename)}"'
    };
    return Response.ok(file.openRead(), headers: headers);
  }

  Future<io.HttpServer> serve({int port = 8080}) async {
    _server ??= await sio.serve(app, io.InternetAddress.anyIPv4, port);
    started = true;
    return _server!;
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    started = false;
    _server = null;
  }
}
