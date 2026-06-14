import 'package:flutter/material.dart';
import 'package:rust_ohos_app/api/hello.dart';
import 'package:rust_ohos_app/api/ffi.dart';
import 'package:rust_ohos_app/frb_generated.dart' show RustLib;
import 'dart:async';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late int sumResult;
  late Future<int> sumAsyncResult;

  @override
  void initState() {
    super.initState();
    // sumResult = rust_ohos_app.sum(1, 2);
    // sumAsyncResult = rust_ohos_app.sumAsync(3, 4);

    // final helloResult = hello(hello: 'Hello from Dart!');
    // debugPrint('helloResult: $helloResult');
    // rust_ohos_app.
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // setState(() {
            //   sumResult = rust_ohos_app.sum(sumResult, 1);
            //   sumAsyncResult = rust_ohos_app.sumAsync(sumResult, 1);
            // });
            await hello(hello: 'Hello from Dart!');
            final sumResult = await sum(a: 1, b: 2);
            debugPrint('sumResult: $sumResult');
            final sumAsyncResult = await sumLongRunning(a: 3, b: 4);
            debugPrint('sumAsyncResult: $sumAsyncResult');
          },
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(title: const Text('Native Packages')),
        // body: SingleChildScrollView(
        //   child: Container(
        //     padding: const .all(10),
        //     child: Column(
        //       children: [
        //         const Text(
        //           'This calls a native function through FFI that is shipped as source in the package. '
        //           'The native code is built as part of the Flutter Runner build.',
        //           style: textStyle,
        //           textAlign: .center,
        //         ),
        //         spacerSmall,
        //         Text(
        //           'sum(1, 2) = $sumResult',
        //           style: textStyle,
        //           textAlign: .center,
        //         ),
        //         spacerSmall,
        //         FutureBuilder<int>(
        //           future: sumAsyncResult,
        //           builder: (BuildContext context, AsyncSnapshot<int> value) {
        //             final displayValue = (value.hasData)
        //                 ? value.data
        //                 : 'loading';
        //             return Text(
        //               'await sumAsync(3, 4) = $displayValue',
        //               style: textStyle,
        //               textAlign: .center,
        //             );
        //           },
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
