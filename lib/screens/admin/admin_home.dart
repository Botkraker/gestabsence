import 'package:flutter/material.dart';
import 'package:gestabsence/screens/admin/manage_students_screen.dart';
import 'package:gestabsence/models/seance.dart';
import 'package:gestabsence/screens/admin/professors_screen.dart';
import 'package:gestabsence/screens/admin/seances_screen.dart';
import 'package:gestabsence/screens/admin/students_screen.dart';
import 'package:gestabsence/services/class_service.dart';
import 'package:gestabsence/services/session_service.dart';
import 'package:gestabsence/themeapp.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key, required this.name});

  final String name;

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  static const int _initialVisibleCount = 3;
  static const int _loadStep = 3;

  late Future<List<Seance>> _seancesFuture;
  int _visibleSeanceCount = _initialVisibleCount;

  @override
  void initState() {
    super.initState();
    _seancesFuture = SessionService.getAllSessions();
  }

  void _loadMore(int totalCount) {
    setState(() {
      _visibleSeanceCount = (_visibleSeanceCount + _loadStep).clamp(
        _initialVisibleCount,
        totalCount,
      );
    });
  }

  void _reloadSeances() {
    setState(() {
      _visibleSeanceCount = _initialVisibleCount;
      _seancesFuture = SessionService.getAllSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Home')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Academic Year: ${DateTime.now().year - 1} - ${DateTime.now().year}',
                  style: ThemeTextStyles.headlineLarge.copyWith(
                    color: ThemeColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bizerte Science Faculty',
                  style: ThemeTextStyles.display.copyWith(fontSize: 38),
                ),
                Text(
                  'Faculty Dashboard',
                  style: ThemeTextStyles.display.copyWith(
                    fontSize: 38,
                    color: ThemeColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                FutureBuilder<Map<String, dynamic>>(
                  future: ClassService.getAdminStats(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        width: double.infinity,
                        height: 130,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError || snapshot.data == null) {
                      return _buildStatsBox(totalStudents: 0, hasError: true);
                    }

                    final response = snapshot.data!;
                    final data = response['data'] is Map<String, dynamic>
                        ? response['data'] as Map<String, dynamic>
                        : <String, dynamic>{};

                    final totalStudents =
                        int.tryParse(data['total_students']?.toString() ?? '0') ?? 0;

                    return _buildStatsBox(totalStudents: totalStudents);
                  },
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 900;
                    final boxes = [
                      _buildManageBox(
                        title: 'Enseignants',
                        description: 'Manage teacher accounts and assignment data.',
                        icon: Icons.badge_outlined,
                        actionText: 'Manage Enseignants',
                        onAction: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfessorsScreen()),
                        ),
                      ),
                      _buildManageBox(
                        title: 'Classes',
                        description: 'Manage classes, levels, and linked entities.',
                        icon: Icons.class_outlined,
                        actionText: 'Manage Classes',
                        onAction: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StudentsScreen()),
                        ),
                      ),
                    ];

                    if (isNarrow) {
                      return Column(
                        children: [
                          boxes[0],
                          const SizedBox(height: 16),
                          boxes[1],
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: boxes[0]),
                        const SizedBox(width: 16),
                        Expanded(child: boxes[1]),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildQuickActionsSection(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      color: ThemeColors.textPrimary,
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Text('Seances', style: ThemeTextStyles.headlineLarge),
                  ],
                ),
                const SizedBox(height: 10),
                _buildSeancesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBox({
    required int totalStudents,
    bool hasError = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.borderSubtle, width: 1),
      ),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people, size: 32, color: ThemeColors.primary),
              const SizedBox(width: 8),
              Text(
                'Population',
                style: ThemeTextStyles.statNumber.copyWith(
                  color: ThemeColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            hasError
                ? 'Unable to load database stats'
                : '$totalStudents students enrolled across all departments.',
            textAlign: TextAlign.left,
            style: ThemeTextStyles.bodyLarge,
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ThemeButtonStyles.secondary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageStudentsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.groups_outlined),
            label: const Text('Manage Students'),
          ),
        ],
      ),
    );
  }

  Widget _buildManageBox({
    required String title,
    required String description,
    required IconData icon,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: ThemeColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: ThemeColors.primary),
              ),
              const SizedBox(width: 10),
              Text(title, style: ThemeTextStyles.cardTitle),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: ThemeTextStyles.bodyMedium),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ThemeButtonStyles.secondary,
            onPressed: onAction,
            icon: const Icon(Icons.settings_outlined),
            label: Text(actionText),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on_outlined, color: ThemeColors.primary),
              const SizedBox(width: 8),
              Text('CI2 Quick Actions', style: ThemeTextStyles.cardTitle),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                style: ThemeButtonStyles.secondary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SeancesScreen()),
                  );
                },
                icon: const Icon(Icons.event_note_outlined),
                label: const Text('View Seances'),
              ),
              ElevatedButton.icon(
                style: ThemeButtonStyles.secondary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentsScreen(
                        initialAction: StudentsScreenAction.assignClass,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.group_work_outlined),
                label: const Text('Assign Class'),
              ),
              OutlinedButton.icon(
                style: ThemeButtonStyles.outlined,
                onPressed: () {},
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Manage Absences'),
              ),
              OutlinedButton.icon(
                style: ThemeButtonStyles.outlined,
                onPressed: () {},
                icon: const Icon(Icons.download_outlined),
                label: const Text('Export Report'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeancesSection() {
    return FutureBuilder<List<Seance>>(
      future: _seancesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ThemeColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ThemeColors.borderSubtle, width: 1),
            ),
            height: 180,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ThemeColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ThemeColors.borderSubtle, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unable to load seances from server.',
                  style: ThemeTextStyles.bodyLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  snapshot.error.toString(),
                  style: ThemeTextStyles.bodySmall,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ThemeButtonStyles.secondary,
                  onPressed: _reloadSeances,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final seances = snapshot.data ?? const <Seance>[];
        if (seances.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ThemeColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ThemeColors.borderSubtle, width: 1),
            ),
            child: Text(
              'No seances available.',
              style: ThemeTextStyles.bodyLarge,
            ),
          );
        }

        final sortedSeances = _sortSeances(seances);
        final visibleCount = _visibleSeanceCount.clamp(0, sortedSeances.length);
        final visibleSeances = sortedSeances.take(visibleCount).toList();
        final hasMore = visibleCount < sortedSeances.length;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ThemeColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ThemeColors.borderSubtle, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 340,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: visibleSeances.length,
                  separatorBuilder: (_, index) => const Divider(height: 20),
                  itemBuilder: (context, index) {
                    return _buildSeanceTile(visibleSeances[index]);
                  },
                ),
              ),
              if (hasMore) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: OutlinedButton.icon(
                    style: ThemeButtonStyles.outlined,
                    onPressed: () => _loadMore(sortedSeances.length),
                    icon: const Icon(Icons.expand_more),
                    label: Text(
                      'View More (${sortedSeances.length - visibleCount} remaining)',
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeanceTile(Seance seance) {
    final status = _computeStatus(seance);
    final color = status == 'active'
        ? ThemeColors.liveGreen
        : status == 'upcoming'
            ? ThemeColors.primary
            : ThemeColors.textSecondary;

    final matiere = (seance.matiere ?? '').trim();
    final classe = (seance.classe ?? '').trim();
    final title = [matiere, classe].where((part) => part.isNotEmpty).join(' - ');

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SeancesScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/logo.webp',
                width: 66,
                height: 66,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stackTrace) => Container(
                  width: 66,
                  height: 66,
                  color: ThemeColors.surfaceAlt,
                  child: const Icon(Icons.image, color: ThemeColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty ? 'Untitled Seance' : title,
                    style: ThemeTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Professor: ${seance.enseignantFullName}',
                    style: ThemeTextStyles.bodyMedium,
                  ),
                  Text(
                    'Time: ${_formatSeanceTime(seance)}',
                    style: ThemeTextStyles.bodyMedium,
                  ),
                  if (seance.date != null)
                    Text(
                      'Date: ${_formatDate(seance.date!)}',
                      style: ThemeTextStyles.bodySmall,
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: color),
              ),
              child: Text(
                status,
                style: ThemeTextStyles.labelLarge.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _computeStatus(Seance seance) {
    final start = _toDateTime(seance.date, seance.heureDebut);
    final end = _toDateTime(seance.date, seance.heureFin);

    if (start == null || end == null) return 'upcoming';

    final now = DateTime.now();
    if (now.isAfter(end)) return 'finished';
    if (now.isBefore(start)) return 'upcoming';
    return 'active';
  }

  List<Seance> _sortSeances(List<Seance> seances) {
    final copy = List<Seance>.from(seances);
    copy.sort((a, b) {
      final statusA = _computeStatus(a);
      final statusB = _computeStatus(b);

      final rankDiff = _statusRank(statusA).compareTo(_statusRank(statusB));
      if (rankDiff != 0) return rankDiff;

      final startA = _toDateTime(a.date, a.heureDebut);
      final startB = _toDateTime(b.date, b.heureDebut);
      final endA = _toDateTime(a.date, a.heureFin);
      final endB = _toDateTime(b.date, b.heureFin);

      if (statusA == 'finished') {
        if (endA == null && endB == null) return 0;
        if (endA == null) return 1;
        if (endB == null) return -1;
        return endB.compareTo(endA);
      }

      if (startA == null && startB == null) return 0;
      if (startA == null) return 1;
      if (startB == null) return -1;
      return startA.compareTo(startB);
    });
    return copy;
  }

  int _statusRank(String status) {
    switch (status) {
      case 'active':
        return 0;
      case 'upcoming':
        return 1;
      case 'finished':
        return 2;
      default:
        return 3;
    }
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

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatTime(String? value) {
    if (value == null || value.trim().isEmpty) return '--:--';

    final parts = value.split(':');
    if (parts.length < 2) return '--:--';

    final hour = parts[0].padLeft(2, '0');
    final minute = parts[1].padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatSeanceTime(Seance seance) {
    return '${_formatTime(seance.heureDebut)} - ${_formatTime(seance.heureFin)}';
  }
}
