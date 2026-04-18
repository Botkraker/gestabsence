import 'package:flutter/material.dart';
import 'package:gestabsence/models/seance.dart';
import 'package:gestabsence/models/seance_absence_stats.dart';
import 'package:gestabsence/models/utilisateur.dart';
import 'package:gestabsence/screens/enseignant/appel_screen.dart';
import 'package:gestabsence/services/api_service.dart';
import 'package:gestabsence/services/class_service.dart';
import 'package:gestabsence/services/matiere_service.dart';
import 'package:gestabsence/services/session_service.dart';
import 'package:gestabsence/services/teacher_service.dart';
import 'package:gestabsence/themeapp.dart';

/// Admin screen that centralizes seance lifecycle operations:
/// - list existing seances with absence metrics,
/// - create/edit a seance,
/// - open attendance call for a selected seance.
class SeancesScreen extends StatefulWidget {
  const SeancesScreen({super.key});

  @override
  State<SeancesScreen> createState() => _SeancesScreenState();
}

class _SeancesScreenState extends State<SeancesScreen> {
  // Future used by FutureBuilder. Reassigned after successful create/edit/retry.
  late Future<List<SeanceAbsenceStats>> _futureSeances;

  @override
  void initState() {
    super.initState();
    // Load once at startup; subsequent reloads replace this future in setState.
    _futureSeances = _loadSeances();
  }

  Future<List<SeanceAbsenceStats>> _loadSeances() async {
    // Backend endpoint returns list with aggregate absence stats per seance.
    final response = await ApiService.get('/admin/seances.php');
    if (response['success'] == 1 && response['data'] is List) {
      // Defensive conversion: keep only valid map rows.
      final items = (response['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(SeanceAbsenceStats.fromJson)
          .toList();
      // Keep sessions chronologically ordered for predictable list behavior.
      items.sort((a, b) {
        final startA = _toDateTime(a.date, a.startTime);
        final startB = _toDateTime(b.date, b.startTime);

        if (startA == null && startB == null) return a.id.compareTo(b.id);
        if (startA == null) return 1;
        if (startB == null) return -1;
        return startA.compareTo(startB);
      });

      // Sorted data is returned and rendered as-is in the list view.
      return items;
    }

    // Throwing here lets FutureBuilder switch to the error UI state.
    throw Exception(response['message']?.toString() ?? 'Failed to load seances');
  }

  Future<void> _openSeanceForm({SeanceAbsenceStats? existing}) async {
    // Resolve select options first; the form depends on these entities.
    // If one list is missing, form creation would not be valid.
    final teachersRaw = await TeacherService.getAllTeachers();
    final classesRaw = await ClassService.getAllClasses();
    final matieresRaw = await MatiereService.getAllMatieres();

    // Normalize teacher rows to strongly-typed tuples for Dropdown widgets.
    final teachers = teachersRaw
        .map((t) {
          final id = t.id;
          if (id == null) return null;
          final name = '${t.nom ?? ''} ${t.prenom ?? ''}'.trim();
          return (id: id, name: name.isEmpty ? 'Teacher #$id' : name);
        })
        .whereType<({int id, String name})>()
        .toList();

      // Normalize class rows to minimal (id, name) tuple format.
    final classes = classesRaw
        .map((c) {
          final id = int.tryParse(c['id']?.toString() ?? '');
          if (id == null) return null;
          return (id: id, name: c['nom']?.toString() ?? 'Class #$id');
        })
        .whereType<({int id, String name})>()
        .toList();

      // Normalize subject (matiere) rows to minimal (id, name) tuple format.
    final matieres = matieresRaw
        .map((m) {
          final id = int.tryParse(m['id']?.toString() ?? '');
          if (id == null) return null;
          return (id: id, name: m['nom']?.toString() ?? 'Matiere #$id');
        })
        .whereType<({int id, String name})>()
        .toList();

    if (!mounted) return;

    // Guard: cannot create/edit a seance unless all reference entities exist.
    if (teachers.isEmpty || classes.isEmpty || matieres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create teachers, classes, and matieres first.'),
        ),
      );
      return;
    }

    // Mutable local state for dialog controls.
    int? selectedTeacherId;
    int? selectedClassId;
    int? selectedMatiereId;

    // Controllers keep input values alive while dialog rebuilds.
    final dateController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();

    if (existing != null) {
      // Fetch full record before editing to prefill all fields.
      // Stats list row is not always enough for all editable columns.
      final response = await ApiService.get('/admin/seances.php?id=${existing.id}');
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : <String, dynamic>{};
      selectedTeacherId = int.tryParse(data['enseignant_id']?.toString() ?? '');
      selectedClassId = int.tryParse(data['classe_id']?.toString() ?? '');
      selectedMatiereId = int.tryParse(data['matiere_id']?.toString() ?? '');
      dateController.text = data['date_seance']?.toString() ?? '';
      startController.text = data['heure_debut']?.toString() ?? '';
      endController.text = data['heure_fin']?.toString() ?? '';
    }

    // Fallback defaults when creating or when some edit fields are missing.
    // This ensures all dropdowns and text fields have usable initial values.
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
        // StatefulBuilder gives local setState for dialog-only controls.
        // This avoids touching the parent screen state for every field change.
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
                    // Teacher selection.
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
                        // Class selection.
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
                        // Matiere selection.
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
                        // Date format expected by backend endpoint.
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                        // Start time format expected by backend endpoint.
                          selectedMatiereId = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Matiere'),
                    ),
                        // End time format expected by backend endpoint.
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
      // User cancelled dialog or required selection is missing.
      return;
    }

    // POST creates a new session; PUT updates the selected one.
    final response = existing == null
        ? await SessionService.createSession(
            enseignantId: selectedTeacherId!,
            classeId: selectedClassId!,
            matiereId: selectedMatiereId!,
            dateSeance: dateController.text.trim(),
            heureDebut: startController.text.trim(),
            heureFin: endController.text.trim(),
          )
        : await SessionService.updateSession(
            sessionId: existing.id,
            enseignantId: selectedTeacherId!,
            classeId: selectedClassId!,
            matiereId: selectedMatiereId!,
            dateSeance: dateController.text.trim(),
            heureDebut: startController.text.trim(),
            heureFin: endController.text.trim(),
          );

    if (!mounted) return;

    // Centralized success/error toast feedback for user action confirmation.
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
      // Refresh list so the latest create/edit is immediately visible.
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
          // Loading state while future resolves.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state with retry pathway.
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
                        // Re-run fetch pipeline on demand.
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

          // Data state.
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

              // Convert list item model to AppelScreen model contract.
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
                  // Open attendance call screen in admin mode.
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
                    // Attendance changes may alter absence stats; reload list.
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

  // Combines date + hh:mm(:ss) into DateTime for sorting/comparison.
  // Returns null for malformed or incomplete inputs.
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
    // Visual severity color based on absence percentage thresholds.
    // >=50% high (red), >=25% medium (warning), else healthy (green).
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
                    // Seance title line with id for easy admin traceability.
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
                        // Edit keeps user in same screen and refreshes on save.
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
                    // Numeric metric plus progress bar for quick visual scanning.
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