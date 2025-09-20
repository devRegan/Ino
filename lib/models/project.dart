import 'dart:convert';

class Project {
  final int? id;
  final String name;
  final String arduinoType;
  final String communicationType;
  final String uiConfigJson;
  final String firmwareVersion;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    this.id,
    required this.name,
    required this.arduinoType,
    required this.communicationType,
    required this.uiConfigJson,
    this.firmwareVersion = '1.0.0',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'arduino_type': arduinoType,
      'communication_type': communicationType,
      'ui_config_json': uiConfigJson,
      'firmware_version': firmwareVersion,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from Map (database)
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'] ?? '',
      arduinoType: map['arduino_type'] ?? '',
      communicationType: map['communication_type'] ?? '',
      uiConfigJson: map['ui_config_json'] ?? '',
      firmwareVersion: map['firmware_version'] ?? '1.0.0',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  // Get UI Configuration as object
  ProjectUIConfig get uiConfig => ProjectUIConfig.fromJson(uiConfigJson);

  // Copy with modifications
  Project copyWith({
    String? name,
    String? arduinoType,
    String? communicationType,
    String? uiConfigJson,
    String? firmwareVersion,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      arduinoType: arduinoType ?? this.arduinoType,
      communicationType: communicationType ?? this.communicationType,
      uiConfigJson: uiConfigJson ?? this.uiConfigJson,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class ProjectUIConfig {
  final List<UIControl> controls;

  ProjectUIConfig({required this.controls});

  factory ProjectUIConfig.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return ProjectUIConfig(
        controls:
            (json['controls'] as List?)
                ?.map((control) => UIControl.fromMap(control))
                .toList() ??
            [],
      );
    } catch (e) {
      return ProjectUIConfig(controls: []);
    }
  }

  String toJson() {
    return jsonEncode({
      'controls': controls.map((control) => control.toMap()).toList(),
    });
  }
}

class UIControl {
  final String type;
  final String label;
  final String? command;
  final String? commandPrefix;
  final String? commandOn;
  final String? commandOff;
  final double? minValue;
  final double? maxValue;
  final double? defaultValue;

  UIControl({
    required this.type,
    required this.label,
    this.command,
    this.commandPrefix,
    this.commandOn,
    this.commandOff,
    this.minValue,
    this.maxValue,
    this.defaultValue,
  });

  factory UIControl.fromMap(Map<String, dynamic> map) {
    return UIControl(
      type: map['type'] ?? '',
      label: map['label'] ?? '',
      command: map['command'],
      commandPrefix: map['command_prefix'],
      commandOn: map['command_on'],
      commandOff: map['command_off'],
      minValue: map['min_value']?.toDouble(),
      maxValue: map['max_value']?.toDouble(),
      defaultValue: map['default_value']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'label': label,
      if (command != null) 'command': command,
      if (commandPrefix != null) 'command_prefix': commandPrefix,
      if (commandOn != null) 'command_on': commandOn,
      if (commandOff != null) 'command_off': commandOff,
      if (minValue != null) 'min_value': minValue,
      if (maxValue != null) 'max_value': maxValue,
      if (defaultValue != null) 'default_value': defaultValue,
    };
  }
}
