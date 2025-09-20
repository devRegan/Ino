// widgets/project_card.dart
import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getArduinoIcon(project.arduinoType),
                    size: 24,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          project.arduinoType,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'duplicate':
                          onDuplicate();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 16),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.cable,
                    label: project.communicationType,
                    context: context,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.code,
                    label: 'v${project.firmwareVersion}',
                    context: context,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.widgets,
                    label: '${project.uiConfig.controls.length} controls',
                    context: context,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Updated ${_formatDate(project.updatedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getArduinoIcon(String type) {
    switch (type.toLowerCase()) {
      case 'esp32':
      case 'esp8266':
        return Icons.wifi;
      default:
        return Icons.memory;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

// widgets/dynamic_ui_widget.dart

class DynamicUIWidget extends StatefulWidget {
  final ProjectUIConfig uiConfig;
  final Function(String) onCommandSent;
  final bool isEnabled;

  const DynamicUIWidget({
    super.key,
    required this.uiConfig,
    required this.onCommandSent,
    this.isEnabled = true,
  });

  @override
  State<DynamicUIWidget> createState() => _DynamicUIWidgetState();
}

class _DynamicUIWidgetState extends State<DynamicUIWidget> {
  final Map<String, dynamic> _controlStates = {};

  @override
  Widget build(BuildContext context) {
    if (widget.uiConfig.controls.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.widgets, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No controls configured',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: widget.uiConfig.controls.map((control) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildControl(control),
        );
      }).toList(),
    );
  }

  Widget _buildControl(UIControl control) {
    switch (control.type) {
      case 'button':
        return _buildButton(control);
      case 'slider':
        return _buildSlider(control);
      case 'switch':
        return _buildSwitch(control);
      default:
        return _buildUnsupportedControl(control);
    }
  }

  Widget _buildButton(UIControl control) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: widget.isEnabled
            ? () {
                if (control.command != null) {
                  widget.onCommandSent(control.command!);
                }
              }
            : null,
        icon: const Icon(Icons.play_arrow),
        label: Text(control.label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSlider(UIControl control) {
    final key = '${control.type}_${control.label}';
    final double currentValue = _controlStates[key]?.toDouble() ??
        control.defaultValue ??
        control.minValue ??
        0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              control.label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                currentValue.toInt().toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: currentValue,
          min: control.minValue ?? 0.0,
          max: control.maxValue ?? 100.0,
          divisions:
              ((control.maxValue ?? 100.0) - (control.minValue ?? 0.0)).toInt(),
          onChanged: widget.isEnabled
              ? (value) {
                  setState(() {
                    _controlStates[key] = value;
                  });
                }
              : null,
          onChangeEnd: widget.isEnabled
              ? (value) {
                  if (control.commandPrefix != null) {
                    widget.onCommandSent(
                        '${control.commandPrefix}${value.toInt()}');
                  }
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildSwitch(UIControl control) {
    final key = '${control.type}_${control.label}';
    final bool currentValue = _controlStates[key] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                control.label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                currentValue ? 'ON' : 'OFF',
                style: TextStyle(
                  color: currentValue ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Switch(
            value: currentValue,
            onChanged: widget.isEnabled
                ? (value) {
                    setState(() {
                      _controlStates[key] = value;
                    });

                    if (value && control.commandOn != null) {
                      widget.onCommandSent(control.commandOn!);
                    } else if (!value && control.commandOff != null) {
                      widget.onCommandSent(control.commandOff!);
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedControl(UIControl control) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unsupported Control',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
                Text(
                  'Type: ${control.type} - ${control.label}',
                  style: TextStyle(color: Colors.orange[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
