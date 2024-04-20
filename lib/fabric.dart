import 'package:cutting_fabric/utils.dart';

class FabricInfo {
  int width;
  int pricePerMeter;
  PatternInfo? pattern;

  FabricInfo({
    required this.width,
    required this.pricePerMeter,
    this.pattern,
  });

  static fromJson(Map<String, dynamic> json) {
    return FabricInfo(
      width: json["width"],
      pricePerMeter: json["price"],
      pattern: json["pattern"] != null ? PatternInfo.fromJson(json["pattern"]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "width": width,
      "price": pricePerMeter,
      "pattern": pattern?.toJson(),
    };
  }

  FabricInfo clone() {
    return FabricInfo.fromJson(toJson());
  }
}

class PatternInfo {
  PatternInfo({
    int? width,
    int? length,
  }) {
    if (width != null) {
      this.width = width;
    }
    if (length != null) {
      this.length = length;
    }
  }

  int width = cmToInt(20);
  int length = cmToInt(20);

  static fromJson(Map<String, dynamic> json) {
    return PatternInfo(
      width: json["width"],
      length: json["length"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "width": width,
      "length": length,
    };
  }
}

class CutInfo {
  CutInfo({
    required this.width,
    required this.length,
    required this.name,
    required this.quantity,
    required this.centerOnPattern,
    required this.canRotate,
  });

  int width;
  int length;
  String name;
  int quantity;
  bool centerOnPattern;
  bool canRotate;

  static fromJson(Map<String, dynamic> json) {
    return CutInfo(
      width: json["width"],
      length: json["length"],
      name: json["name"],
      quantity: json["quantity"],
      centerOnPattern: json["centerOnPattern"],
      canRotate: json["canRotate"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "width": width,
      "length": length,
      "name": name,
      "quantity": quantity,
      "centerOnPattern": centerOnPattern,
      "canRotate": canRotate,
    };
  }

  CutInfo clone() {
    return CutInfo.fromJson(toJson());
  }
}
