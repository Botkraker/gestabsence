import 'package:flutter/material.dart';
import 'package:gestabsence/main.dart';
import 'package:gestabsence/models/etudiant.dart';
import 'package:gestabsence/models/seance.dart';
import 'package:gestabsence/screens/enseignant/enseignant_home.dart';
import 'package:gestabsence/screens/enseignant/mes_seances_screen.dart';
import 'package:gestabsence/services/absence_service.dart';
import 'package:gestabsence/services/student_service.dart';
import 'package:gestabsence/themeapp.dart';

class AppelScreen extends StatefulWidget {
  const AppelScreen({
    super.key,
    required this.userId,
    required this.name,
    this.seance,
    this.showNavigation = true,
  });

  final int userId;
  final String name;
  final Seance? seance;
  final bool showNavigation;

  @override
  State<AppelScreen> createState() => _AppelScreenState();
}

class _AppelScreenState extends State<AppelScreen> {
  int _currentIndex = 2;
  late Future<List<Etudiant>> _studentsFuture;
  final Map<int, bool> _presenceByStudentId = <int, bool>{};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _loadStudentsForSelectedSeance();
  }

  Future<List<Etudiant>> _loadStudentsForSelectedSeance() async {
    if (widget.seance == null) {
      return const <Etudiant>[];
    }

    final students = await StudentService.getAllStudents();
    final seanceClass = (widget.seance!.classe ?? '').trim().toLowerCase();
    final savedStatuses = await AbsenceService.getSeanceAbsenceStatuses(widget.seance!.id ?? 0);

    final filtered = students.where((student) {
      final studentClass = (student.classe ?? '').trim().toLowerCase();
      return seanceClass.isNotEmpty && studentClass == seanceClass;
    }).toList();

    final resolvedStudents = filtered.isEmpty ? students : filtered;

    for (final student in resolvedStudents) {
      final savedStatus = savedStatuses[student.id];
      _presenceByStudentId[student.id] = savedStatus == null
          ? true
          : savedStatus.toLowerCase() != 'absent';
    }

    return resolvedStudents;
  }

  Future<void> _saveAttendance() async {
    final seanceId = widget.seance?.id;
    if (seanceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid seance id.')),
      );
      return;
    }

    if (_presenceByStudentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No students found for this seance.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final payload = _presenceByStudentId.entries
        .map(
          (entry) => <dynamic>[
            entry.key,
            entry.value ? 'present' : 'absent',
          ],
        )
        .toList();

    final response = await AbsenceService.recordAbsences(
      seanceId: seanceId,
      listAbsence: payload,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    final success = response['success'] == 1;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Attendance saved successfully.'
              : (response['message']?.toString() ?? 'Failed to save attendance.'),
        ),
      ),
    );

    if (success && !widget.showNavigation) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 160,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 25),
              Text('Appel', style: ThemeTextStyles.headlineLarge),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.logout_outlined, size: 28),
              color: ThemeColors.textSecondary,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MyApp()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: widget.seance == null
            ? _buildNoSeanceSelected()
            : _buildAttendanceForSeance(),
      ),
      bottomNavigationBar: widget.showNavigation
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                switch (index) {
                  case 0:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EnseignantHome(
                          userId: widget.userId,
                          name: widget.name,
                        ),
                      ),
                    );
                    break;
                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MesSeancesScreen(
                          userId: widget.userId,
                          name: widget.name,
                        ),
                      ),
                    );
                    break;
                  default:
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: 'Seances',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.fact_check_outlined),
                  label: 'Appel',
                ),
              ],
              backgroundColor: ThemeColors.borderSubtle,
              elevation: 0,
            )
          : null,
    );
  }

  Widget _buildNoSeanceSelected() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select a seance first',
          style: ThemeTextStyles.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          'Open attendance from Mes Seances to mark students as present or absent for a specific seance.',
          style: ThemeTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildAttendanceForSeance() {
    final seance = widget.seance!;
    return FutureBuilder<List<Etudiant>>(
      future: _studentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
              style: ThemeTextStyles.bodyMedium,
            ),
          );
        }

        final students = snapshot.data ?? const <Etudiant>[];

        if (students.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSeanceHeader(seance),
              const SizedBox(height: 20),
              Text(
                'No students found for class ${seance.classe ?? 'N/A'}.',
                style: ThemeTextStyles.bodyMedium,
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSeanceHeader(seance),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: students.length,
                separatorBuilder: (_, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final student = students[index];
                  final isPresent = _presenceByStudentId[student.id] ?? true;

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: ThemeColors.primary.withValues(alpha: 0.12),
                        child: Icon(
                          Icons.person,
                          color: ThemeColors.primary,
                        ),
                      ),
                      title: Text(
                        '${student.utilisateur.prenom} ${student.utilisateur.nom}',
                        style: ThemeTextStyles.bodyLarge,
                      ),
                      subtitle: Text(
                        isPresent ? 'present' : 'absent',
                        style: ThemeTextStyles.bodySmall.copyWith(
                          color: isPresent ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                      trailing: Switch(
                        value: isPresent,
                        onChanged: (value) {
                          setState(() {
                            _presenceByStudentId[student.id] = value;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveAttendance,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Saving...' : 'Save Attendance'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSeanceHeader(Seance seance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              seance.matiere ?? 'Unknown subject',
              style: ThemeTextStyles.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Class: ${seance.classe ?? 'N/A'}',
              style: ThemeTextStyles.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Time: ${seance.heureDebut ?? '--:--'} - ${seance.heureFin ?? '--:--'}',
              style: ThemeTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

 
}