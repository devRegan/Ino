import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/project.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'arduino_projects.db');

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        arduino_type TEXT NOT NULL,
        communication_type TEXT NOT NULL,
        ui_config_json TEXT NOT NULL,
        firmware_version TEXT DEFAULT '1.0.0',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Insert sample projects for demonstration
    await _insertSampleProjects(db);
  }

  Future<void> _insertSampleProjects(Database db) async {
    final sampleProjects = [
      {
        'name': 'LED Controller',
        'arduino_type': 'Arduino Uno',
        'communication_type': 'USB',
        'ui_config_json': '''
{
  "controls": [
    {"type": "button", "label": "LED On", "command": "LED_ON"},
    {"type": "button", "label": "LED Off", "command": "LED_OFF"},
    {"type": "slider", "label": "Brightness", "command_prefix": "BRIGHTNESS:", "min_value": 0, "max_value": 255, "default_value": 128}
  ]
}''',
        'firmware_version': '1.0.0',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'name': 'Motor Control',
        'arduino_type': 'Arduino Nano',
        'communication_type': 'USB',
        'ui_config_json': '''
{
  "controls": [
    {"type": "button", "label": "Start Motor", "command": "MOTOR_START"},
    {"type": "button", "label": "Stop Motor", "command": "MOTOR_STOP"},
    {"type": "slider", "label": "Speed", "command_prefix": "SPEED:", "min_value": 0, "max_value": 100, "default_value": 50},
    {"type": "switch", "label": "Direction", "command_on": "DIR_FORWARD", "command_off": "DIR_REVERSE"}
  ]
}''',
        'firmware_version': '1.2.1',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
    ];

    for (var project in sampleProjects) {
      await db.insert('projects', project);
    }
  }

  Future<void> initDatabase() async {
    await database;
  }

  // CRUD Operations
  Future<int> insertProject(Project project) async {
    final db = await database;
    return await db.insert('projects', project.toMap());
  }

  Future<List<Project>> getAllProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      orderBy: 'updated_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Project.fromMap(maps[i]);
    });
  }

  Future<Project?> getProject(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Project.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateProject(Project project) async {
    final db = await database;
    await db.update(
      'projects',
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<void> deleteProject(int id) async {
    final db = await database;
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Project>> searchProjects(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'updated_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Project.fromMap(maps[i]);
    });
  }
}
