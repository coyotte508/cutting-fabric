import 'package:flutter/material.dart';

class FabricDialogContent extends StatefulWidget {
  final double fabricWidth;
  final double pricePerMeter;
  final String fabricName;
  final ({double patternWidth, double patternLength})? pattern;
  final void Function(
      {required double fabricWidth,
      required double pricePerMeter,
      required ({double patternWidth, double patternLength})? pattern,
      required String fabricName}) onSave;

  const FabricDialogContent({
    super.key,
    required this.fabricWidth,
    required this.pricePerMeter,
    required this.fabricName,
    required this.pattern,
    required this.onSave,
  });

  @override
  State<FabricDialogContent> createState() => _FabricDialogContentState();
}

class _FabricDialogContentState extends State<FabricDialogContent> {
  late double _fabricWidth;
  late double _pricePerMeter;
  late String _fabricName;
  late double _patternWidth;
  late double _patternLength;
  late bool _hasPattern;

  final _fabricWidthController = TextEditingController();
  final _pricePerMeterController = TextEditingController();
  final _fabricNameController = TextEditingController();
  final _patternWidthController = TextEditingController();
  final _patternLengthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fabricWidth = widget.fabricWidth;
    _pricePerMeter = widget.pricePerMeter;
    _fabricName = widget.fabricName;
    _patternWidth = widget.pattern?.patternWidth ?? 20.0;
    _patternLength = widget.pattern?.patternLength ?? 20.0;
    _hasPattern = widget.pattern != null;

    _fabricWidthController.addListener(() {
      setState(() {
        _fabricWidth = double.parse(_fabricWidthController.text);
      });
    });
    _pricePerMeterController.addListener(() {
      setState(() {
        _pricePerMeter = double.parse(_pricePerMeterController.text);
      });
    });
    _fabricNameController.addListener(() {
      setState(() {
        _fabricName = _fabricNameController.text;
      });
    });
    _patternWidthController.addListener(() {
      setState(() {
        _patternWidth = double.parse(_patternWidthController.text);
      });
    });
    _patternLengthController.addListener(() {
      setState(() {
        _patternLength = double.parse(_patternLengthController.text);
      });
    });

    _fabricWidthController.text = _fabricWidth.toString();
    _pricePerMeterController.text = _pricePerMeter.toString();
    _fabricNameController.text = _fabricName;
    _patternWidthController.text = _patternWidth.toString();
    _patternLengthController.text = _patternLength.toString();
  }

  @override
  void dispose() {
    _fabricWidthController.dispose();
    _pricePerMeterController.dispose();
    _fabricNameController.dispose();
    _patternWidthController.dispose();
    _patternLengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        actions: [
          TextButton(
              onPressed: () {
                widget.onSave(
                  fabricWidth: _fabricWidth,
                  pricePerMeter: _pricePerMeter,
                  fabricName: _fabricName,
                  pattern: _hasPattern
                      ? (
                          patternLength: _patternLength,
                          patternWidth: _patternWidth
                        )
                      : null,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'))
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _fabricNameController,
              decoration: const InputDecoration(labelText: 'Nom du tissu'),
            ),
            TextField(
              controller: _fabricWidthController,
              decoration: const InputDecoration(labelText: 'Largeur du tissu'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _pricePerMeterController,
              decoration: const InputDecoration(labelText: 'Prix au mètre'),
              keyboardType: TextInputType.number,
            ),
            CheckboxListTile(
              value: _hasPattern,
              onChanged: (value) {
                setState(() {
                  _hasPattern = value!;
                });
              },
              title: const Text("Avec motif"),
            ),
            ..._hasPattern
                ? [
                    TextField(
                      controller: _patternWidthController,
                      decoration:
                          const InputDecoration(labelText: 'Largeur du motif'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _patternLengthController,
                      decoration:
                          const InputDecoration(labelText: 'Longueur du motif'),
                      keyboardType: TextInputType.number,
                    ),
                  ]
                : [],
          ],
        ));
  }
}
