import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _fabricWidth = 140;
  final _fabricWidthController = TextEditingController();
  double _pricePerMeter = 10;
  final _pricePerMeterController = TextEditingController();

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
    _fabricWidthController.addListener(() {
      setState(() {
        _fabricWidth = int.parse(_fabricWidthController.text);
      });
    });
    _pricePerMeterController.addListener(() {
      setState(() {
        _pricePerMeter = double.parse(_pricePerMeterController.text);
      });
    });
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
    _fabricWidthController.text = '$_fabricWidth';
    _pricePerMeterController.text = '$_pricePerMeter';
    _panelWidthController.text = '${panel["width"]}';
    _panelLengthController.text = '${panel["length"]}';
    _panelQuantityController.text = '${panel["quantity"]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: Column(
          children: <Widget>[
            TextField(
              keyboardType: const TextInputType.numberWithOptions(),
              decoration: const InputDecoration(
                label: Text('Largeur de tissu en cm'),
              ),
              onChanged: (value) => setState(() {
                _fabricWidth = int.parse(value);
              }),
              controller: _fabricWidthController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            TextField(
              keyboardType: const TextInputType.numberWithOptions(),
              decoration: const InputDecoration(
                label: Text('Prix au mètre en €'),
              ),
              onChanged: (value) => setState(() {
                _pricePerMeter = double.parse(value);
              }),
              controller: _pricePerMeterController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
            )
          ],
        ),
      ),
    );
  }
}
