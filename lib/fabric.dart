class FabricInfo {
  double width;
  String name;
  double pricePerMeter;
  PatternInfo? pattern;

  FabricInfo({
    required this.width,
    required this.name,
    required this.pricePerMeter,
    this.pattern,
  });

  static fromJson(Map<String, dynamic> json) {
    return FabricInfo(
      width: json["width"],
      name: json["name"],
      pricePerMeter: json["price"],
      pattern: json["pattern"] != null ? PatternInfo.fromJson(json["pattern"]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "width": width,
      "name": name,
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
    this.width = 20.0,
    this.length = 20.0,
  });

  double width;
  double length;

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

class PanelInfo {
  PanelInfo({
    required this.width,
    required this.length,
    required this.name,
    required this.quantity,
    required this.centerOnPattern,
    required this.canRotate,
  });

  double width;
  double length;
  String name;
  int quantity;
  bool centerOnPattern;
  bool canRotate;
}
