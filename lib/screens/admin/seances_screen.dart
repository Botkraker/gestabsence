import 'package:flutter/material.dart';
import 'package:gestabsence/models/seance.dart';
import 'package:gestabsence/screens/enseignant/appel_screen.dart';
import 'package:gestabsence/services/api_service.dart';
import 'package:gestabsence/themeapp.dart';

/// Admin seances management screen.
///
/// Main capabilities:
/// - Load seances and lookup entities.
/// - Add/edit/delete seances.
/// - Search by class, subject, teacher, date and time.
class SeancesScreen extends StatefulWidget {
  const SeancesScreen({super.key});

  @override
  State<SeancesScreen> createState() => _SeancesScreenState();
}

class _SeancesScreenState extends State<SeancesScreen> {
  List<Map<String, dynamic>> _seances = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _teachers = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _classes = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _matieres = <Map<String, dynamic>>[];
  bool _isLoading = true;
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

    final seancesResponse = await ApiService.get('/admin/seances.php');
    final teachersResponse = await ApiService.get('/admin/enseignants.php');
    final classesResponse = await ApiService.get('/admin/classes.php');
    final matieresResponse = await ApiService.get('/admin/matieres.php');

    if (!mounted) return;

    final seances = seancesResponse['success'] == 1 && seancesResponse['data'] is List
        ? (seancesResponse['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((s) => {
                  'id': int.tryParse(s['id']?.toString() ?? '') ?? 0,
                  'enseignant_id': int.tryParse(s['enseignant_id']?.toString() ?? '') ?? 0,
                  'classe_id': int.tryParse(s['classe_id']?.toString() ?? '') ?? 0,
                  'matiere_id': int.tryParse(s['matiere_id']?.toString() ?? '') ?? 0,
                  'date_seance': s['date_seance']?.toString() ?? '',
                  'heure_debut': s['heure_debut']?.toString() ?? '',
                  'heure_fin': s['heure_fin']?.toString() ?? '',
                  'enseignant_nom': s['enseignant_nom']?.toString() ?? '',
                  'enseignant_prenom': s['enseignant_prenom']?.toString() ?? '',
                  'classe_nom': s['classe_nom']?.toString() ?? '',
                  'matiere_nom': s['matiere_nom']?.toString() ?? '',
                })
            .toList()
        : <Map<String, dynamic>>[];

    final teachers = teachersResponse['success'] == 1 && teachersResponse['data'] is List
        ? (teachersResponse['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((t) => {
                  'id': int.tryParse(t['enseignant_id']?.toString() ?? '') ?? 0,
                  'nom': t['nom']?.toString() ?? '',
                  'prenom': t['prenom']?.toString() ?? '',
                })
            .where((t) => (t['id'] as int) > 0)
            .toList()
        : <Map<String, dynamic>>[];

    final classes = classesResponse['success'] == 1 && classesResponse['data'] is List
        ? (classesResponse['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((c) => {
                  'id': int.tryParse(c['id']?.toString() ?? '') ?? 0,
                  'nom': c['nom']?.toString() ?? '',
                })
            .where((c) => (c['id'] as int) > 0)
            .toList()
        : <Map<String, dynamic>>[];

    final matieres = matieresResponse['success'] == 1 && matieresResponse['data'] is List
        ? (matieresResponse['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map((m) => {
                  'id': int.tryParse(m['id']?.toString() ?? '') ?? 0,
                  'nom': m['nom']?.toString() ?? '',
                })
            .where((m) => (m['id'] as int) > 0)
            .toList()
        : <Map<String, dynamic>>[];

    setState(() {
      _seances = seances;
      _teachers = teachers;
      _classes = classes;
      _matieres = matieres;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filtered => _seances.where((s) {
        final q = _searchQuery.toLowerCase();
        final teacher = '${s['enseignant_nom']} ${s['enseignant_prenom']}'.trim();
        return '${s['matiere_nom']} ${s['classe_nom']} $teacher ${s['date_seance']} ${s['heure_debut']} ${s['heure_fin']}'
            .toLowerCase()
            .contains(q);
      }).toList();

  Future<void> _navigateToAdd() async {
    if (_teachers.isEmpty || _classes.isEmpty || _matieres.isEmpty) {
      _showSnack('Create teachers, classes, and matieres first.');
      return;
    }

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => _SeanceFormScreen(
          teachers: _teachers,
          classes: _classes,
          matieres: _matieres,
        ),
      ),
    );

    if (result == null) return;

    await _createSeance(result);
  }

  Future<void> _createSeance(Map<String, dynamic> data) async {
    final response = await ApiService.post('/admin/seances.php', data);
    if (!mounted) return;

    if (response['success'] == 1) {
      _showSnack('Seance added successfully');
      await _loadData();
    } else {
      _showSnack(response['message']?.toString() ?? 'Failed to add seance');
    }
  }

  Future<void> _navigateToEdit(Map<String, dynamic> seance) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => _SeanceFormScreen(
          teachers: _teachers,
          classes: _classes,
          matieres: _matieres,
          seance: seance,
        ),
      ),
    );

    if (result == null) return;

    final response = await ApiService.put('/admin/seances.php', result);
    if (!mounted) return;

    if (response['success'] == 1) {
      _showSnack('Seance updated successfully');
      await _loadData();
    } else {
      _showSnack(response['message']?.toString() ?? 'Failed to update seance');
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> seance) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Seance'),
        content: Text(
          'Are you sure you want to remove ${seance['matiere_nom']} - ${seance['classe_nom']}?',
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

    final response = await ApiService.delete('/admin/seances.php?id=${seance['id']}');
    if (!mounted) return;

    if (response['success'] == 1) {
      _showSnack('Seance removed');
      await _loadData();
    } else {
      _showSnack(response['message']?.toString() ?? 'Failed to remove seance');
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
        title: const Text('Seances'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Seance',
            onPressed: _navigateToAdd,
            icon: const Icon(Icons.add),
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
                      const Icon(Icons.schedule_outlined, color: ThemeColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${_seances.length} seance${_seances.length == 1 ? '' : 's'} registered',
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
                      icon: const Icon(Icons.add),
                      label: const Text('Add Seance'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by subject, class, teacher, date or time...',
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
                                ? 'No seances yet.\nTap Add Seance to get started.'
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
                            final seance = filtered[index];
                            final teacher =
                                '${seance['enseignant_nom']} ${seance['enseignant_prenom']}'.trim();
                            return Container(
                              decoration: BoxDecoration(
                                color: ThemeColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: ThemeColors.borderSubtle),
                              ),
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                onTap: () {
                                  final selectedSeance = Seance.fromJson(seance);
                                  final teacherName =
                                      '${seance['enseignant_nom']} ${seance['enseignant_prenom']}'
                                          .trim();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AppelScreen(
                                        userId: (seance['enseignant_id'] as int?) ?? 0,
                                        name: teacherName.isEmpty ? 'Admin' : teacherName,
                                        seance: selectedSeance,
                                      ),
                                    ),
                                  );
                                },
                                title: Text(
                                  '${seance['matiere_nom']} - ${seance['classe_nom']}',
                                  style: ThemeTextStyles.headlineSmall,
                                ),
                                isThreeLine: true,
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 2),
                                    Text(
                                      'Teacher: ${teacher.isEmpty ? 'N/A' : teacher}',
                                      style: ThemeTextStyles.bodySmall,
                                    ),
                                    Text(
                                      'Date: ${seance['date_seance']}   Time: ${_formatTime(seance['heure_debut']?.toString())} - ${_formatTime(seance['heure_fin']?.toString())}',
                                      style: ThemeTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: ThemeColors.primary,
                                      ),
                                      tooltip: 'Edit',
                                      onPressed: () => _navigateToEdit(seance),
                                      padding: const EdgeInsets.all(8),
                                      constraints:
                                          const BoxConstraints(minWidth: 36, minHeight: 36),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: ThemeColors.errorRed,
                                      ),
                                      tooltip: 'Remove',
                                      onPressed: () => _confirmDelete(seance),
                                      padding: const EdgeInsets.all(8),
                                      constraints:
                                          const BoxConstraints(minWidth: 36, minHeight: 36),
                                    ),
                                  ],
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

  String _formatTime(String? value) {
    if (value == null || value.trim().isEmpty) return '--:--';
    final parts = value.split(':');
    if (parts.length < 2) return '--:--';
    final hour = parts[0].padLeft(2, '0');
    final minute = parts[1].padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _SeanceFormScreen extends StatefulWidget {
  const _SeanceFormScreen({
    required this.teachers,
    required this.classes,
    required this.matieres,
    this.seance,
  });

  final List<Map<String, dynamic>> teachers;
  final List<Map<String, dynamic>> classes;
  final List<Map<String, dynamic>> matieres;
  final Map<String, dynamic>? seance;

  @override
  State<_SeanceFormScreen> createState() => _SeanceFormScreenState();
}

class _SeanceFormScreenState extends State<_SeanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  bool _isSaving = false;
  late int _selectedTeacherId;
  late int _selectedClassId;
  late int _selectedMatiereId;

  bool get _isEditing => widget.seance != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final s = widget.seance!;
      _selectedTeacherId = int.tryParse(s['enseignant_id']?.toString() ?? '') ??
          int.tryParse(widget.teachers.first['id']?.toString() ?? '0') ??
          0;
      _selectedClassId = int.tryParse(s['classe_id']?.toString() ?? '') ??
          int.tryParse(widget.classes.first['id']?.toString() ?? '0') ??
          0;
      _selectedMatiereId = int.tryParse(s['matiere_id']?.toString() ?? '') ??
          int.tryParse(widget.matieres.first['id']?.toString() ?? '0') ??
          0;
      _dateController.text = s['date_seance']?.toString() ?? '';
      _startController.text = s['heure_debut']?.toString() ?? '';
      _endController.text = s['heure_fin']?.toString() ?? '';
    } else {
      _selectedTeacherId = int.tryParse(widget.teachers.first['id']?.toString() ?? '0') ?? 0;
      _selectedClassId = int.tryParse(widget.classes.first['id']?.toString() ?? '0') ?? 0;
      _selectedMatiereId = int.tryParse(widget.matieres.first['id']?.toString() ?? '0') ?? 0;
      _dateController.text = DateTime.now().toIso8601String().split('T').first;
      _startController.text = '08:00:00';
      _endController.text = '10:00:00';
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final payload = <String, dynamic>{
      'enseignant_id': _selectedTeacherId,
      'classe_id': _selectedClassId,
      'matiere_id': _selectedMatiereId,
      'date_seance': _dateController.text.trim(),
      'heure_debut': _startController.text.trim(),
      'heure_fin': _endController.text.trim(),
      if (_isEditing) 'id': int.tryParse(widget.seance!['id']?.toString() ?? '0') ?? 0,
    };

    Navigator.pop(context, payload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Seance' : 'Add Seance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedTeacherId,
                decoration: const InputDecoration(
                  labelText: 'Teacher',
                  border: OutlineInputBorder(),
                ),
                items: widget.teachers.map<DropdownMenuItem<int>>((t) {
                  final id = int.tryParse(t['id']?.toString() ?? '0') ?? 0;
                  final fullName = '${t['nom'] ?? ''} ${t['prenom'] ?? ''}'.trim();
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(fullName.isEmpty ? 'Teacher #$id' : fullName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTeacherId = value ?? _selectedTeacherId;
                  });
                },
                validator: (v) => v == null || v == 0 ? 'Please select a teacher' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedClassId,
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                ),
                items: widget.classes.map<DropdownMenuItem<int>>((c) {
                  final id = int.tryParse(c['id']?.toString() ?? '0') ?? 0;
                  final name = c['nom']?.toString() ?? 'Class #$id';
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClassId = value ?? _selectedClassId;
                  });
                },
                validator: (v) => v == null || v == 0 ? 'Please select a class' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedMatiereId,
                decoration: const InputDecoration(
                  labelText: 'Matiere',
                  border: OutlineInputBorder(),
                ),
                items: widget.matieres.map<DropdownMenuItem<int>>((m) {
                  final id = int.tryParse(m['id']?.toString() ?? '0') ?? 0;
                  final name = m['nom']?.toString() ?? 'Matiere #$id';
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMatiereId = value ?? _selectedMatiereId;
                  });
                },
                validator: (v) => v == null || v == 0 ? 'Please select a matiere' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Date is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startController,
                decoration: const InputDecoration(
                  labelText: 'Start (HH:MM:SS)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Start time is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endController,
                decoration: const InputDecoration(
                  labelText: 'End (HH:MM:SS)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'End time is required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                child: Text(_isEditing ? 'Save Changes' : 'Add Seance'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
