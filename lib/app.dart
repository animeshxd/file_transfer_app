import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'pages/receive.dart';
import 'pages/send.dart';
import 'services/server.dart';
import 'services/utils.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transfer App',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int current = 0;
  var server = Server();
  bool useTethering = false;

  StreamSubscription<ConnectivityResult>? connectionSubscription;

  @override
  void dispose() async {
    super.dispose();
    server.stop();
    await FilePicker.platform.clearTemporaryFiles();
    await connectionSubscription?.cancel();
  }

  @override
  void initState() {
    super.initState();
    connectionSubscription =
        Connectivity().onConnectivityChanged.listen((e) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    var body = [
      PageForSend(
        useTethering: useTethering,
      ),
      const PageForReceive()
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("File Transfer"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.file_upload), label: 'send'),
          BottomNavigationBarItem(
              icon: Icon(Icons.file_download), label: 'receive')
        ],
        currentIndex: current,
        onTap: (value) => setState(() => current = value),
      ),
      body: FutureBuilder<bool>(
        future: checkForWifi(),
        initialData: false,
        builder: (context, snapshot) {
          if (snapshot.data == false && useTethering != true) {
            return showAskForNetwork;
          }
          return body[current];
        },
      ),
    );
  }

  Widget get showAskForNetwork {
    return AlertDialog(
      title: const Text("No Local Network Found"),
      content: const Text("Please connect to Wifi or Wired Network"),
      actions: [
        TextButton(
          onPressed: () => setState(() {}),
          child: const Text("OK"),
        ),
        TextButton(
          onPressed: () => setState(
            () {
              useTethering = true;
            },
          ),
          child: const Text("I will use tethering"),
        )
      ],
    );
  }
}
