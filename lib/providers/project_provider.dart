import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../services/database_service.dart';

class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  List<Project> _filteredProjects = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Project> get projects => _filteredProjects;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      _projects = await DatabaseService.instance.getAllProjects();
      _applyFilter();
    } catch (e) {
      debugPrint('Error loading projects: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProject(Project project) async {
    try {
      final id = await DatabaseService.instance.insertProject(project);
      final newProject = project.copyWith();
      _projects.insert(0, Project.fromMap({...newProject.toMap(), 'id': id}));
      _applyFilter();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding project: $e');
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await DatabaseService.instance.updateProject(project);
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
        _applyFilter();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating project: $e');
    }
  }

  Future<void> deleteProject(int id) async {
    try {
      await DatabaseService.instance.deleteProject(id);
      _projects.removeWhere((p) => p.id == id);
      _applyFilter();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting project: $e');
    }
  }

  Future<Project?> getProject(int id) async {
    try {
      return await DatabaseService.instance.getProject(id);
    } catch (e) {
      debugPrint('Error getting project: $e');
      return null;
    }
  }

  void searchProjects(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredProjects = List.from(_projects);
    } else {
      _filteredProjects = _projects
          .where(
            (project) =>
                project.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                project.arduinoType.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }
  }

  Future<void> duplicateProject(Project project) async {
    final duplicatedProject = Project(
      name: '${project.name} (Copy)',
      arduinoType: project.arduinoType,
      communicationType: project.communicationType,
      uiConfigJson: project.uiConfigJson,
      firmwareVersion: project.firmwareVersion,
    );

    await addProject(duplicatedProject);
  }

  // Get statistics
  int get totalProjects => _projects.length;

  Map<String, int> get projectsByType {
    final Map<String, int> types = {};
    for (var project in _projects) {
      types[project.arduinoType] = (types[project.arduinoType] ?? 0) + 1;
    }
    return types;
  }

  Map<String, int> get projectsByCommunication {
    final Map<String, int> communication = {};
    for (var project in _projects) {
      communication[project.communicationType] =
          (communication[project.communicationType] ?? 0) + 1;
    }
    return communication;
  }
}
