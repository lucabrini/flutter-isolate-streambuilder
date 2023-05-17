import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Isolate - StreamBuilder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Page(title: 'Isolate StreamBuilder Demo'),
    );
  }
}

class Page extends StatefulWidget {
  const Page({super.key, required this.title});

  final String title;

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  late ReceivePort receivePort;

  @override
  void initState() {
    receivePort = spawnIsolate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: StreamBuilder(
        stream: receivePort.asBroadcastStream(),
        builder: _builder,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.title),
    );
  }

  Widget _builder(BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildChildren(snapshot),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(AsyncSnapshot snapshot) {
    return [
      Text(
        snapshot.hasData
            ? 'Current Progress: ${snapshot.data}/100'
            : 'No data yet',
      ),
      LinearProgressIndicator(
        value: snapshot.hasData ? snapshot.data / 100 : 0,
        backgroundColor: Colors.orangeAccent,
        valueColor: const AlwaysStoppedAnimation(Colors.blue),
        minHeight: 25,
      ),
    ];
  }
}

// Function used to spawn an isolate
ReceivePort spawnIsolate() {
  final receivePort = ReceivePort();
  Isolate.spawn(heavyWork, receivePort.sendPort);
  return receivePort;
}

// Top level background function
heavyWork(SendPort sendPort) {
  sleep(const Duration(seconds: 5));

  for (double i = 0; i < 100; i++) {
    sleep(const Duration(milliseconds: 200));
    sendPort.send(i);
  }

  Isolate.exit(sendPort, 100.0);
}
