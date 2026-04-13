import 'package:flutter/material.dart';
import 'package:gestabsence/services/api_service.dart';
import 'package:gestabsence/themeapp.dart';

enum StudentsScreenAction { addMatiere, assignClass }

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key, this.initialAction});

  final StudentsScreenAction? initialAction;

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  bool _isLoading = true;
  bool _didRunInitialAction = false;
  List<Map<String, dynamic>> _classes = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _matieres = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _assignments = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  Future<void> _reloadData() async {
    setState(() {
      _isLoading = true;
    });

    final classesResponse = await ApiService.get('/admin/classes.php');
    final matieresResponse = await ApiService.get('/admin/matieres.php');
    final assignmentsResponse = await ApiService.get('/admin/class_matieres.php');

    if (!mounted) return;

    final classes = classesResponse['success'] == 1 && classesResponse['data'] is List
        ? (classesResponse['data'] as List).whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];
    final matieres = matieresResponse['success'] == 1 && matieresResponse['data'] is List
        ? (matieresResponse['data'] as List).whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];
    final assignments = assignmentsResponse['success'] == 1 && assignmentsResponse['data'] is List
        ? (assignmentsResponse['data'] as List)
            .whereType<Map<String, dynamic>>()
            .toList()
        : <Map<String, dynamic>>[];

    setState(() {
      _classes = classes;
      _matieres = matieres;
      _assignments = assignments;
      _isLoading = false;
    });

    if (!_didRunInitialAction && widget.initialAction != null) {
      _didRunInitialAction = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final action = widget.initialAction;
        if (action == null) return;
        switch (action) {
          case StudentsScreenAction.addMatiere:
            _showAddMatiereDialog();
            break;
          case StudentsScreenAction.assignClass:
            _showAssignDialog();
            break;
        }
      });
    }
  }

  Future<void> _showAddMatiereDialog() async {
    final nameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColors.surface,
        title: const Text('Add Matiere'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Matiere name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    final name = nameController.text.trim();
    if (result != true || name.isEmpty) return;

    final response = await ApiService.post('/admin/matieres.php', {'nom': name});
    if (!mounted) return;

    if (response['success'] == 1) {
      _showSnack('Matiere added.');
      await _reloadData();
    } else {
      _showSnack(response['message']?.toString() ?? 'Failed to add matiere.');
    }
  }

  Future<void> _showAddClassDialog() async {
    final nameController = TextEditingController();
    final levelController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColors.surface,
        title: const Text('Add Class'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Class name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: levelController,
              decoration: const InputDecoration(labelText: 'Level (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    final name = nameController.text.trim();
    final level = levelController.text.trim();
    if (result != true || name.isEmpty) return;

    final payload = <String, dynamic>{'nom': name};
    if (level.isNotEmpty) {
      payload['niveau'] = level;
    }

    final response = await ApiService.post('/admin/classes.php', payload);
    if (!mounted) return;

    if (response['success'] == 1) {
      _showSnack('Class added.');
      await _reloadData();
    } else {
      _showSnack(response['message']?.toString() ?? 'Failed to add class.');
    }
  }

  Future<void> _showAssignDialog() async {
    final classOptions = _classes
        .map((c) {
          final id = int.tryParse(c['id']?.toString() ?? '');
          if (id == null) return null;
          return (id: id, name: c['nom']?.toString() ?? 'Class');
        })
        .whereType<({int id, String name})>()
        .toList();

    final matiereOptions = _matieres
        .map((m) {
          final id = int.tryParse(m['id']?.toString() ?? '');
          if (id == null) return null;
          return (id: id, name: m['nom']?.toString() ?? 'Matiere');
        })
        .whereType<({int id, String name})>()
        .toList();

    if (classOptions.isEmpty || matiereOptions.isEmpty) {
      _showSnack('Please make sure classes and matieres exist first.');
      return;
    }

    int? selectedClassId = classOptions.first.id;
    int? selectedMatiereId = matiereOptions.first.id;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) => AlertDialog(
            backgroundColor: ThemeColors.surface,
            title: const Text('Assign Class to Matiere'),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedClassId,
                    items: classOptions
                        .map(
                          (c) => DropdownMenuItem<int>(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedClassId = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Class'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedMatiereId,
                    items: matiereOptions
                        .map(
                          (m) => DropdownMenuItem<int>(
                            value: m.id,
                            child: Text(m.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedMatiereId = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Matiere'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Assign'),
              ),
            ],
          ),
        );
      },
    );

    if (result != true || selectedClassId == null || selectedMatiereId == null) return;

    final response = await ApiService.post('/admin/class_matieres.php', {
      'classe_id': selectedClassId,
      'matiere_id': selectedMatiereId,
    });

    if (!mounted) return;

    if (response['success'] == 1) {
      _showSnack('Assignment saved.');
      await _reloadData();
    } else {
      final message = response['statusCode'] == 409
          ? 'Already assigned to that class.'
          : (response['message']?.toString() ?? 'Failed to assign class.');
      _showSnack(message);
    }
  }

  Future<void> _deleteMatiere(int id) async {
    final response = await ApiService.delete('/admin/matieres.php?id=$id');
    if (!mounted) return;
    if (response['success'] == 1) {
      _showSnack('Matiere deleted.');
      await _reloadData();
    } else {
      _showSnack(response['message']?.toString() ?? 'Failed to delete matiere.');
    }
  }

  Future<void> _deleteAssignment(int id) async {
    final response = await ApiService.delete('/admin/class_matieres.php?id=$id');
    if (!mounted) return;
    if (response['success'] == 1) {
      _showSnack('Assignment deleted.');
      await _reloadData();
    } else {
      _showSnack(response['message']?.toString() ?? 'Failed to delete assignment.');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        title: const Text('Manage Classes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _reloadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ThemeColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: ThemeColors.borderSubtle),
                    ),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          style: ThemeButtonStyles.secondary,
                          onPressed: _showAddClassDialog,
                          icon: const Icon(Icons.class_outlined),
                          label: const Text('Add Class'),
                        ),
                        ElevatedButton.icon(
                          style: ThemeButtonStyles.secondary,
                          onPressed: _showAddMatiereDialog,
                          icon: const Icon(Icons.menu_book_outlined),
                          label: const Text('Add Matiere'),
                        ),
                        OutlinedButton.icon(
                          style: ThemeButtonStyles.outlined,
                          onPressed: _showAssignDialog,
                          icon: const Icon(Icons.link_outlined),
                          label: const Text('Assign Class -> Matiere'),
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    title: 'Matieres',
                    icon: Icons.menu_book_outlined,
                    child: _matieres.isEmpty
                        ? Text('No matieres yet.', style: ThemeTextStyles.bodyMedium)
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _matieres
                                .map(
                                  (m) => InputChip(
                                    label: Text(m['nom']?.toString() ?? 'Matiere'),
                                    backgroundColor: ThemeColors.surfaceAlt,
                                    onDeleted: () {
                                      final id = int.tryParse(m['id']?.toString() ?? '');
                                      if (id != null) {
                                        _deleteMatiere(id);
                                      }
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Class Assignments',
                    icon: Icons.class_outlined,
                    child: _assignments.isEmpty
                        ? Text(
                            'No class-to-matiere assignments yet.',
                            style: ThemeTextStyles.bodyMedium,
                          )
                        : Column(
                            children: _assignments
                                .map(
                                  (a) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.arrow_right_alt),
                                    title: Text(
                                      a['classe_nom']?.toString() ?? 'Class',
                                      style: ThemeTextStyles.bodyLarge,
                                    ),
                                    subtitle: Text(
                                      a['matiere_nom']?.toString() ?? 'Matiere',
                                      style: ThemeTextStyles.bodySmall,
                                    ),
                                    trailing: IconButton(
                                      tooltip: 'Delete assignment',
                                      icon: const Icon(
                                        Icons.close,
                                        color: ThemeColors.errorRed,
                                      ),
                                      onPressed: () {
                                        final id = int.tryParse(
                                          a['id']?.toString() ?? '',
                                        );
                                        if (id != null) {
                                          _deleteAssignment(id);
                                        }
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ThemeColors.primary),
              const SizedBox(width: 8),
              Text(title, style: ThemeTextStyles.headlineSmall),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
