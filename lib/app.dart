import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_transfer_app/pages/receive.dart';
import 'package:file_transfer_app/pages/send.dart';
import 'package:file_transfer_app/utils.dart';
import 'package:flutter/material.dart';

import 'server.dart';

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

  StreamSubscription<ConnectivityResult>? connectionSubscription;
  var mainContent = const [PageForSend(), PageForReceive()];

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
    bool isWideScreen = MediaQuery.of(context).size.width > 640;
    return Scaffold(
      appBar: AppBar(
        title: const Text("File Transfer"),
      ),
      bottomNavigationBar: !isWideScreen
          ? BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.file_upload),
                  label: 'send',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.file_download),
                  label: 'receive',
                )
              ],
              currentIndex: current,
              onTap: (value) => setState(() => current = value),
            )
          : null,
      body: FutureBuilder<bool>(
        future: checkForWifi(),
        initialData: false,
        builder: (context, snapshot) {
          bool haveNetwork = snapshot.data == true;
          if (isWideScreen) {
            return navigationRailwithContent(current, haveNetwork);
          }
          if (!haveNetwork) {
            return showAskForNetwork;
          }
          return mainContent[current];
        },
      ),
    );
  }

  Widget navigationRailwithContent(int current, bool hasNetwork) {
    return Row(
      children: [
        NavigationRail(
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.file_upload),
              label: Text('send'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.file_download),
              label: Text('receive'),
            ),
          ],
          selectedIndex: current,
          onDestinationSelected: (value) =>
              setState(() => this.current = value),
        ),
        Expanded(child: hasNetwork ? mainContent[current] : showAskForNetwork)
      ],
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
        )
      ],
    );
  }
}
