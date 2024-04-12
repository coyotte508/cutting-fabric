import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'fabric_dialog.dart';
import 'fabric_painter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import "fabric.dart";

void main() {
  runApp(const MyApp());
}

const maxCanvasWidth = 700.0;

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
  FabricInfo _fabric = FabricInfo(
    width: 140.0,
    name: "Super tissu",
    pricePerMeter: 50.0,
  );
  bool _showPattern = true;

  late SharedPreferences prefs;

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
    await file.writeAsString(jsonEncode([_fabric.toJson()]));
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
      _fabric = FabricInfo.fromJson(fabric);
    });
  }

  List<PanelInfo> panel = [
    PanelInfo(
        width: 50.0,
        length: 50.0,
        quantity: 1,
        name: "Panel 1",
        centerOnPattern: false)
  ];

  final _panelWidthController = TextEditingController();
  final _panelLengthController = TextEditingController();
  final _panelQuantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _panelWidthController.addListener(() {
      setState(() {
        panel[0].width = double.parse(_panelWidthController.text);
      });
    });
    _panelLengthController.addListener(() {
      setState(() {
        panel[0].length = double.parse(_panelLengthController.text);
      });
    });
    _panelQuantityController.addListener(() {
      setState(() {
        panel[0].quantity = int.parse(_panelQuantityController.text);
      });
    });
    _panelWidthController.text = '${panel[0].width}';
    _panelLengthController.text = '${panel[0].length}';
    _panelQuantityController.text = '${panel[0].quantity}';

    _readFabrics();

    SharedPreferences.getInstance().then((prefs) {
      this.prefs = prefs;
      setState(() {
        _showPattern = prefs.getBool("showPattern") ?? true;
      });
    });
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
                    title: Text('Tissu "${_fabric.name}"'),
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
                            "value": '${_fabric.width} cm'
                          },
                          {
                            "title": "Prix au mètre",
                            "value": '${_fabric.pricePerMeter} €'
                          },
                          {
                            "title": "Motif",
                            "value": _fabric.pattern != null
                                ? '${_fabric.pattern!.width}x${_fabric.pattern!.length} cm'
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
                                  fabric: _fabric.clone(),
                                  onSave: (FabricInfo fabric) {
                                    setState(() {
                                      _fabric = fabric;
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
            ...(_fabric.pattern != null
                ? [
                    CheckboxListTile(
                      value: _showPattern,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (value) {
                        setState(() {
                          _showPattern = value!;
                        });
                        prefs.setBool("showPattern", value!);
                      },
                      title: const Text("Afficher motif sur plan de coupe"),
                    )
                  ]
                : []),
            const SizedBox.square(
              dimension: 10.0,
            ),
            Container(
              alignment: Alignment.center,
              child: LayoutBuilder(builder: (context, constraints) {
                return CustomPaint(
                  painter: FabricPainter(
                      () => (_fabric.width, _showPattern, _fabric.pattern)),
                  size: Size(
                      min(constraints.maxWidth, maxCanvasWidth),
                      200 *
                          min(constraints.maxWidth, maxCanvasWidth) /
                          _fabric.width),
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
