import 'package:flutter/material.dart';
import 'package:gestabsence/main.dart';
import 'package:gestabsence/themeapp.dart';
import 'package:gestabsence/screens/enseignant/appel_screen.dart';
import 'package:gestabsence/screens/enseignant/mes_seances_screen.dart';
import 'package:gestabsence/services/session_service.dart';
import 'package:gestabsence/services/absence_service.dart';
import 'package:gestabsence/models/seance.dart';

class EnseignantHome extends StatefulWidget {
  const EnseignantHome({super.key, required this.userId, required this.name});
  final int userId;
  final String name;

  @override
  State<EnseignantHome> createState() => _EnseignantHomeState();
}

class _EnseignantHomeState extends State<EnseignantHome> {
  int _currentIndex = 0;
  late Future<List<Seance>> _futureTeacherSessions;

  @override
  void initState() {
    super.initState();
    _futureTeacherSessions = SessionService.getTeacherSessions(widget.userId);
  }

  Future<int> _getTotalStudents(List<Seance> sessions) async {
    if (sessions.isEmpty) return 0;
    Set<String> uniqueClasses = {};
    for (var seance in sessions) {
      if (seance.classe != null) {
        uniqueClasses.add(seance.classe!);
      }
    }
    return uniqueClasses.length * 30;
  }

  Future<double> _getAverageAttendance(List<Seance> sessions) async {
    if (sessions.isEmpty) return 0;
    
    double totalAttendance = 0;
    int count = 0;
    
    for (var seance in sessions) {
      if (seance.id != null) {
        final statuses = await AbsenceService.getSeanceAbsenceStatuses(seance.id!);
        if (statuses.isNotEmpty) {
          int presentCount = statuses.values.where((s) => s.toLowerCase() == 'present').length;
          double attendance = (presentCount / statuses.length) * 100;
          totalAttendance += attendance;
          count++;
        }
      }
    }
    
    return count > 0 ? totalAttendance / count : 0;
  }

  Seance? _getNextSession(List<Seance> sessions) {
    final now = DateTime.now();
    final upcoming = sessions.where((seance) {
      return seance.date != null && seance.date!.isAfter(now);
    }).toList();
    
    if (upcoming.isEmpty) return null;
    
    upcoming.sort((a, b) => a.date!.compareTo(b.date!));
    return upcoming.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 300,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              Text(["Dashboard","Sceances","Appel"][_currentIndex], style: ThemeTextStyles.headlineLarge),
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
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Seances",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            label: "Appel",
          ),
        ],
        backgroundColor: ThemeColors.borderSubtle,
        elevation: 0,
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard();
      case 1:

        return MesSeancesScreen(
          userId: widget.userId,
          name: widget.name,
        );
      case 2:
        return AppelScreen(
          userId: widget.userId,
          name: widget.name,
        );
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return FutureBuilder<List<Seance>>(
      future: _futureTeacherSessions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading dashboard',
              style: ThemeTextStyles.bodyMedium,
            ),
          );
        }

        final sessions = snapshot.data ?? [];

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome, Dr.${widget.name}',
                  style: ThemeTextStyles.headlineMedium,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 24),
                FutureBuilder<int>(
                  future: _getTotalStudents(sessions),
                  builder: (context, snapshot) {
                    final totalStudents = snapshot.data ?? 0;
                    return _buildStatCard(
                      title: 'Total étudiants',
                      value: totalStudents.toString(),
                      height: 150,
                    );
                  },
                ),
                const SizedBox(height: 16),
                FutureBuilder<double>(
                  future: _getAverageAttendance(sessions),
                  builder: (context, snapshot) {
                    final avgAttendance = snapshot.data ?? 0;
                    return _buildStatCard(
                      title: 'Présence Moy',
                      value: '${avgAttendance.toStringAsFixed(1)}%',
                      height: 150,
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildNextSessionCard(sessions),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextSessionCard(List<Seance> sessions) {
    final nextSession = _getNextSession(sessions);
    
    if (nextSession == null) {
      return _buildStatCard(
        title: 'Prochaine séance',
        value: 'Aucune séance prévue',
        height: 150,
      );
    }

    final sessionTime = nextSession.heureDebut ?? 'N/A';
    final sessionClass = nextSession.classe ?? 'N/A';
    final sessionSubject = nextSession.matiere ?? 'N/A';
    
    return _buildStatCard(
      title: 'Prochaine séance',
      value: '$sessionSubject - $sessionTime, $sessionClass',
      subtitle: nextSession.date != null
          ? 'Le ${nextSession.date!.day}/${nextSession.date!.month}/${nextSession.date!.year}'
          : 'Date non disponible',
      height: 170,
    );
  }


  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtitle,
    double height = 150,
  }) {
    return SizedBox(
      height: height,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: ThemeTextStyles.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  value,
                  style: ThemeTextStyles.statNumber,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 10),
                Flexible(
                  child: Text(
                    subtitle,
                    style: ThemeTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
