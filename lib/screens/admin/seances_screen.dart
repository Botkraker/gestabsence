import 'package:flutter/material.dart';
import 'package:gestabsence/models/seance.dart';
import 'package:gestabsence/models/seance_absence_stats.dart';
import 'package:gestabsence/screens/enseignant/appel_screen.dart';
import 'package:gestabsence/services/api_service.dart';
import 'package:gestabsence/themeapp.dart';

class SeancesScreen extends StatefulWidget {
  const SeancesScreen({super.key});

  @override
  State<SeancesScreen> createState() => _SeancesScreenState();
}

class _SeancesScreenState extends State<SeancesScreen> {
  late Future<List<SeanceAbsenceStats>> _futureSeances;

  @override
  void initState() {
    super.initState();
    _futureSeances = _loadSeances();
  }

  Future<List<SeanceAbsenceStats>> _loadSeances() async {
    final response = await ApiService.get('/admin/seances.php');
    if (response['success'] == 1 && response['data'] is List) {
      final items = (response['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(SeanceAbsenceStats.fromJson)
          .toList();
      items.sort((a, b) {
        final startA = _toDateTime(a.date, a.startTime);
        final startB = _toDateTime(b.date, b.startTime);

        if (startA == null && startB == null) return a.id.compareTo(b.id);
        if (startA == null) return 1;
        if (startB == null) return -1;
        return startA.compareTo(startB);
      });
      return items;
    }
    throw Exception(response['message']?.toString() ?? 'Failed to load seances');
  }

  Future<List<Map<String, dynamic>>> _loadOptions(String endpoint) async {
    final response = await ApiService.get(endpoint);
    if (response['success'] == 1 && response['data'] is List) {
      return (response['data'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  Future<void> _openSeanceForm({SeanceAbsenceStats? existing}) async {
    final teachersRaw = await _loadOptions('/admin/enseignants.php');
    final classesRaw = await _loadOptions('/admin/classes.php');
    final matieresRaw = await _loadOptions('/admin/matieres.php');

    final teachers = teachersRaw
        .map((t) {
          final id = int.tryParse(t['enseignant_id']?.toString() ?? '');
          if (id == null) return null;
          final name =
              '${t['nom']?.toString() ?? ''} ${t['prenom']?.toString() ?? ''}'.trim();
          return (id: id, name: name.isEmpty ? 'Teacher #$id' : name);
        })
        .whereType<({int id, String name})>()
        .toList();
    final classes = classesRaw
        .map((c) {
          final id = int.tryParse(c['id']?.toString() ?? '');
          if (id == null) return null;
          return (id: id, name: c['nom']?.toString() ?? 'Class #$id');
        })
        .whereType<({int id, String name})>()
        .toList();
    final matieres = matieresRaw
        .map((m) {
          final id = int.tryParse(m['id']?.toString() ?? '');
          if (id == null) return null;
          return (id: id, name: m['nom']?.toString() ?? 'Matiere #$id');
        })
        .whereType<({int id, String name})>()
        .toList();

    if (!mounted) return;

    if (teachers.isEmpty || classes.isEmpty || matieres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create teachers, classes, and matieres first.'),
        ),
      );
      return;
    }

    int? selectedTeacherId;
    int? selectedClassId;
    int? selectedMatiereId;
    final dateController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();

    if (existing != null) {
      final detail = await ApiService.get('/admin/seances.php?id=${existing.id}');
      final data = detail['data'] is Map<String, dynamic>
          ? detail['data'] as Map<String, dynamic>
          : <String, dynamic>{};
      selectedTeacherId = int.tryParse(data['enseignant_id']?.toString() ?? '');
      selectedClassId = int.tryParse(data['classe_id']?.toString() ?? '');
      selectedMatiereId = int.tryParse(data['matiere_id']?.toString() ?? '');
      dateController.text = data['date_seance']?.toString() ?? '';
      startController.text = data['heure_debut']?.toString() ?? '';
      endController.text = data['heure_fin']?.toString() ?? '';
    }

    selectedTeacherId ??= teachers.first.id;
    selectedClassId ??= classes.first.id;
    selectedMatiereId ??= matieres.first.id;
    dateController.text = dateController.text.isEmpty
        ? DateTime.now().toIso8601String().split('T').first
        : dateController.text;
    startController.text = startController.text.isEmpty ? '08:00:00' : startController.text;
    endController.text = endController.text.isEmpty ? '10:00:00' : endController.text;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: ThemeColors.surface,
              title: Text(existing == null ? 'Add Seance' : 'Edit Seance'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedTeacherId,
                      items: teachers
                          .map(
                            (t) => DropdownMenuItem<int>(
                              value: t.id,
                              child: Text(t.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedTeacherId = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Teacher'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: selectedClassId,
                      items: classes
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
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: selectedMatiereId,
                      items: matieres
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
                    const SizedBox(height: 10),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: startController,
                      decoration: const InputDecoration(labelText: 'Start (HH:MM:SS)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: endController,
                      decoration: const InputDecoration(labelText: 'End (HH:MM:SS)'),
                    ),
                  ],
                ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(existing == null ? 'Create' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true ||
        selectedTeacherId == null ||
        selectedClassId == null ||
        selectedMatiereId == null) {
      return;
    }

    final payload = <String, dynamic>{
      'enseignant_id': selectedTeacherId,
      'classe_id': selectedClassId,
      'matiere_id': selectedMatiereId,
      'date_seance': dateController.text.trim(),
      'heure_debut': startController.text.trim(),
      'heure_fin': endController.text.trim(),
    };

    final response = existing == null
        ? await ApiService.post('/admin/seances.php', payload)
        : await ApiService.put('/admin/seances.php', {
            ...payload,
            'id': existing.id,
          });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response['success'] == 1
              ? (existing == null ? 'Seance created.' : 'Seance updated.')
              : (response['message']?.toString() ?? 'Operation failed.'),
        ),
      ),
    );

    if (response['success'] == 1) {
      setState(() {
        _futureSeances = _loadSeances();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        title: const Text('Seances'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Seance',
            icon: const Icon(Icons.add),
            onPressed: () => _openSeanceForm(),
          ),
        ],
      ),
      body: FutureBuilder<List<SeanceAbsenceStats>>(
        future: _futureSeances,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Unable to load seances.',
                      style: ThemeTextStyles.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString(),
                      style: ThemeTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ThemeButtonStyles.secondary,
                      onPressed: () {
                        setState(() {
                          _futureSeances = _loadSeances();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final seances = snapshot.data ?? const <SeanceAbsenceStats>[];
          if (seances.isEmpty) {
            return Center(
              child: Text('No seances found.', style: ThemeTextStyles.bodyLarge),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: seances.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final seance = seances[index];
              final selectedSeance = Seance(
                id: seance.id,
                matiere: seance.subjectName,
                classe: seance.className,
                date: seance.date,
                heureDebut: seance.startTime,
                heureFin: seance.endTime,
              );

              return _SeanceAbsenceTile(
                seance: seance,
                onEdit: () => _openSeanceForm(existing: seance),
                onTap: () async {
                  final saved = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AppelScreen(
                        userId: 0,
                        name: 'Admin',
                        seance: selectedSeance,
                        showNavigation: false,
                      ),
                    ),
                  );

                  if (saved == true && mounted) {
                    setState(() {
                      _futureSeances = _loadSeances();
                    });
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  DateTime? _toDateTime(DateTime? date, String? time) {
    if (date == null || time == null || time.trim().isEmpty) return null;
    final parts = time.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}

class _SeanceAbsenceTile extends StatelessWidget {
  const _SeanceAbsenceTile({
    required this.seance,
    required this.onTap,
    required this.onEdit,
  });

  final SeanceAbsenceStats seance;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final percent = seance.absencePercent;
    final barColor = percent >= 50
        ? ThemeColors.errorRed
        : percent >= 25
            ? ThemeColors.tertiaryLight
            : ThemeColors.liveGreen;

    return Material(
      color: ThemeColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ThemeColors.borderSubtle, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${seance.title}  #${seance.id}',
                      style: ThemeTextStyles.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Teacher: ${seance.teacherName}',
                      style: ThemeTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Class: ${seance.className}',
                      style: ThemeTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Absences: ${seance.absentCount}/${seance.totalCount}',
                      style: ThemeTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap to manage attendance',
                      style: ThemeTextStyles.bodySmall.copyWith(
                        color: ThemeColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        style: ThemeButtonStyles.outlined,
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Seance'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$percent%',
                      style: ThemeTextStyles.statNumber.copyWith(color: barColor),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: percent / 100,
                        backgroundColor: ThemeColors.surfaceAlt,
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}