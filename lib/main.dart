import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'fabric_dialog.dart';
import 'fabric_painter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

final MAX_CANVAS_WIDTH = 700.0;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plans de coupe de tapisserie',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Plans de coupe de tapisserie'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _fabricName = "Super tissu";
  double _fabricWidth = 140.0;
  double _pricePerMeter = 50.0;
  ({double patternWidth, double patternLength})? _pattern;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _fabricsFile async {
    final path = await _localPath;
    return File('$path/fabrics.json');
  }

  Future<void> _writeFabrics() async {
    final file = await _fabricsFile;
    await file.writeAsString(jsonEncode([
      {
        "name": _fabricName,
        "width": _fabricWidth,
        "price": _pricePerMeter,
        "pattern": _pattern != null
            ? {
                "width": _pattern!.patternWidth,
                "length": _pattern!.patternLength
              }
            : null
      }
    ]));
  }

  Future<void> _readFabrics() async {
    final file = await _fabricsFile;
    if (!await file.exists()) {
      return;
    }
    final contents = await file.readAsString();
    final fabrics = jsonDecode(contents);
    final fabric = fabrics[0];
    setState(() {
      _fabricName = fabric["name"];
      _fabricWidth = fabric["width"];
      _pricePerMeter = fabric["price"];
      _pattern = fabric["pattern"] != null
          ? (
              patternWidth: fabric["pattern"]["width"],
              patternLength: fabric["pattern"]["length"]
            )
          : null;
    });
  }

  var panel = {
    "width": 0.0,
    "length": 0.0,
    "quantity": 1,
  };
  final _panelWidthController = TextEditingController();
  final _panelLengthController = TextEditingController();
  final _panelQuantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _panelWidthController.addListener(() {
      setState(() {
        panel["width"] = double.parse(_panelWidthController.text);
      });
    });
    _panelLengthController.addListener(() {
      setState(() {
        panel["length"] = double.parse(_panelLengthController.text);
      });
    });
    _panelQuantityController.addListener(() {
      setState(() {
        panel["quantity"] = int.parse(_panelQuantityController.text);
      });
    });
    _panelWidthController.text = '${panel["width"]}';
    _panelLengthController.text = '${panel["length"]}';
    _panelQuantityController.text = '${panel["quantity"]}';

    _readFabrics();
  }

  @override
  void dispose() {
    _panelWidthController.dispose();
    _panelLengthController.dispose();
    _panelQuantityController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListView(
          children: <Widget>[
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Tissu "$_fabricName"'),
                    subtitle: const Text('Caractéristiques du tissu'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0.0),
                    child: Table(
                        border: const TableBorder(
                            horizontalInside: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        )),
                        children: [
                          {
                            "title": "Largeur de tissu",
                            "value": '$_fabricWidth cm'
                          },
                          {
                            "title": "Prix au mètre",
                            "value": '$_pricePerMeter €'
                          },
                          {
                            "title": "Motif",
                            "value": _pattern != null
                                ? '${_pattern!.patternWidth}x${_pattern!.patternLength} cm'
                                : 'Non'
                          },
                        ].map((e) {
                          return TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(e["title"]!)),
                              ),
                              TableCell(
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(e["value"]!)),
                              ),
                            ],
                          );
                        }).toList()),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return FabricDialogContent(
                                  fabricName: "Super tissu",
                                  fabricWidth: _fabricWidth,
                                  pricePerMeter: _pricePerMeter,
                                  pattern: _pattern,
                                  onSave: (
                                      {required fabricName,
                                      required fabricWidth,
                                      required pattern,
                                      required pricePerMeter}) {
                                    setState(() {
                                      _fabricWidth = fabricWidth;
                                      _pricePerMeter = pricePerMeter;
                                      _fabricName = fabricName;
                                      _pattern = pattern;
                                    });
                                    _writeFabrics();
                                  },
                                );
                              });
                        },
                        child: const Text('Modifier'),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Flexible(
                    child: TextField(
                  keyboardType: const TextInputType.numberWithOptions(),
                  decoration: const InputDecoration(
                    label: Text('Longueur en cm'),
                  ),
                  onChanged: (value) => setState(() {}),
                  controller: _panelLengthController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                )),
                const SizedBox(
                  width: 10.0,
                ),
                Flexible(
                    child: TextField(
                  keyboardType: const TextInputType.numberWithOptions(),
                  decoration: const InputDecoration(
                    label: Text('Largeur en cm'),
                  ),
                  onChanged: (value) => setState(() {}),
                  controller: _panelWidthController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                )),
                const SizedBox(
                  width: 10.0,
                ),
                Flexible(
                    child: TextField(
                  keyboardType: const TextInputType.numberWithOptions(),
                  decoration: const InputDecoration(
                    label: Text('Quantité'),
                  ),
                  onChanged: (value) => setState(() {}),
                  controller: _panelQuantityController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                )),
              ],
            ),
            const SizedBox.square(
              dimension: 10.0,
            ),
            Container(
              alignment: Alignment.center,
              child: LayoutBuilder(builder: (context, constraints) {
                return CustomPaint(
                  painter: FabricPainter(() => (_fabricWidth, _pattern)),
                  size: Size(
                      min(constraints.maxWidth, MAX_CANVAS_WIDTH),
                      200 *
                          min(constraints.maxWidth, MAX_CANVAS_WIDTH) /
                          _fabricWidth),
                );
              }),
            ),
            const SizedBox.square(
              dimension: 10.0,
            ),
          ],
        ),
      ),
    );
  }
}
