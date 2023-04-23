import 'dart:io' as io;
import 'dart:math';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_ui/server.dart';
import 'package:file_ui/utils.dart';
import 'package:flutter/material.dart';

import '../model/file.dart';
import '../widgets/adaptive_button.dart';

List<File> files = [];
int port = 0;

class PageForSend extends StatefulWidget {
  final Server server;
  const PageForSend({super.key, required this.server});

  @override
  State<PageForSend> createState() => _PageForSendState();
}

class _PageForSendState extends State<PageForSend> {
  FilePickerResult? result;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var server = widget.server;
    bool sending = server.started;
    widget.server.files = files.asMap().map((key, value) {
      value.id = key;
      return MapEntry(key, value);
    });
    return DropTarget(
      onDragDone: _onFileDropped,
      onDragEntered: (details) => setState(() => _dragging = true),
      onDragExited: (details) => setState(() => _dragging = false),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: _selectFiles,
                child: const Text("Select Files"),
              ),
              SizedBox(width: width * .05),
              AdaptiveOutlinedIconButton(
                onPressed: () async {
                  port = _getRandomPort;
                  sending = server.started;
                  if (sending) {
                    await server.stop();
                  } else {
                    await server.serve(port: port);
                  }
                  _trySetState(() => sending = server.started);
                },
                icon: Icon(
                  sending ? Icons.stop : Icons.send,
                  color: sending
                      ? Colors.redAccent
                      : Theme.of(context).primaryColor,
                ),
                label: Text(sending ? 'stop' : 'start'),
                toolTip: sending ? 'stop' : 'start',
              ),
              IconButton(
                onPressed: _clearFiles,
                icon: const Icon(Icons.clear_all),
                tooltip: 'clear',
              ),
            ],
          ),
          FutureBuilder<String?>(
            future: getPin(port),
            initialData: '',
            builder: (context, snapshot) {
              return Text("PIN: ${!sending ? '' : snapshot.data}");
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              color: _dragging
                  ? Theme.of(context).primaryColor.withAlpha(20)
                  : Colors.transparent,
              child: ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  var file = files[index];
                  return Dismissible(
                    key: Key('${file.path}'),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) {
                      _trySetState(() => files.removeAt(index));
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        file.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${file.path}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Text(file.size.H),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  int get _getRandomPort => Random().nextInt(1111) + 8888;

  void _selectFiles() async {
    result = await FilePicker.platform.pickFiles(allowMultiple: true);
    files = result?.files
            .map((e) => File(name: e.name, size: e.size, path: e.path))
            .toList() ??
        files;
    widget.server.files = files.asMap().map((key, value) {
      value.id = key;
      return MapEntry(key, value);
    });
    _trySetState();
  }

  void _trySetState([VoidCallback? fn]) {
    try {
      setState(fn ?? () {});
    } on Exception {
      return;
    }
  }

  void _onFileDropped(DropDoneDetails details) async {
    for (var file in details.files) {
      try {
        files.add(
          File(
            name: file.name,
            size: await file.length(),
            path: file.path,
          ),
        );
      } on io.FileSystemException {
        return;
      }
    }
    widget.server.files = files.asMap().map((key, value) {
      value.id = key;
      return MapEntry(key, value);
    });
    _trySetState();
  }

  void _clearFiles() async {
    await FilePicker.platform.clearTemporaryFiles();
    _trySetState(() => files.clear());
  }
}