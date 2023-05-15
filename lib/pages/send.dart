import 'dart:io' as io;
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../model/file.dart';
import '../services/server.dart';
import '../services/utils.dart';
import '../widgets/adaptive_button.dart';

List<File> _files = [];
String pin = "";

class PageForSend extends StatefulWidget {
  final bool useTethering;
  const PageForSend({super.key, required this.useTethering});

  @override
  State<PageForSend> createState() => _PageForSendState();
}

class _PageForSendState extends State<PageForSend> {
  bool _dragging = false;
  bool _loadingFile = false;
  bool _sending = false;
  final Server server = Server();

  @override
  void initState() {
    super.initState();
    _sending = server.started;
    _updateServerFiles(server, _files);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    _updateServerFiles(server, _files);

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
                onPressed: _startOrStopServer,
                icon: Icon(
                  _sending ? Icons.stop : Icons.send,
                  color: _sending
                      ? Colors.redAccent
                      : Theme.of(context).primaryColor,
                ),
                toolTip: _sending ? 'stop' : 'start',
              ),
              IconButton(
                onPressed: _clearFiles,
                icon: const Icon(Icons.clear_all),
                tooltip: 'clear',
              ),
            ],
          ),
          Text("PIN: ${pin.isNotEmpty ? pin : "not found"}"),
          Visibility(
            visible: _loadingFile,
            child: Container(
              width: width,
              height: 30,
              color: Colors.red,
              child: const Center(
                child: Text(
                  "loading a big file, please wait...",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              color: _dragging
                  ? Theme.of(context).primaryColor.withAlpha(20)
                  : Colors.transparent,
              child: ListView.builder(
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  var file = _files[index];
                  return Dismissible(
                    key: Key('${file.path}'),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) {
                      _trySetState(() => _files.removeAt(index));
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

  void _startOrStopServer() async {
    _sending = server.started;
    pin = "";
    if (_sending) {
      await server.stop();
    } else {
      var port = _getRandomPort;
      await _setPin(port);
      _updateServerFiles(server, _files);
      await server.serve(port: port);
    }
    _trySetState(() => _sending = server.started);
  }

  Future<void> _setPin(int port) async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.wifi ||
        connectivity == ConnectivityResult.ethernet) {
      pin = (await getPin(port)) ?? "";
    } else {
      pin = port.toString();
    }
  }

  void _selectFiles() async {
    var result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      onFileLoading: (status) {
        _loadingFile = status == FilePickerStatus.picking;
        _trySetState();
      },
    );
    _files.addAll(
      result?.files
              .map((e) => File(name: e.name, size: e.size, path: e.path))
              .toList() ??
          [],
    );
    _updateServerFiles(server, _files);
    _trySetState();
  }

  var uuid = const Uuid();
  void _updateServerFiles(Server server, List<File> files) {
    server.files = files.asMap().map((key, value) {
      value.id = uuid.v4().toString();
      return MapEntry(value.id!, value);
    });
  }

  void _trySetState([VoidCallback? fn]) {
    try {
      setState(fn ?? () {});
    } catch (e) {
      return;
    }
  }

  void _onFileDropped(DropDoneDetails details) async {
    for (var file in details.files) {
      try {
        _files.add(
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
    _updateServerFiles(server, _files);
    _trySetState();
  }

  void _clearFiles() async {
    if (io.Platform.isAndroid || io.Platform.isIOS) {
      await FilePicker.platform.clearTemporaryFiles();
    }
    _trySetState(() => _files.clear());
  }
}
