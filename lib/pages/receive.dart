import 'package:file_ui/utils.dart';
import 'package:flutter/material.dart';

import '../widgets/adaptive_button.dart';

class PageForReceive extends StatefulWidget {
  const PageForReceive({super.key});

  @override
  State<PageForReceive> createState() => _PageForReceiveState();
}

class _PageForReceiveState extends State<PageForReceive> {
  List<_File> files = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    files = getFiles();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.width;
    // print(width);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: width * .3,
              child: Form(key: _formKey, child: TextFormField()),
            ),
            SizedBox(
              width: width * .05,
            ),
            AdaptiveOutlinedIconButton(
              onPressed: () {},
              icon: const Icon(Icons.done),
              label: const Text('connect'),
              toolTip: 'connect',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.refresh),
              tooltip: 'refresh',
            )
          ],
        ),
        Expanded(
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
                trailing: IconButton(onPressed: (){}, icon: const Icon(Icons.download)),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _File {
  final int id;
  final String name;
  final int size;

  _File({required this.name, required this.size, required this.id});

  Map<String, Object> toJson() {
    return {'name': name, 'size': size};
  }
}

List<_File> getFiles() {
  return [
    _File(id: 1, name: 'pubspec.yaml', size: 10),
    _File(id: 2, name: 'pubspec.lock', size: 10),
    _File(id: 3, name: 'analysis_options.yaml', size: 999999990),
  ];
}
