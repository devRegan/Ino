import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../providers/project_provider.dart';
import '../models/project.dart';

class AddProjectScreen extends StatefulWidget {
  final Project? project;

  const AddProjectScreen({super.key, this.project});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _firmwareVersionController = TextEditingController();

  String _selectedArduinoType = 'Arduino Uno';
  String _selectedCommunicationType = 'USB';
  String _uiConfigJson = '';

  final List<String> _arduinoTypes = [
    'Arduino Uno',
    'Arduino Nano',
    'Arduino Mega',
    'Arduino Leonardo',
    'ESP32',
    'ESP8266',
    'Arduino Pro Mini',
  ];

  final List<String> _communicationTypes = [
    'USB',
    'Bluetooth',
    'Wi-Fi',
  ];

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.project!.name;
      _firmwareVersionController.text = widget.project!.firmwareVersion;
      _selectedArduinoType = widget.project!.arduinoType;
      _selectedCommunicationType = widget.project!.communicationType;
      _uiConfigJson = widget.project!.uiConfigJson;
    } else {
      _firmwareVersionController.text = '1.0.0';
      _uiConfigJson = _getDefaultUIConfig();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _firmwareVersionController.dispose();
    super.dispose();
  }

  String _getDefaultUIConfig() {
    return jsonEncode({
      'controls': [
        {'type': 'button', 'label': 'LED On', 'command': 'LED_ON'},
        {'type': 'button', 'label': 'LED Off', 'command': 'LED_OFF'}
      ]
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Project' : 'Add New Project'),
        actions: [
          TextButton(
            onPressed: _saveProject,
            child: Text(
              'Save',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Project Name
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Project Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a project name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedArduinoType,
                      decoration: const InputDecoration(
                        labelText: 'Arduino Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.memory),
                      ),
                      items: _arduinoTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedArduinoType = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCommunicationType,
                      decoration: const InputDecoration(
                        labelText: 'Communication Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cable),
                      ),
                      items: _communicationTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCommunicationType = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _firmwareVersionController,
                      decoration: const InputDecoration(
                        labelText: 'Firmware Version',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.code),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a firmware version';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // UI Configuration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UI Configuration',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _loadUIFromFile,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Load UI JSON'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _useDefaultUI,
                            icon: const Icon(Icons.auto_fix_high),
                            label: const Text('Use Default'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _formatJson(_uiConfigJson),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'UI Controls Preview:',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildUIPreview(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProject,
                    child:
                        Text(_isEditing ? 'Update Project' : 'Create Project'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUIPreview() {
    try {
      final config = ProjectUIConfig.fromJson(_uiConfigJson);
      if (config.controls.isEmpty) {
        return const Text('No controls configured');
      }

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: config.controls.map((control) {
          return Chip(
            avatar: _getControlIcon(control.type),
            label: Text(control.label),
          );
        }).toList(),
      );
    } catch (e) {
      return Text(
        'Invalid JSON configuration',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }
  }

  Icon _getControlIcon(String type) {
    switch (type) {
      case 'button':
        return const Icon(Icons.smart_button, size: 16);
      case 'slider':
        return const Icon(Icons.linear_scale, size: 16);
      case 'switch':
        return const Icon(Icons.toggle_on, size: 16);
      default:
        return const Icon(Icons.widgets, size: 16);
    }
  }

  String _formatJson(String jsonString) {
    try {
      final dynamic parsedJson = jsonDecode(jsonString);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(parsedJson);
    } catch (e) {
      return jsonString;
    }
  }

  Future<void> _loadUIFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && mounted) {
        String content = String.fromCharCodes(result.files.single.bytes!);

        // Validate JSON
        jsonDecode(content);

        setState(() {
          _uiConfigJson = content;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('UI configuration loaded successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading file: $e')),
        );
      }
    }
  }

  void _useDefaultUI() {
    setState(() {
      _uiConfigJson = _getDefaultUIConfig();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Default UI configuration loaded')),
    );
  }

  void _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate JSON
    try {
      jsonDecode(_uiConfigJson);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid UI configuration JSON')),
        );
      }
      return;
    }

    final project = Project(
      id: _isEditing ? widget.project!.id : null,
      name: _nameController.text.trim(),
      arduinoType: _selectedArduinoType,
      communicationType: _selectedCommunicationType,
      uiConfigJson: _uiConfigJson,
      firmwareVersion: _firmwareVersionController.text.trim(),
    );

    try {
      final provider = context.read<ProjectProvider>();

      if (_isEditing) {
        await provider.updateProject(project);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project updated successfully')),
          );
        }
      } else {
        await provider.addProject(project);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project created successfully')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving project: $e')),
        );
      }
    }
  }
}
