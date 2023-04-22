
import 'package:file_ui/pages/receive.dart';
import 'package:file_ui/pages/send.dart';
import 'package:flutter/material.dart';

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

  var body = [const PageForSend(), const PageForReceive()];
  @override
  Widget build(BuildContext context) {
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
      body: body[current],
    );
  }
}

