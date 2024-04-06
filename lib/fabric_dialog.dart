import 'package:flutter/material.dart';

class FabricDialogContent extends StatefulWidget {
  final double fabricWidth;
  final double pricePerMeter;
  final String fabricName;
  final void Function(
      {required double fabricWidth,
      required double pricePerMeter,
      required String fabricName}) onSave;

  const FabricDialogContent({
    super.key,
    required this.fabricWidth,
    required this.pricePerMeter,
    required this.fabricName,
    required this.onSave,
  });

  @override
  State<FabricDialogContent> createState() => _FabricDialogContentState();
}

class _FabricDialogContentState extends State<FabricDialogContent> {
  late double _fabricWidth;
  late double _pricePerMeter;
  late String _fabricName;

  final _fabricWidthController = TextEditingController();
  final _pricePerMeterController = TextEditingController();
  final _fabricNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fabricWidth = widget.fabricWidth;
    _pricePerMeter = widget.pricePerMeter;
    _fabricName = widget.fabricName;

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

    _fabricWidthController.text = _fabricWidth.toString();
    _pricePerMeterController.text = _pricePerMeter.toString();
    _fabricNameController.text = _fabricName;
  }

  @override
  void dispose() {
    _fabricWidthController.dispose();
    _pricePerMeterController.dispose();
    _fabricNameController.dispose();
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
              decoration: const InputDecoration(labelText: 'Fabric Name'),
            ),
            TextField(
              controller: _fabricWidthController,
              decoration: const InputDecoration(labelText: 'Fabric Width'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _pricePerMeterController,
              decoration: const InputDecoration(labelText: 'Price Per Meter'),
              keyboardType: TextInputType.number,
            ),
          ],
        ));
  }
}
