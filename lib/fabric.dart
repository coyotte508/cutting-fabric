class FabricInfo {
  int width;
  String name;
  int pricePerMeter;
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
    this.width = 200,
    this.length = 200,
  });

  int width;
  int length;

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

  int width;
  int length;
  String name;
  int quantity;
  bool centerOnPattern;
  bool canRotate;

  static fromJson(Map<String, dynamic> json) {
    return PanelInfo(
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

  PanelInfo clone() {
    return PanelInfo.fromJson(toJson());
  }
}
