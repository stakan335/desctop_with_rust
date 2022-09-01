import 'dart:ffi';
import 'dart:io';

import 'package:desktop_with_rust/bridge_generated.dart';
import 'package:flutter/material.dart';

// To use the bundled libc++ please add the following LDFLAGS:
//   LDFLAGS="-L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib"

// llvm is keg-only, which means it was not symlinked into /usr/local,
// because macOS already provides this software and installing another version in
// parallel can cause all kinds of trouble.

// If you need to have llvm first in your PATH, run:
//   echo 'export PATH="/usr/local/opt/llvm/bin:$PATH"' >> ~/.zshrc

// For compilers to find llvm you may need to set:
//   export LDFLAGS="-L/usr/local/opt/llvm/lib"
//   export CPPFLAGS="-I/usr/local/opt/llvm/include"

const base = "rust";
final path = Platform.isWindows ? "$base.dll" : "lib$base.so";
late final dylib = Platform.isIOS
    ? DynamicLibrary.process()
    : Platform.isMacOS
        ? DynamicLibrary.executable()
        : DynamicLibrary.open(path);

late final api = RustImpl(dylib);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<int> counter;

  @override
  void initState() {
    super.initState();

    counter = api.getCounter();
  }

  void _incrementCounter() {
    setState(() {
      counter = api.increment();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            FutureBuilder(
              future: counter,
              builder: (counter, snap) {
                return Text(
                  '${snap.data}',
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
