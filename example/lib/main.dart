import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_zip_archive/flutter_zip_archive.dart';
import 'package:path_provider/path_provider.dart';

const String? password = null;

Future<File> copy(String fname) async {
  Directory tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/x/$fname');
  if (file.existsSync()) file.deleteSync(recursive: true);
  await file.create(recursive: true);
  Uint8List bytes =
      (await rootBundle.load('images/$fname')).buffer.asUint8List();
  await file.writeAsBytes(bytes);
  return file;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await copy('start.png');
  await copy('area.png');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterZipArchivePlugin = FlutterZipArchive();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? platformVersion;
    String? result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _flutterZipArchivePlugin.getPlatformVersion();
      print(platformVersion);
      Directory tempDir = await getTemporaryDirectory();
      final o1 = File("${tempDir.path}/out1.zip");
      if (o1.existsSync()) o1.deleteSync();
      result = await _flutterZipArchivePlugin.zip("${tempDir.path}/x/start.png", o1.path, password);
      print(result);
      print(await o1.length());
      final o2 = File("${tempDir.path}/out2.zip");
      if (o2.existsSync()) o2.deleteSync();
      result = await _flutterZipArchivePlugin.zip("${tempDir.path}/x", o2.path, password);
      print(result);
      print(await o2.length());
    }
    catch (e) {
      platformVersion = 'Error platform: $e';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = "$platformVersion";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(
              Icons.create,
            ),
            onPressed: () {
              print("Pressed");
            }),
      ),
    );
  }
}
