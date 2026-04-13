import 'package:flutter/material.dart';
import 'package:gestabsence/screens/admin/add_professor_screen.dart';
import 'package:gestabsence/screens/admin/edit_professor_screen.dart';
import 'package:gestabsence/services/api_service.dart';
import 'package:gestabsence/themeapp.dart';

class ProfessorsScreen extends StatefulWidget {
  const ProfessorsScreen({super.key, this.openAddOnStart = false});

  final bool openAddOnStart;

  @override
  State<ProfessorsScreen> createState() => _ProfessorsScreenState();
}

class _ProfessorsScreenState extends State<ProfessorsScreen> {
  List<Map<String, dynamic>> _professors = [];
  bool _isLoading = true;
  bool _didRunInitialAction = false;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProfessors();
  }

  Future<void> _loadProfessors() async {
    setState(() {
      _isLoading = true;
    });

    final response = await ApiService.get('/admin/enseignants.php');

    if (!mounted) return;

    final data = response['success'] == 1 && response['data'] is List
        ? (response['data'] as List).whereType<Map<String, dynamic>>().map((row) {
            return {
              'id': int.tryParse(row['enseignant_id']?.toString() ?? '') ?? 0,
              'nom': row['nom']?.toString() ?? '',
              'prenom': row['prenom']?.toString() ?? '',
              'email': row['email']?.toString() ?? '',
              'matiere': row['specialite']?.toString() ?? '',
            };
          }).toList()
        : <Map<String, dynamic>>[];

    setState(() {
      _professors = data;
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

  List<Map<String, dynamic>> get _filtered => _professors.where((p) {
        final q = _searchQuery.toLowerCase();
        return '${p['nom']} ${p['prenom']} ${p['email']} ${p['matiere']}'
            .toLowerCase()
            .contains(q);
      }).toList();

  Future<void> _navigateToAdd() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddProfessorScreen()),
    );

    if (result != null) {
      await _createProfessor(result);
    }
  }

  Future<void> _createProfessor(Map<String, dynamic> data) async {
    final response = await ApiService.post('/admin/enseignants.php', {
      'nom': data['nom'],
      'prenom': data['prenom'],
      'email': data['email'],
      'password': data['password'],
      'specialite': data['matiere'],
    });

    if (!mounted) return;

    if (response['success'] == 1) {
      _showSnack('Professor added successfully');
      await _loadProfessors();

      final createdId = int.tryParse(
        response['data']?['enseignant_id']?.toString() ?? '',
      );

      if (createdId != null && mounted) {
        final created = _professors.where((p) => p['id'] == createdId).toList();
        if (created.isNotEmpty) {
          await _navigateToEdit(created.first);
        }
      }
    } else {
      _showSnack(response['message']?.toString() ?? 'Failed to add professor');
    }
  }

  Future<void> _navigateToEdit(Map<String, dynamic> professor) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfessorScreen(professor: professor),
      ),
    );

    if (result != null) {
      if (result['_action'] == 'add' && result['payload'] is Map<String, dynamic>) {
        await _createProfessor(result['payload'] as Map<String, dynamic>);
        return;
      }

      final response = await ApiService.put('/admin/enseignants.php', {
        'id': result['id'],
        'nom': result['nom'],
        'prenom': result['prenom'],
        'email': result['email'],
        'specialite': result['matiere'],
        if ((result['password']?.toString() ?? '').isNotEmpty)
          'password': result['password'],
      });

      if (!mounted) return;

      if (response['success'] == 1) {
        _showSnack('Professor updated successfully');
        await _loadProfessors();
      } else {
        _showSnack(response['message']?.toString() ?? 'Failed to update professor');
      }
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> professor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Professor'),
        content: Text(
          'Are you sure you want to remove ${professor['prenom']} ${professor['nom']}?',
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

    if (confirmed == true) {
      final response = await ApiService.delete('/admin/enseignants.php?id=${professor['id']}');

      if (!mounted) return;

      if (response['success'] == 1) {
        _showSnack('Professor removed');
        await _loadProfessors();
      } else {
        _showSnack(response['message']?.toString() ?? 'Failed to remove professor');
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        title: const Text('Professors'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              style: ThemeButtonStyles.secondary,
              onPressed: _navigateToAdd,
              icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
              label: const Text('Add Professor'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
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
                const Icon(Icons.people, color: ThemeColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_professors.length} professor${_professors.length == 1 ? '' : 's'} registered',
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
                label: const Text('Add Enseignant'),
              ),
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, email or subject...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: ThemeColors.surfaceAlt,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No professors yet.\nTap "Add" to get started.'
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
                          final prof = filtered[index];
                          return _ProfessorTile(
                            professor: prof,
                            onEdit: () => _navigateToEdit(prof),
                            onDelete: () => _confirmDelete(prof),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _ProfessorTile extends StatelessWidget {
  const _ProfessorTile({
    required this.professor,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> professor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final fullName = '${professor['prenom']} ${professor['nom']}';
    final initials = _initials(professor['prenom'], professor['nom']);

    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: ThemeColors.primary.withValues(alpha: 0.12),
          child: Text(
            initials,
            style: TextStyle(
              color: ThemeColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        title: Text(fullName, style: ThemeTextStyles.headlineSmall),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 13, color: ThemeColors.textSecondary),
                const SizedBox(width: 4),
                Text(professor['email'] ?? '', style: ThemeTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.menu_book_outlined, size: 13, color: ThemeColors.textSecondary),
                const SizedBox(width: 4),
                Text(professor['matiere'] ?? '', style: ThemeTextStyles.bodySmall),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: ThemeColors.primary),
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: ThemeColors.errorRed),
              tooltip: 'Remove',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String? prenom, String? nom) {
    final a = (prenom?.isNotEmpty == true) ? prenom![0].toUpperCase() : '';
    final b = (nom?.isNotEmpty == true) ? nom![0].toUpperCase() : '';
    return '$a$b';
  }
}
