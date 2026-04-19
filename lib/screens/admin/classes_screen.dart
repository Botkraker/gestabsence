import 'package:flutter/material.dart';
import 'package:gestabsence/services/class_service.dart';
import 'package:gestabsence/services/matiere_service.dart';
import 'package:gestabsence/themeapp.dart';

/// Admin classes/subjects management screen.
///
/// Main capabilities:
/// - Create classes and matieres.
/// - View classes and matieres.
/// - Delete matieres.
class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  bool _isLoading = true;

  List<Map<String, dynamic>> _classes = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _matieres = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  Future<void> _reloadData() async {
    setState(() {
      _isLoading = true;
    });

    final classes = await ClassService.getAllClasses();
    final matieres = await MatiereService.getAllMatieres();

    if (!mounted) return;

    setState(() {
      _classes = classes;
      _matieres = matieres;
      _isLoading = false;
    });
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
          decoration: const InputDecoration(labelText: 'Matiere name'),
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

    final response = await MatiereService.createMatiere(nom: name);
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

    final response = await ClassService.createClass(
      nom: name,
      niveau: level,
    );
    if (!mounted) return;

    if (response['success'] == 1) {
      _showSnack('Class added.');
      await _reloadData();
    } else {
      _showSnack(response['message']?.toString() ?? 'Failed to add class.');
    }
  }

  Future<void> _deleteMatiere(int id) async {
    final response = await MatiereService.deleteMatiere(id);
    if (!mounted) return;

    if (response['success'] == 1) {
      _showSnack('Matiere deleted.');
      await _reloadData();
    } else {
      _showSnack(response['message']?.toString() ?? 'Failed to delete matiere.');
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Classes',
                    icon: Icons.class_outlined,
                    child: _classes.isEmpty
                        ? Text('No classes yet.', style: ThemeTextStyles.bodyMedium)
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _classes.length,
                            separatorBuilder: (_, __) => const Divider(height: 10),
                            itemBuilder: (context, index) {
                              final c = _classes[index];
                              final level = c['niveau']?.toString().trim() ?? '';
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.class_outlined),
                                title: Text(
                                  c['nom']?.toString() ?? 'Class',
                                  style: ThemeTextStyles.bodyLarge,
                                ),
                                subtitle: level.isEmpty
                                    ? null
                                    : Text(level, style: ThemeTextStyles.bodySmall),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Matieres',
                    icon: Icons.menu_book_outlined,
                    child: _matieres.isEmpty
                        ? Text('No matieres yet.', style: ThemeTextStyles.bodyMedium)
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _matieres.length,
                            separatorBuilder: (_, __) => const Divider(height: 10),
                            itemBuilder: (context, index) {
                              final m = _matieres[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.menu_book_outlined),
                                title: Text(
                                  m['nom']?.toString() ?? 'Matiere',
                                  style: ThemeTextStyles.bodyLarge,
                                ),
                                trailing: TextButton(
                                  onPressed: () {
                                    final id = int.tryParse(m['id']?.toString() ?? '');
                                    if (id != null) {
                                      _deleteMatiere(id);
                                    }
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: ThemeColors.errorRed),
                                  ),
                                ),
                              );
                            },
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(title, style: ThemeTextStyles.bodyLarge),
            ],
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }
}
