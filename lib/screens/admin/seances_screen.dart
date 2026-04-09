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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seances')),
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
  const _SeanceAbsenceTile({required this.seance, required this.onTap});

  final SeanceAbsenceStats seance;
  final VoidCallback onTap;

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