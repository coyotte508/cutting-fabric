import 'package:flutter/material.dart';
import 'dart:math';
import 'fabric.dart';

class FabricDialogContent extends StatefulWidget {
  final FabricInfo fabric;

  final void Function(FabricInfo fabric) onSave;

  const FabricDialogContent({
    super.key,
    required this.fabric,
    required this.onSave,
  });

  @override
  State<FabricDialogContent> createState() => _FabricDialogContentState();
}

class _FabricDialogContentState extends State<FabricDialogContent> {
  late FabricInfo _fabric;

  final _fabricWidthController = TextEditingController();
  final _pricePerMeterController = TextEditingController();
  final _fabricNameController = TextEditingController();
  final _patternWidthController = TextEditingController();
  final _patternLengthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fabric = widget.fabric;

    _fabricWidthController.addListener(() {
      setState(() {
        _fabric.width = max(10, double.parse(_fabricWidthController.text));
      });
    });
    _pricePerMeterController.addListener(() {
      setState(() {
        _fabric.pricePerMeter = double.parse(_pricePerMeterController.text);
      });
    });
    _fabricNameController.addListener(() {
      setState(() {
        _fabric.name = _fabricNameController.text;
      });
    });
    _patternWidthController.addListener(() {
      setState(() {
        _fabric.pattern?.width = double.parse(_patternWidthController.text);
      });
    });
    _patternLengthController.addListener(() {
      setState(() {
        _fabric.pattern?.length = double.parse(_patternLengthController.text);
      });
    });

    _fabricWidthController.text = _fabric.width.toString();
    _pricePerMeterController.text = _fabric.pricePerMeter.toString();
    _fabricNameController.text = _fabric.name;
    _patternWidthController.text = (_fabric.pattern ?? PatternInfo()).width.toString();
    _patternLengthController.text = (_fabric.pattern ?? PatternInfo()).length.toString();
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
                widget.onSave(_fabric);
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
              value: _fabric.pattern != null,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _fabric.pattern = PatternInfo(
                      width: double.parse(_patternWidthController.text),
                      length: double.parse(_patternLengthController.text),
                    );
                  } else {
                    _fabric.pattern = null;
                  }
                });
              },
              title: const Text("Avec motif"),
            ),
            ..._fabric.pattern != null
                ? [
                    TextField(
                      controller: _patternWidthController,
                      decoration: const InputDecoration(labelText: 'Largeur du motif'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _patternLengthController,
                      decoration: const InputDecoration(labelText: 'Longueur du motif'),
                      keyboardType: TextInputType.number,
                    ),
                  ]
                : [],
          ],
        ));
  }
}
