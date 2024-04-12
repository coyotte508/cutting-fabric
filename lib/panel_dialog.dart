import 'package:flutter/material.dart';
import 'fabric.dart';

class PanelDialogContent extends StatefulWidget {
  final PanelInfo panel;
  final void Function(PanelInfo panel) onSave;
  final bool hasPattern;

  const PanelDialogContent({
    super.key,
    required this.panel,
    required this.onSave,
    required this.hasPattern,
  });

  @override
  State<PanelDialogContent> createState() => _PanelDialogContentState();
}

class _PanelDialogContentState extends State<PanelDialogContent> {
  late PanelInfo _panel;

  final _panelNameController = TextEditingController();
  final _panelWidthController = TextEditingController();
  final _panelLengthController = TextEditingController();
  final _panelQuantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _panel = widget.panel;

    _panelNameController.addListener(() {
      setState(() {
        _panel.name = _panelNameController.text;
      });
    });
    _panelWidthController.addListener(() {
      setState(() {
        _panel.width = double.parse(_panelWidthController.text);
      });
    });
    _panelLengthController.addListener(() {
      setState(() {
        _panel.length = double.parse(_panelLengthController.text);
      });
    });
    _panelQuantityController.addListener(() {
      setState(() {
        _panel.quantity = int.parse(_panelQuantityController.text);
      });
    });

    _panelNameController.text = _panel.name;
    _panelWidthController.text = _panel.width.toString();
    _panelLengthController.text = _panel.length.toString();
    _panelQuantityController.text = _panel.quantity.toString();
  }

  @override
  void dispose() {
    _panelNameController.dispose();
    _panelWidthController.dispose();
    _panelLengthController.dispose();
    _panelQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        actions: [
          TextButton(
              onPressed: () {
                widget.onSave(_panel);
                Navigator.of(context).pop();
              },
              child: const Text('Save'))
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _panelNameController,
              decoration: const InputDecoration(labelText: 'Nom de la découpe'),
            ),
            TextField(
              controller: _panelWidthController,
              decoration: const InputDecoration(labelText: 'Largeur de la découpe'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _panelLengthController,
              decoration: const InputDecoration(labelText: 'Longueur de la découpe'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _panelQuantityController,
              decoration: const InputDecoration(labelText: 'Nombre de découpes'),
              keyboardType: TextInputType.number,
            ),
            ...(widget.hasPattern
                ? [
                    CheckboxListTile(
                      value: _panel.centerOnPattern,
                      onChanged: (value) {
                        setState(() {
                          _panel.centerOnPattern = value == true;
                        });
                      },
                      title: const Text("Centrer sur le motif"),
                    )
                  ]
                : []),
            CheckboxListTile(
              value: _panel.canRotate,
              onChanged: (value) {
                setState(() {
                  _panel.canRotate = value == true;
                });
              },
              title: const Text("Rotation autorisée"),
            ),
          ],
        ));
  }
}
