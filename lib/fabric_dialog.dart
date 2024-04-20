import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cutting_fabric/utils.dart';
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
  final _patternWidthController = TextEditingController();
  final _patternLengthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fabric = widget.fabric;

    _fabricWidthController.addListener(() {
      setState(() {
        _fabric.width = cmToInt(max(10.0, double.parse(_fabricWidthController.text)));
      });
    });
    _pricePerMeterController.addListener(() {
      setState(() {
        _fabric.pricePerMeter = euroToInt(double.parse(_pricePerMeterController.text));
      });
    });
    _patternWidthController.addListener(() {
      setState(() {
        _fabric.pattern?.width = cmToInt(double.parse(_patternWidthController.text));
      });
    });
    _patternLengthController.addListener(() {
      setState(() {
        _fabric.pattern?.length = cmToInt(double.parse(_patternLengthController.text));
      });
    });

    _fabricWidthController.text = (intToCm(_fabric.width)).toString();
    _pricePerMeterController.text = (intToEuro(_fabric.pricePerMeter)).toString();
    _patternWidthController.text = (intToCm((_fabric.pattern ?? PatternInfo()).width)).toString();
    _patternLengthController.text = (intToCm((_fabric.pattern ?? PatternInfo()).length)).toString();
  }

  @override
  void dispose() {
    _fabricWidthController.dispose();
    _pricePerMeterController.dispose();
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
