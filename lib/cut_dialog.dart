import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cutting_fabric/utils.dart';
import 'fabric.dart';

class CutDialogContent extends StatefulWidget {
  final CutInfo cut;
  final void Function(CutInfo cut) onSave;
  final bool hasPattern;

  const CutDialogContent({
    super.key,
    required this.cut,
    required this.onSave,
    required this.hasPattern,
  });

  @override
  State<CutDialogContent> createState() => _CutDialogContentState();
}

class _CutDialogContentState extends State<CutDialogContent> {
  late CutInfo _cut;

  final _cutNameController = TextEditingController();
  final _cutWidthController = TextEditingController();
  final _cutLengthController = TextEditingController();
  final _cutQuantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cut = widget.cut;

    _cutNameController.addListener(() {
      setState(() {
        _cut.name = _cutNameController.text;
      });
    });
    _cutWidthController.addListener(() {
      setState(() {
        _cut.width = cmToInt(double.parse(_cutWidthController.text));
      });
    });
    _cutLengthController.addListener(() {
      setState(() {
        _cut.length = cmToInt(double.parse(_cutLengthController.text));
      });
    });
    _cutQuantityController.addListener(() {
      setState(() {
        _cut.quantity = int.parse(_cutQuantityController.text);
      });
    });

    _cutNameController.text = _cut.name;
    _cutWidthController.text = intToCm(_cut.width).toString();
    _cutLengthController.text = intToCm((_cut.length)).toString();
    _cutQuantityController.text = _cut.quantity.toString();
  }

  @override
  void dispose() {
    _cutNameController.dispose();
    _cutWidthController.dispose();
    _cutLengthController.dispose();
    _cutQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        actions: [
          TextButton(
              onPressed: () {
                widget.onSave(_cut);
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.saveCTA))
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _cutNameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.cutName),
            ),
            TextField(
              controller: _cutWidthController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.cutWidth),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _cutLengthController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.cutLength),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _cutQuantityController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.cutQuantity),
              keyboardType: TextInputType.number,
            ),
            ...(widget.hasPattern
                ? [
                    CheckboxListTile(
                      value: _cut.centerOnPattern,
                      onChanged: (value) {
                        setState(() {
                          _cut.centerOnPattern = value == true;
                        });
                      },
                      title: Text(AppLocalizations.of(context)!.cutCenterOnPattern),
                    )
                  ]
                : []),
            CheckboxListTile(
              value: _cut.canRotate,
              onChanged: (value) {
                setState(() {
                  _cut.canRotate = value == true;
                });
              },
              title: Text(AppLocalizations.of(context)!.cutAllowRotation),
            ),
          ],
        ));
  }
}
