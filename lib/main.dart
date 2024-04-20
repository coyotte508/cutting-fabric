import 'dart:convert';
import 'dart:isolate';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:upholstery_cutting_tool/algorithm.dart';
import 'package:upholstery_cutting_tool/panel_dialog.dart';
import 'dart:math';
import 'fabric_dialog.dart';
import 'fabric_painter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import "fabric.dart";

void main() async {
  runApp(const MyApp());
}

const maxCanvasWidth = 700.0;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('fr'), // French
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FabricInfo _fabric;
  bool _initialized = false;

  bool _showPattern = true;

  late SharedPreferences prefs;

  PanelPlacements? _placements;

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

  late final List<PanelInfo> _panels;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _fabric = FabricInfo(
        width: 1400,
        name: AppLocalizations.of(context)!.defaultFabricName,
        pricePerMeter: 5000,
      );
      _panels = [
        PanelInfo(
            width: 500,
            length: 500,
            quantity: 1,
            name: AppLocalizations.of(context)!.defaultPanelName(1),
            centerOnPattern: false,
            canRotate: false)
      ];
      _initialized = true;
    }
  }

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
        title: Text(AppLocalizations.of(context)!.appBarTitle),
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
                    title: Text(AppLocalizations.of(context)!.fabricCardTitle(_fabric.name)),
                    subtitle: Text(AppLocalizations.of(context)!.fabricCardSubtitle),
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
                          {"title": AppLocalizations.of(context)!.fabricWidth, "value": '${_fabric.width / 10.0} cm'},
                          {
                            "title": AppLocalizations.of(context)!.fabricPricePerMeter,
                            "value": '${_fabric.pricePerMeter / 100.0} €'
                          },
                          {
                            "title": AppLocalizations.of(context)!.pattern,
                            "value": _fabric.pattern != null
                                ? '${_fabric.pattern!.width / 10.0}x${_fabric.pattern!.length / 10.0} cm'
                                : AppLocalizations.of(context)!.noPattern
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
                        child: Text(AppLocalizations.of(context)!.editCTA),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox.square(
              dimension: 10.0,
            ),
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.panelCardTitle),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0.0),
                    child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1.0),
                          1: FlexColumnWidth(1.0),
                          2: IntrinsicColumnWidth(),
                          3: IntrinsicColumnWidth(),
                        },
                        border: const TableBorder(
                            horizontalInside: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        )),
                        children: [
                          TableRow(children: [
                            TableCell(
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(AppLocalizations.of(context)!.panelTableName)),
                            ),
                            TableCell(
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(AppLocalizations.of(context)!.panelTableMeasurements)),
                            ),
                            TableCell(
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(AppLocalizations.of(context)!.panelTableQuantity)),
                            ),
                            const TableCell(
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
                                      child: Text("${panel.width / 10.0}x${panel.length / 10.0} cm")),
                                ),
                                TableCell(
                                  child: Center(
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Text(panel.quantity.toString()))),
                                ),
                                TableCell(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                          tooltip: panel.canRotate
                                              ? AppLocalizations.of(context)!.tooltipAllowRotation
                                              : AppLocalizations.of(context)!.tooltipAllowRotationNo,
                                          onPressed: () {
                                            setState(() {
                                              panel.canRotate = !panel.canRotate;
                                            });
                                          },
                                          icon: Icon(panel.canRotate
                                              ? Icons.screen_rotation_outlined
                                              : Icons.screen_lock_rotation_outlined)),
                                      IconButton(
                                          tooltip: panel.centerOnPattern
                                              ? AppLocalizations.of(context)!.tooltipCenterOnPattern
                                              : AppLocalizations.of(context)!.tooltipCenterOnPatternNo,
                                          onPressed: _fabric.pattern != null
                                              ? () {
                                                  setState(() {
                                                    panel.centerOnPattern = !panel.centerOnPattern;
                                                  });
                                                }
                                              : null,
                                          icon: Icon(panel.centerOnPattern
                                              ? Icons.center_focus_strong
                                              : Icons.center_focus_weak)),
                                      IconButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return PanelDialogContent(
                                                    panel: panel.clone(),
                                                    hasPattern: _fabric.pattern != null,
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
                                                    title: Text(AppLocalizations.of(context)!.deletePanelTitle),
                                                    content: Text(
                                                        AppLocalizations.of(context)!.deletePanelMessage(panel.name)),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              _panels.remove(panel);
                                                            });
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: Text(AppLocalizations.of(context)!.yesCTA)),
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: Text(AppLocalizations.of(context)!.noCTA)),
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
                                      length: 500,
                                      name: AppLocalizations.of(context)!.defaultPanelName(_panels.length + 1),
                                      quantity: 1,
                                      width: 500),
                                  hasPattern: _fabric.pattern != null,
                                  onSave: (PanelInfo updatedPanel) {
                                    setState(() {
                                      _panels.add(updatedPanel);
                                    });
                                    _writePanels();
                                  },
                                );
                              });
                        },
                        child: Text(AppLocalizations.of(context)!.addCTA),
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
                      title: Text(AppLocalizations.of(context)!.showPattern),
                    )
                  ]
                : []),
            // Button to launch the cutting algorithm
            ElevatedButton(
              onPressed: () {
                final width = _fabric.width;

                ReceivePort receivePort = ReceivePort();
                receivePort.listen((message) {
                  setState(() => _placements = message);
                });
                Isolate.spawn<(SendPort, int, PatternInfo?, List<PanelInfo>)>((message) {
                  final placements = computeBestPlacement(message.$2, message.$3, message.$4);
                  message.$1.send(placements);
                }, (receivePort.sendPort, width, _fabric.pattern, _panels));
              },
              child: Text(AppLocalizations.of(context)!.launchAlgorithmCTA),
            ),
            const SizedBox.square(
              dimension: 10.0,
            ),
            ...(_placements != null
                ? [
                    Container(
                      alignment: Alignment.center,
                      child: LayoutBuilder(builder: (context, constraints) {
                        return CustomPaint(
                          painter: FabricPainter(() => (_fabric.width, _showPattern, _fabric.pattern, _placements!)),
                          // 2m length
                          size: Size(min(constraints.maxWidth, maxCanvasWidth),
                              _placements!.totalLength * min(constraints.maxWidth, maxCanvasWidth) / _fabric.width),
                        );
                      }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        AppLocalizations.of(context)!.cuttingPlanDetailsMessage(
                            _placements!.totalLength / 1000 * _fabric.pricePerMeter / 100,
                            _placements!.totalLength / 1000),
                        style: const TextStyle(fontSize: 20.0),
                      ),
                    )
                  ]
                : []),
          ],
        ),
      ),
    );
  }
}

computeBestPlacement(int width, PatternInfo? pattern, List<PanelInfo> panels) {
  final placements = PanelPlacements(fabricWidth: width, pattern: pattern);
  List<PanelInfo> panelArray = [];

  for (final panel in panels) {
    for (var i = 0; i < panel.quantity; i++) {
      panelArray.add(panel.clone());
    }
  }

  for (final panel in panelArray) {
    placements.placePanelBottomLeft(panel);
  }
  var bestPlacements = placements;
  // re-clone panels
  panelArray = panelArray.map((e) => e.clone()).toList();

  for (var i = 0; i < 10000; i++) {
    final newPlacements = PanelPlacements(fabricWidth: width, pattern: pattern);
    panelArray.shuffle();

    for (final panel in panelArray) {
      if (panel.canRotate && Random().nextBool()) {
        var tmp = panel.width;
        panel.width = panel.length;
        panel.length = tmp;
      }
      newPlacements.placePanelBottomLeft(panel);
    }

    if (newPlacements.totalLength < bestPlacements.totalLength) {
      bestPlacements = newPlacements;
      panelArray = panelArray.map((e) => e.clone()).toList();
    }
  }

  return bestPlacements;
}
