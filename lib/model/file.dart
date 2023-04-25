import 'dart:io' as io;
import 'package:path/path.dart' as p;

class File {
  final String name;
  final int size;
  String? path;
  String? id;

  File({required this.name, required this.size, this.path, this.id});

  Map<String, dynamic> toJson() {
    return {'name': name, 'size': size, 'id': id};
  }

  factory File.fromMap(Map<String, dynamic> map) {
    return File(
      name: map["name"],
      size: map["size"],
      path: map['path'],
      id: map['id'],
    );
  }

  factory File.fromIOFile(io.File file) {
    return File(
      name: p.basename(file.path),
      size: file.lengthSync(),
      path: file.path,
    );
  }

  @override
  String toString() => toJson().toString();
}
