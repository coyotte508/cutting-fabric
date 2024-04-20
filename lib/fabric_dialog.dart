import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
        _fabric.width = max(100, (double.parse(_fabricWidthController.text) * 10).round());
      });
    });
    _pricePerMeterController.addListener(() {
      setState(() {
        _fabric.pricePerMeter = (double.parse(_pricePerMeterController.text) * 100).round();
      });
    });
    _fabricNameController.addListener(() {
      setState(() {
        _fabric.name = _fabricNameController.text;
      });
    });
    _patternWidthController.addListener(() {
      setState(() {
        _fabric.pattern?.width = (double.parse(_patternWidthController.text) * 10).round();
      });
    });
    _patternLengthController.addListener(() {
      setState(() {
        _fabric.pattern?.length = (double.parse(_patternLengthController.text) * 10).round();
      });
    });

    _fabricWidthController.text = (_fabric.width / 10.0).toString();
    _pricePerMeterController.text = (_fabric.pricePerMeter / 100.0).toString();
    _fabricNameController.text = _fabric.name;
    _patternWidthController.text = ((_fabric.pattern ?? PatternInfo()).width / 10.0).toString();
    _patternLengthController.text = ((_fabric.pattern ?? PatternInfo()).length / 10.0).toString();
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
              child: Text(AppLocalizations.of(context)!.saveCTA))
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _fabricNameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fabricName),
            ),
            TextField(
              controller: _fabricWidthController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fabricWidth),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _pricePerMeterController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fabricPricePerMeter),
              keyboardType: TextInputType.number,
            ),
            CheckboxListTile(
              value: _fabric.pattern != null,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _fabric.pattern = PatternInfo(
                      width: (double.parse(_patternWidthController.text) * 10).round(),
                      length: (double.parse(_patternLengthController.text) * 10).round(),
                    );
                  } else {
                    _fabric.pattern = null;
                  }
                });
              },
              title: Text(AppLocalizations.of(context)!.withPattern),
            ),
            ..._fabric.pattern != null
                ? [
                    TextField(
                      controller: _patternWidthController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.patternWidth),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _patternLengthController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.patternLength),
                      keyboardType: TextInputType.number,
                    ),
                  ]
                : [],
          ],
        ));
  }
}
