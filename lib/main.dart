import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:upholstery_cutting_tool/panel_dialog.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
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

  Future<File> get _panelsFile async {
    final path = await _localPath;
    return File('$path/panels.json');
  }

  Future<void> _writeFabrics() async {
    final file = await _fabricsFile;
    await file.writeAsString(jsonEncode([_fabric.toJson()]));
  }

  Future<void> _writePanels() async {
    final file = await _panelsFile;
    await file.writeAsString(jsonEncode(_panels.map((e) => e.toJson()).toList()));
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

  Future<void> _readPanels() async {
    final file = await _panelsFile;
    if (!await file.exists()) {
      return;
    }
    final contents = await file.readAsString();
    final List<dynamic> panels = jsonDecode(contents).map((e) => PanelInfo.fromJson(e)).toList();
    setState(() {
      _panels.clear();
      for (var panel in panels) {
        _panels.add(panel);
      }
    });
  }

  final List<PanelInfo> _panels = [
    PanelInfo(width: 50.0, length: 50.0, quantity: 1, name: "Découpe 1", centerOnPattern: false, canRotate: false)
  ];

  @override
  void initState() {
    super.initState();

    _readFabrics();
    _readPanels();

    SharedPreferences.getInstance().then((prefs) {
      this.prefs = prefs;
      setState(() {
        _showPattern = prefs.getBool("showPattern") ?? true;
      });
    });
  }

  @override
  void dispose() {
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
                          {"title": "Largeur de tissu", "value": '${_fabric.width} cm'},
                          {"title": "Prix au mètre", "value": '${_fabric.pricePerMeter} €'},
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
                                    padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(e["title"]!)),
                              ),
                              TableCell(
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(e["value"]!)),
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
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListTile(
                    title: Text('Découpes à réaliser'),
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
                          const TableRow(children: [
                            TableCell(
                              child: Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('Nom')),
                            ),
                            TableCell(
                              child: Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('Dimensions')),
                            ),
                            TableCell(
                              child: Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('Qté')),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(''),
                              ),
                            ),
                          ]),
                          ..._panels.map((panel) {
                            return TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(panel.name)),
                                ),
                                TableCell(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text("${panel.width}x${panel.length} cm")),
                                ),
                                TableCell(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(panel.quantity.toString())),
                                ),
                                TableCell(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                          tooltip: panel.canRotate ? "Rotation autorisée" : "Rotation bloquée",
                                          onPressed: () {
                                            setState(() {
                                              panel.canRotate = !panel.canRotate;
                                            });
                                          },
                                          icon: Icon(panel.canRotate
                                              ? Icons.screen_rotation_outlined
                                              : Icons.screen_lock_rotation_outlined)),
                                      IconButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return PanelDialogContent(
                                                    panel: panel.clone(),
                                                    onSave: (PanelInfo updatedPanel) {
                                                      setState(() {
                                                        _panels[_panels.indexOf(panel)] = updatedPanel;
                                                      });
                                                      _writePanels();
                                                    },
                                                  );
                                                });
                                          },
                                          visualDensity: VisualDensity.compact,
                                          icon: const Icon(Icons.edit)),
                                      IconButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text("Supprimer la découpe"),
                                                    content: const Text(
                                                        "Êtes-vous sûr de vouloir supprimer cette découpe ?"),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              _panels.remove(panel);
                                                            });
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: const Text("Oui")),
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: const Text("Non")),
                                                    ],
                                                  );
                                                });
                                          },
                                          padding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.compact,
                                          color: Colors.red,
                                          icon: const Icon(Icons.delete_outlined))
                                    ],
                                  ),
                                )
                              ],
                            );
                          })
                        ]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return PanelDialogContent(
                                  panel: PanelInfo(
                                      canRotate: false,
                                      centerOnPattern: false,
                                      length: 50.0,
                                      name: "Découpe ${_panels.length + 1}",
                                      quantity: 1,
                                      width: 50.0),
                                  onSave: (PanelInfo updatedPanel) {
                                    setState(() {
                                      _panels.add(updatedPanel);
                                    });
                                    _writePanels();
                                  },
                                );
                              });
                        },
                        child: const Text('Ajouter'),
                      ),
                    ],
                  )
                ],
              ),
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
                  painter: FabricPainter(() => (_fabric.width, _showPattern, _fabric.pattern)),
                  size: Size(min(constraints.maxWidth, maxCanvasWidth),
                      200 * min(constraints.maxWidth, maxCanvasWidth) / _fabric.width),
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
