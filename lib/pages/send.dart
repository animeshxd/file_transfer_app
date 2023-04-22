import 'dart:io';
import 'dart:math';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_ui/utils.dart';
import 'package:flutter/material.dart';

import '../widgets/adaptive_button.dart';

List<PlatformFile> files = [];
int port = 0;

class PageForSend extends StatefulWidget {
  const PageForSend({super.key});

  @override
  State<PageForSend> createState() => _PageForSendState();
}

class _PageForSendState extends State<PageForSend> {
  FilePickerResult? result;
  bool _dragging = false;
  bool _sending = false;
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return DropTarget(
      onDragDone: (details) async {
        for (var file in details.files) {
          try {
            files.add(
              PlatformFile(
                name: file.name,
                size: await file.length(),
                path: file.path,
              ),
            );
          } on FileSystemException {
            return;
          }
        }
        setState(() {});
      },
      onDragEntered: (details) => setState(() => _dragging = true),
      onDragExited: (details) => setState(() => _dragging = false),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () async {
                  // files.clear();
                  result =
                      await FilePicker.platform.pickFiles(allowMultiple: true);
                  files = result?.files ?? files;
                  setState(() {});
                },
                child: const Text("Select Files"),
              ),
              SizedBox(width: width * .05),
              AdaptiveOutlinedIconButton(
                onPressed: () {
                  port = Random().nextInt(1112) + 8888;
                  setState(() => _sending = !_sending);
                },
                icon: Icon(
                  _sending ? Icons.stop : Icons.send,
                  color: _sending
                      ? Colors.redAccent
                      : Theme.of(context).primaryColor,
                ),
                label: Text(_sending ? 'stop' : 'start'),
                toolTip: _sending ? 'stop' : 'start',
              ),
              IconButton(
                onPressed: () => setState(() => files.clear()),
                icon: const Icon(Icons.clear_all),
                tooltip: 'clear',
              ),
            ],
          ),
          FutureBuilder<String?>(
            future: getPin(port),
            initialData: '',
            builder: (context, snapshot) {
              return Text("PIN: ${!_sending ? '' : snapshot.data}");
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
                      setState(() => files.removeAt(index));
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
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
                      trailing: StreamBuilder(
                        builder: (context, snapshot) {
                          return Text(file.size.H);
                        } /*Icon(Icons.access_time)*/,
                      ),
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
}

