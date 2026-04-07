import 'package:flutter/material.dart';
import 'package:gestabsence/services/api_service.dart';
import 'package:gestabsence/themeapp.dart';

class AdminHome extends StatelessWidget {
	const AdminHome({super.key, required this.name});

	final String name;

	@override
	Widget build(BuildContext context) {
    final seances = _buildDemoSeances();

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
                  "Academic Year: ${DateTime.now().year - 1} - ${DateTime.now().year}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Bizerte Science Faculty",
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.textPrimary,
                  ),
                ),
                const Text(
                  "Faculty Dashboard",
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                FutureBuilder<Map<String, dynamic>>(
                  future: ApiService.getAdminStudentStats(),
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
                    if (isNarrow) {
                      return Column(
                        children: [
                          _buildManageBox(
                            title: 'Enseignants',
                            description: 'Manage teacher accounts and assignment data.',
                            primaryText: 'Manage Enseignants',
                            secondaryText: 'Add Enseignant',
                          ),
                          const SizedBox(height: 16),
                          _buildManageBox(
                            title: 'Classes',
                            description: 'Manage classes, levels, and linked entities.',
                            primaryText: 'Manage Classes',
                            secondaryText: 'Add Class',
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _buildManageBox(
                            title: 'Enseignants',
                            description: 'Manage teacher accounts and assignment data.',
                            primaryText: 'Manage Enseignants',
                            secondaryText: 'Add Enseignant',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildManageBox(
                            title: 'Classes',
                            description: 'Manage classes, levels, and linked entities.',
                            primaryText: 'Manage Classes',
                            secondaryText: 'Add Class',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildQuickActionsSection(),
                const SizedBox(height: 20),
                const Text(
                  'Seances',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ThemeColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ThemeColors.borderSubtle,
                      width: 1,
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: seances.length,
                    separatorBuilder: (_, __) => const Divider(height: 20),
                    itemBuilder: (context, index) {
                      return _buildSeanceTile(seances[index]);
                    },
                  ),
                ),
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
          const Row(
            children: [
              Icon(Icons.people, size: 32, color: ThemeColors.primary),
              SizedBox(width: 8),
              Text(
                'Population',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
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
            style: const TextStyle(fontSize: 16, color: ThemeColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildManageBox({
    required String title,
    required String description,
    required String primaryText,
    required String secondaryText,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: ThemeColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton(onPressed: () {}, child: Text(primaryText)),
              OutlinedButton(onPressed: () {}, child: Text(secondaryText)),
            ],
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
          const Text(
            'CI2 Quick Actions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ThemeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('Create Seance')),
              ElevatedButton(onPressed: () {}, child: const Text('Assign Class')),
              OutlinedButton(onPressed: () {}, child: const Text('Manage Absences')),
              OutlinedButton(onPressed: () {}, child: const Text('Export Report')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeanceTile(_SeanceItem seance) {
    final status = _computeStatus(seance.start, seance.end);
    final color = status == 'active'
        ? ThemeColors.liveGreen
        : status == 'upcoming'
            ? ThemeColors.primary
            : ThemeColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/logo.webp',
            width: 66,
            height: 66,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
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
                seance.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Professor: ${seance.professor}',
                style: const TextStyle(color: ThemeColors.textSecondary),
              ),
              Text(
                'Time: ${_formatTime(seance.start)} - ${_formatTime(seance.end)}',
                style: const TextStyle(color: ThemeColors.textSecondary),
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
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  List<_SeanceItem> _buildDemoSeances() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      _SeanceItem(
        title: 'Mobile Development - CI2-A',
        professor: 'Sami Ben Ali',
        start: today.subtract(const Duration(hours: 2)),
        end: today.subtract(const Duration(hours: 1)),
      ),
      _SeanceItem(
        title: 'Networks - CI2-B',
        professor: 'Nadia Trabelsi',
        start: now.subtract(const Duration(minutes: 30)),
        end: now.add(const Duration(minutes: 30)),
      ),
      _SeanceItem(
        title: 'Databases - CI2-A',
        professor: 'Youssef Ayedi',
        start: now.add(const Duration(hours: 2)),
        end: now.add(const Duration(hours: 3, minutes: 30)),
      ),
    ];
  }

  String _computeStatus(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (now.isAfter(end)) return 'finished';
    if (now.isBefore(start)) return 'upcoming';
    return 'active';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _SeanceItem {
  const _SeanceItem({
    required this.title,
    required this.professor,
    required this.start,
    required this.end,
  });

  final String title;
  final String professor;
  final DateTime start;
  final DateTime end;
}
