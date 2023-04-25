import 'dart:io';

import 'package:download_manager/download_manager.dart';
import 'package:file_ui/client.dart';
import 'package:file_ui/model/file.dart';
import 'package:file_ui/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/adaptive_button.dart';

class PageForReceive extends StatefulWidget {
  const PageForReceive({super.key});

  @override
  State<PageForReceive> createState() => _PageForReceiveState();
}

String pin = '';
List<File> files = [];

// ignore: constant_identifier_names
enum ServerFoundState { FOUND, NOTFOUND, FAILED }

var _serverFound = ServerFoundState.NOTFOUND;

class _PageForReceiveState extends State<PageForReceive> {
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _getFiles();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: width * .3,
              child: Form(
                key: _formKey,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: pin,
                  onChanged: _onFormFieldChanged,
                  validator: _pinValidator,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'enter pin',
                    contentPadding: EdgeInsets.all(14),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            SizedBox(width: width * .05),
            AdaptiveOutlinedIconButton(
              onPressed: _onFormSubmitted,
              icon: Icon(
                Icons.done,
                color: _serverFound == ServerFoundState.FAILED
                    ? Colors.red
                    : _serverFound == ServerFoundState.FOUND
                        ? Colors.green
                        : Theme.of(context).primaryColor,
              ),
              toolTip: _serverFound == ServerFoundState.FOUND
                  ? 'connected'
                  : 'connect',
            ),
            IconButton(
              onPressed: _onFormSubmitted,
              icon: const Icon(Icons.refresh),
              tooltip: 'refresh',
            )
          ],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _getFiles(),
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                var file = files[index];
                return ListTile(
                  title: Text(
                    file.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Size: ${file.size.H}'),
                  trailing: IconButton(
                    onPressed: () {
                      _downloadHandler(file);
                      _runOnAndroid(
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Download Started: ${file.name}"),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.download),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _downloadHandler(File file) async {
    var hostPort = await getHostPort(pin);
    var ip = hostPort.ip;
    var port = hostPort.port;
    var url = "http://$ip:$port/file/${file.id}";
    if (Platform.isAndroid) {
      await downloadFile(url: url, filename: file.name);
      return;
    }

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  void _runOnAndroid(VoidCallback fn) {
    if (Platform.isAndroid) fn();
  }

  void _getFiles() async {
    if (_pinValidator(pin) != null) return;
    var hostPort = await getHostPort(pin);
    try {
      files =
          (await Client().files(hostPort.ip, hostPort.port)).values.toList();
    } on ClientException {
      _serverFound = ServerFoundState.FAILED;
      files.clear();
      _trySetState();
      return;
    }
    _serverFound = ServerFoundState.FOUND;
    _trySetState();
  }

  String? _pinValidator(value) {
    if (value == null || value.isEmpty) return '';
    if (value.length < 5 || !RegExp(r'\d+').hasMatch(value)) {
      return "invalid pin";
    }
    var port = int.parse(pin.substring(pin.length - 4, pin.length));
    if (port < 8888) return 'invalid pin';
    pin = value;
    return null;
  }

  void _onFormSubmitted() async => _getFiles();

  void _trySetState([VoidCallback? fn]) {
    try {
      setState(fn ?? () {});
    } catch (e) {
      return;
    }
  }

  void _onFormFieldChanged(String value) {
    pin = value;
    _serverFound = ServerFoundState.NOTFOUND;
    files.clear();
    _trySetState();
  }
}
