import 'package:flutter/material.dart';
import 'package:gestabsence/screens/admin/add_student_screen.dart';
import 'package:gestabsence/screens/admin/edit_student_screen.dart';
import 'package:gestabsence/services/api_service.dart';
import 'package:gestabsence/themeapp.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key, this.openAddOnStart = false});

  final bool openAddOnStart;

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  List<Map<String, dynamic>> _students = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _classes = <Map<String, dynamic>>[];
  bool _isLoading = true;
  bool _didRunInitialAction = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final studentsResponse = await ApiService.get('/admin/etudiants.php');
    final classesResponse = await ApiService.get('/admin/classes.php');

    if (!mounted) return;

    final students = studentsResponse['success'] == 1 && studentsResponse['data'] is List
        ? (studentsResponse['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((s) => {
                  'id': int.tryParse(s['etudiant_id']?.toString() ?? '') ?? 0,
                  'nom': s['nom']?.toString() ?? '',
                  'prenom': s['prenom']?.toString() ?? '',
                  'email': s['email']?.toString() ?? '',
                  'classe_id': int.tryParse(s['classe_id']?.toString() ?? '') ?? 0,
                  'classe_nom': s['classe_nom']?.toString() ?? '',
                })
            .toList()
        : <Map<String, dynamic>>[];

    final classes = classesResponse['success'] == 1 && classesResponse['data'] is List
        ? (classesResponse['data'] as List).whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    setState(() {
      _students = students;
      _classes = classes;
      _isLoading = false;
    });

    if (!_didRunInitialAction && widget.openAddOnStart) {
      _didRunInitialAction = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _navigateToAdd();
      });
    }
  }

  List<Map<String, dynamic>> get _filtered => _students.where((s) {
        final q = _searchQuery.toLowerCase();
        return '${s['nom']} ${s['prenom']} ${s['email']} ${s['classe_nom']}'
            .toLowerCase()
            .contains(q);
      }).toList();

  Future<void> _navigateToAdd() async {
    if (_classes.isEmpty) {
      _showSnack('Create classes first before adding students.');
      return;
    }

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddStudentScreen(classes: _classes),
      ),
    );

    if (result == null) return;

    await _createStudent(result);
  }

  Future<void> _createStudent(Map<String, dynamic> data) async {
    final response = await ApiService.post('/admin/etudiants.php', data);
    if (!mounted) return;

    if (response['success'] == 1) {
      _showSnack('Student added successfully');
      await _loadData();

      final createdId = int.tryParse(response['data']?['etudiant_id']?.toString() ?? '');
      if (createdId != null && mounted) {
        final created = _students.where((s) => s['id'] == createdId).toList();
        if (created.isNotEmpty) {
          await _navigateToEdit(created.first);
        }
      }
    } else {
      _showSnack(response['message']?.toString() ?? 'Failed to add student');
    }
  }

  Future<void> _navigateToEdit(Map<String, dynamic> student) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditStudentScreen(classes: _classes, student: student),
      ),
    );

    if (result == null) return;

    if (result['_action'] == 'add' && result['payload'] is Map<String, dynamic>) {
      await _createStudent(result['payload'] as Map<String, dynamic>);
      return;
    }

    final response = await ApiService.put('/admin/etudiants.php', result);
    if (!mounted) return;

    if (response['success'] == 1) {
      _showSnack('Student updated successfully');
      await _loadData();
    } else {
      _showSnack(response['message']?.toString() ?? 'Failed to update student');
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Student'),
        content: Text(
          'Are you sure you want to remove ${student['prenom']} ${student['nom']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.errorRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final response = await ApiService.delete('/admin/etudiants.php?id=${student['id']}');
    if (!mounted) return;

    if (response['success'] == 1) {
      _showSnack('Student removed');
      await _loadData();
    } else {
      _showSnack(response['message']?.toString() ?? 'Failed to remove student');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        title: const Text('Students'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Student',
            onPressed: _navigateToAdd,
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
  
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: ThemeColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ThemeColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.groups_outlined, color: ThemeColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${_students.length} student${_students.length == 1 ? '' : 's'} registered',
                        style: ThemeTextStyles.bodyMedium.copyWith(
                          color: ThemeColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ThemeButtonStyles.secondary,
                      onPressed: _navigateToAdd,
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('Add Student'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by name, email or class...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: ThemeColors.surfaceAlt,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'No students yet.\nTap Add Student to get started.'
                                : 'No results for "$_searchQuery"',
                            style: ThemeTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final student = filtered[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: ThemeColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: ThemeColors.borderSubtle),
                              ),
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                title: Text(
                                  '${student['prenom']} ${student['nom']}',
                                  style: ThemeTextStyles.headlineSmall,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    Text(
                                      student['email']?.toString() ?? '',
                                      style: ThemeTextStyles.bodySmall,
                                    ),
                                    Text(
                                      'Class: ${student['classe_nom']?.toString() ?? 'N/A'}',
                                      style: ThemeTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                                trailing: SizedBox(
                                  width: 96,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: ThemeColors.primary,
                                        ),
                                        tooltip: 'Edit',
                                        onPressed: () => _navigateToEdit(student),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: ThemeColors.errorRed,
                                        ),
                                        tooltip: 'Remove',
                                        onPressed: () => _confirmDelete(student),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
