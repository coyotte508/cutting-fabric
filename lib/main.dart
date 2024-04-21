import 'dart:convert';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:file_saver/file_saver.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cutting_fabric/algorithm.dart';
import 'package:cutting_fabric/cut_dialog.dart';
import 'package:cutting_fabric/utils.dart';
// import 'package:open_file_plus/open_file_plus.dart';
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
        // Locale('fr'), // French
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

  CutPlacements? _placements;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<String> get _tmpPath async {
    final directory = await getTemporaryDirectory();

    return directory.path;
  }

  Future<File> get _fabricsFile async {
    final path = await _localPath;
    return File('$path/fabrics.json');
  }

  Future<File> get _cutsFile async {
    final path = await _localPath;
    return File('$path/cuts.json');
  }

  Future<void> _writeFabrics() async {
    final file = await _fabricsFile;
    await file.writeAsString(jsonEncode([_fabric.toJson()]));
  }

  Future<void> _writeCuts() async {
    final file = await _cutsFile;
    await file.writeAsString(jsonEncode(_cuts.map((e) => e.toJson()).toList()));
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

  Future<void> _readCuts() async {
    final file = await _cutsFile;
    if (!await file.exists()) {
      return;
    }
    final contents = await file.readAsString();
    final List<dynamic> cuts = jsonDecode(contents).map((e) => CutInfo.fromJson(e)).toList();
    setState(() {
      _cuts.clear();
      for (var cut in cuts) {
        _cuts.add(cut);
      }
    });
  }

  late final List<CutInfo> _cuts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _fabric = FabricInfo(
        width: cmToInt(140),
        pricePerMeter: euroToInt(50),
      );
      _cuts = [
        CutInfo(
            width: cmToInt(50),
            length: cmToInt(50),
            quantity: 1,
            name: AppLocalizations.of(context)!.defaultCutName(1),
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
    _readCuts();

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
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
        child: ListView(
          children: <Widget>[
            const SizedBox.square(
              dimension: 8.0,
            ),
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.fabricCardTitle),
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
                          {"title": AppLocalizations.of(context)!.fabricWidth, "value": '${intToCm(_fabric.width)} cm'},
                          {
                            "title": AppLocalizations.of(context)!.fabricPricePerMeter,
                            "value": '${intToEuro(_fabric.pricePerMeter)} €'
                          },
                          {
                            "title": AppLocalizations.of(context)!.pattern,
                            "value": _fabric.pattern != null
                                ? '${intToCm(_fabric.pattern!.width)}x${intToCm(_fabric.pattern!.length)} cm'
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
                    title: Text(AppLocalizations.of(context)!.cutCardTitle),
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
                                  child: Text(AppLocalizations.of(context)!.cutTableName)),
                            ),
                            TableCell(
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(AppLocalizations.of(context)!.cutTableMeasurements)),
                            ),
                            TableCell(
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                                  child: Text(AppLocalizations.of(context)!.cutTableQuantity)),
                            ),
                            const TableCell(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(''),
                              ),
                            ),
                          ]),
                          ..._cuts.map((cut) {
                            return TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(cut.name)),
                                ),
                                TableCell(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text("${intToCm(cut.width)}x${intToCm(cut.length)} cm")),
                                ),
                                TableCell(
                                  child: Center(
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Text(cut.quantity.toString()))),
                                ),
                                TableCell(
                                  child: Padding(
                                      // Appearance is different on android and linux, on android 0.0 padding is the best
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            tooltip: cut.canRotate
                                                ? AppLocalizations.of(context)!.tooltipAllowRotation
                                                : AppLocalizations.of(context)!.tooltipAllowRotationNo,
                                            onPressed: () {
                                              setState(() {
                                                cut.canRotate = !cut.canRotate;
                                              });
                                            },
                                            icon: Icon(cut.canRotate
                                                ? Icons.screen_rotation_outlined
                                                : Icons.screen_lock_rotation_outlined),
                                            padding: EdgeInsets.zero,
                                            visualDensity: const VisualDensity(
                                                horizontal: VisualDensity.minimumDensity,
                                                vertical: VisualDensity.minimumDensity),
                                          ),
                                          IconButton(
                                            tooltip: cut.centerOnPattern
                                                ? AppLocalizations.of(context)!.tooltipCenterOnPattern
                                                : AppLocalizations.of(context)!.tooltipCenterOnPatternNo,
                                            onPressed: _fabric.pattern != null
                                                ? () {
                                                    setState(() {
                                                      cut.centerOnPattern = !cut.centerOnPattern;
                                                    });
                                                  }
                                                : null,
                                            icon: Icon(cut.centerOnPattern
                                                ? Icons.center_focus_strong
                                                : Icons.center_focus_weak),
                                            padding: EdgeInsets.zero,
                                            visualDensity: const VisualDensity(
                                                horizontal: VisualDensity.minimumDensity,
                                                vertical: VisualDensity.minimumDensity),
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return CutDialogContent(
                                                        cut: cut.clone(),
                                                        hasPattern: _fabric.pattern != null,
                                                        onSave: (CutInfo updatedCut) {
                                                          setState(() {
                                                            _cuts[_cuts.indexOf(cut)] = updatedCut;
                                                          });
                                                          _writeCuts();
                                                        },
                                                      );
                                                    });
                                              },
                                              padding: EdgeInsets.zero,
                                              visualDensity: const VisualDensity(
                                                  horizontal: VisualDensity.minimumDensity,
                                                  vertical: VisualDensity.minimumDensity),
                                              icon: const Icon(Icons.edit)),
                                          IconButton(
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Text(AppLocalizations.of(context)!.deleteCutTitle),
                                                        content: Text(
                                                            AppLocalizations.of(context)!.deleteCutMessage(cut.name)),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  _cuts.remove(cut);
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
                                              visualDensity: const VisualDensity(
                                                  horizontal: VisualDensity.minimumDensity,
                                                  vertical: VisualDensity.minimumDensity),
                                              color: Colors.red,
                                              icon: const Icon(Icons.delete_outlined))
                                        ],
                                      )),
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
                                return CutDialogContent(
                                  cut: CutInfo(
                                      canRotate: false,
                                      centerOnPattern: false,
                                      length: cmToInt(50),
                                      name: AppLocalizations.of(context)!.defaultCutName(_cuts.length + 1),
                                      quantity: 1,
                                      width: cmToInt(50)),
                                  hasPattern: _fabric.pattern != null,
                                  onSave: (CutInfo updatedCut) {
                                    setState(() {
                                      _cuts.add(updatedCut);
                                    });
                                    _writeCuts();
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
                    ),
                    const SizedBox.square(
                      dimension: 3.0,
                    ),
                  ]
                : [const SizedBox.square(dimension: 10.0)]),
            // Button to launch the cutting algorithm
            Row(children: [
              ElevatedButton(
                onPressed: () {
                  final width = _fabric.width;

                  ReceivePort receivePort = ReceivePort();
                  receivePort.listen((message) {
                    setState(() => _placements = message);
                  });
                  Isolate.spawn<(SendPort, int, PatternInfo?, List<CutInfo>)>((message) {
                    final placements = computeBestPlacement(message.$2, message.$3, message.$4);
                    message.$1.send(placements);
                  }, (receivePort.sendPort, width, _fabric.pattern, _cuts));
                },
                child: Text(AppLocalizations.of(context)!.launchAlgorithmCTA),
              ),
              const Spacer(),
              IconButton(
                  onPressed: _placements != null
                      ? () {
                          final fileName = AppLocalizations.of(context)!
                              .saveImageName(DateFormat("yyyy-MM-dd HH'h'mm").format(DateTime.now()));

                          () async {
                            final recorder = ui.PictureRecorder();
                            final canvas = Canvas(recorder);
                            final painter =
                                FabricPainter(() => (_fabric.width, _showPattern, _fabric.pattern, _placements!));
                            final size = Size(800, 800 * _placements!.totalLength / _fabric.width);
                            painter.textScale = 2.0;

                            painter.paint(canvas, size);
                            ui.Image renderedImage =
                                await recorder.endRecording().toImage(size.width.floor(), size.height.floor());

                            final pngBytes = await renderedImage.toByteData(format: ui.ImageByteFormat.png);

                            final res = await FileSaver.instance.saveAs(
                                name: fileName,
                                bytes: pngBytes!.buffer.asUint8List(),
                                ext: "png",
                                mimeType: MimeType.png);
                            //OpenFile.open(file.path);
                            debugPrint(res);
                            // OpenFile.open(res);
                          }();
                        }
                      : null,
                  icon: const Icon(Icons.download)),
              IconButton(
                  onPressed: _placements != null
                      ? () async {
                          final recorder = ui.PictureRecorder();
                          final canvas = Canvas(recorder);
                          final painter =
                              FabricPainter(() => (_fabric.width, _showPattern, _fabric.pattern, _placements!));
                          final size = Size(800, 800 * _placements!.totalLength / _fabric.width);
                          painter.textScale = 2.0;

                          painter.paint(canvas, size);
                          ui.Image renderedImage =
                              await recorder.endRecording().toImage(size.width.floor(), size.height.floor());

                          final pngBytes = await renderedImage.toByteData(format: ui.ImageByteFormat.png);

                          final file = File("${await _tmpPath}/cutting_plan.png");

                          await file.writeAsBytes(pngBytes!.buffer.asUint8List());

                          Share.shareXFiles([XFile(file.path, mimeType: "image/png")]);
                        }
                      : null,
                  icon: const Icon(Icons.share)),
            ]),
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
                          size: Size(min(constraints.maxWidth, maxCanvasWidth),
                              _placements!.totalLength * min(constraints.maxWidth, maxCanvasWidth) / _fabric.width),
                        );
                      }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        AppLocalizations.of(context)!.cuttingPlanDetailsMessage(
                            round2(intToM(_placements!.totalLength) * intToEuro(_fabric.pricePerMeter)),
                            round2(intToM(_placements!.totalLength))),
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

double round2(double value) {
  return (value * 100).round() / 100;
}

computeBestPlacement(int width, PatternInfo? pattern, List<CutInfo> cuts) {
  final placements = CutPlacements(fabricWidth: width, pattern: pattern);
  List<CutInfo> cutArray = [];

  for (final cut in cuts) {
    for (var i = 0; i < cut.quantity; i++) {
      cutArray.add(cut.clone());
    }
  }

  for (final cut in cutArray) {
    placements.placeCutBottomLeft(cut);
  }
  var bestPlacements = placements;
  // re-clone cuts
  cutArray = cutArray.map((e) => e.clone()).toList();

  for (var i = 0; i < 10000; i++) {
    final newPlacements = CutPlacements(fabricWidth: width, pattern: pattern);
    cutArray.shuffle();

    for (final cut in cutArray) {
      if (cut.canRotate && Random().nextBool()) {
        var tmp = cut.width;
        cut.width = cut.length;
        cut.length = tmp;
      }
      newPlacements.placeCutBottomLeft(cut);
    }

    if (newPlacements.totalLength < bestPlacements.totalLength) {
      bestPlacements = newPlacements;
      cutArray = cutArray.map((e) => e.clone()).toList();
    }
  }

  return bestPlacements;
}
