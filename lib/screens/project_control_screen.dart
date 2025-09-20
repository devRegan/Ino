import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/arduino_communication_service.dart';
import '../widgets/dynamic_ui_widget.dart';

class ProjectControlScreen extends StatefulWidget {
  final Project project;

  const ProjectControlScreen({super.key, required this.project});

  @override
  State<ProjectControlScreen> createState() => _ProjectControlScreenState();
}

class _ProjectControlScreenState extends State<ProjectControlScreen> {
  late ArduinoCommunicationService _communicationService;
  bool _isConnected = false;
  bool _isConnecting = false;
  String _connectionStatus = 'Disconnected';
  List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _communicationService = ArduinoCommunicationService();
    _communicationService.onStatusChange = _onConnectionStatusChanged;
    _communicationService.onDataReceived = _onDataReceived;
  }

  @override
  void dispose() {
    _communicationService.disconnect();
    super.dispose();
  }

  void _onConnectionStatusChanged(bool connected, String status) {
    setState(() {
      _isConnected = connected;
      _isConnecting = false;
      _connectionStatus = status;
    });
    _addLog('Status: $status');
  }

  void _onDataReceived(String data) {
    _addLog('Received: $data');
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(
          0, '${DateTime.now().toString().substring(11, 19)}: $message');
      if (_logs.length > 100) {
        _logs.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.cable : Icons.cable_outlined),
            onPressed: _toggleConnection,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'update_firmware',
                child: Row(
                  children: [
                    Icon(Icons.system_update),
                    SizedBox(width: 8),
                    Text('Update Firmware'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'view_logs',
                child: Row(
                  children: [
                    Icon(Icons.list),
                    SizedBox(width: 8),
                    Text('View Logs'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'project_info',
                child: Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(width: 8),
                    Text('Project Info'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection Status Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: _getStatusColor(),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _connectionStatus,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (_isConnecting)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
              ],
            ),
          ),

          // Project Controls
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            _getArduinoIcon(widget.project.arduinoType),
                            size: 32,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.project.arduinoType,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '${widget.project.communicationType} • v${widget.project.firmwareVersion}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (!_isConnected)
                            ElevatedButton.icon(
                              onPressed: _toggleConnection,
                              icon: const Icon(Icons.link, size: 16),
                              label: const Text('Connect'),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Dynamic UI Controls
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Controls',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          DynamicUIWidget(
                            uiConfig: widget.project.uiConfig,
                            onCommandSent: _sendCommand,
                            isEnabled: _isConnected,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Recent Logs
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Activity',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              TextButton(
                                onPressed: () => _showLogsDialog(),
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 120,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: _logs.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No activity yet',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _logs.take(3).length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2),
                                        child: Text(
                                          _logs[index],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (_isConnected) return Colors.green;
    if (_isConnecting) return Colors.orange;
    return Colors.red;
  }

  IconData _getStatusIcon() {
    if (_isConnected) return Icons.check_circle;
    if (_isConnecting) return Icons.hourglass_empty;
    return Icons.error;
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

  Future<void> _toggleConnection() async {
    if (_isConnected) {
      await _disconnect();
    } else {
      await _connect();
    }
  }

  Future<void> _connect() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      await _communicationService.connect(
        widget.project.communicationType,
        widget.project.arduinoType,
      );
    } catch (e) {
      _addLog('Connection error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: $e')),
      );
    }
  }

  Future<void> _disconnect() async {
    await _communicationService.disconnect();
  }

  void _sendCommand(String command) {
    if (!_isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device not connected')),
        );
      }
      return;
    }

    _communicationService.sendCommand(command);
    _addLog('Sent: $command');
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'update_firmware':
        _showFirmwareUpdateDialog();
        break;
      case 'view_logs':
        _showLogsDialog();
        break;
      case 'project_info':
        _showProjectInfoDialog();
        break;
    }
  }

  void _showFirmwareUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Firmware'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.system_update, size: 48),
            SizedBox(height: 16),
            Text(
                'Select a firmware file (.hex or .bin) to upload to your Arduino.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement firmware upload here when ready
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Firmware update feature coming soon')),
                );
              }
            },
            child: const Text('Select File'),
          ),
        ],
      ),
    );
  }

  void _showLogsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Activity Logs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _logs.clear();
                      });
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.clear_all),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: _logs.isEmpty
                    ? const Center(child: Text('No logs available'))
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              _logs[index],
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProjectInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.project.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Arduino Type', widget.project.arduinoType),
            _buildInfoRow('Communication', widget.project.communicationType),
            _buildInfoRow('Firmware Version', widget.project.firmwareVersion),
            _buildInfoRow('Created',
                widget.project.createdAt.toString().substring(0, 16)),
            _buildInfoRow('Updated',
                widget.project.updatedAt.toString().substring(0, 16)),
            const SizedBox(height: 16),
            Text(
              'Controls: ${widget.project.uiConfig.controls.length}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
