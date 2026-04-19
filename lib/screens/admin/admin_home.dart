import 'package:flutter/material.dart';
import 'package:gestabsence/main.dart';
import 'package:gestabsence/screens/admin/classes_screen.dart';
import 'package:gestabsence/screens/admin/enseignants_screen.dart';
import 'package:gestabsence/screens/admin/etudiants_screen.dart';
import 'package:gestabsence/models/seance.dart';
import 'package:gestabsence/screens/admin/seances_screen.dart';
import 'package:gestabsence/services/class_service.dart';
import 'package:gestabsence/services/session_service.dart';
import 'package:gestabsence/themeapp.dart';
import 'package:intl/intl.dart';

/// Main admin dashboard that aggregates quick navigation and live session overview.
class AdminHome extends StatefulWidget {
  const AdminHome({super.key, required this.name});

  final String name;

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late Future<List<Seance>> _seancesFuture;

  @override
  void initState() {
    super.initState();
    // Fetch all seances once and reuse via FutureBuilder.
    _seancesFuture = SessionService.getAllSessions();
  }

  void _reloadSeances() {
    setState(() {
      _seancesFuture = SessionService.getAllSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 250,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              Text("Admin Home", style: ThemeTextStyles.headlineLarge),
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
        ],),
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
                          MaterialPageRoute(builder: (_) => const EnseignantsScreen()),
                        ),
                      ),
                      _buildManageBox(
                        title: 'Classes',
                        description: 'Manage classes, levels, and linked entities.',
                        icon: Icons.class_outlined,
                        actionText: 'Manage Classes',
                        onAction: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ClassesScreen()),
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
                  builder: (_) => const EtudiantsScreen(),
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

  Widget _buildManageSeancesIconButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        tooltip: 'Manage Seances',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SeancesScreen()),
          );
          if (!mounted) return;
          _reloadSeances();
        },
        icon: const Icon(Icons.calendar_month_outlined),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildManageSeancesIconButton(),
                const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
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
                _buildManageSeancesIconButton(),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildManageSeancesIconButton(),
                Text(
                  'No seances available.',
                  style: ThemeTextStyles.bodyLarge,
                ),
              ],
            ),
          );
        }

        final sortedSeances = _sortSeances(seances);

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
              _buildManageSeancesIconButton(),
              SizedBox(
                height: 340,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: sortedSeances.length,
                  separatorBuilder: (_, index) => const Divider(height: 20),
                  itemBuilder: (context, index) {
                    return _buildSeanceTile(sortedSeances[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeanceTile(Seance seance) {
    // gets the matiere name from seances and class name and joins them together 
    final matiere = (seance.matiere ?? '').trim();
    final classe = (seance.classe ?? '').trim();
    final title = [matiere, classe].where((part) => part.isNotEmpty).join(' - ');
// what is inkwell , just a clickable box : https://api.flutter.dev/flutter/material/InkWell-class.html
    return InkWell(
      // we click it we change to seances screen
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SeancesScreen()),
        );
        if (!mounted) return;
        _reloadSeances();
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
          ],
        ),
      ),
    );
  }












// sort seances by date and time to view them in listview
  List<Seance> _sortSeances(List<Seance> seances) {
    final copy = List<Seance>.from(seances);
    //sort whole list by date and time of seance, if date is null put it at the end of the list
    copy.sort((a, b) {
      // convert date and time to DateTime for accurate comparison
      final startA = _toDateTime(a.date, a.heureDebut);
      final startB = _toDateTime(b.date, b.heureDebut);
    // if both are null consider them equal, if one is null put it at the end of the list
      if (startA == null && startB == null) return 0;
      // if startA is null it should come after startB, if startB is null it should come after startA
      if (startA == null) return 1;
      // if startB is null it should come after startA
      if (startB == null) return -1;
      // both are not null, compare them normally
      return startA.compareTo(startB);
    });
    return copy;
  }

// helper to convert date and time strings to DateTime, returns null if either is invalid or missing
  DateTime? _toDateTime(DateTime? date, String? time) {
    // if either date or time is null or empty, return null
    if (date == null || time == null || time.trim().isEmpty) return null;
// split time into hours and minutes
    final parts = time.split(':');
    // if time does not have at least hours and minutes, return null
    if (parts.length < 2) return null;
// parse hours and minutes, if either is invalid return null
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  // function to better visually formate date source https://api.flutter.dev/flutter/package-intl_intl/DateFormat-class.html
  String _formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }
//format time
  String _formatTime(String? value) {
//if null return --:-- 
    if (value == null || value.trim().isEmpty) return '--:--';
// this will only keep hours and minutes 
    final parts = value.split(':');
    if (parts.length < 2) return '--:--';
// pad hours and minutes with leading zeros if needed
    final hour = parts[0].padLeft(2, '0');
    final minute = parts[1].padLeft(2, '0');
    return '$hour:$minute';
  }
// returns the needed format for time 
  String _formatSeanceTime(Seance seance) {
    return '${_formatTime(seance.heureDebut)} - ${_formatTime(seance.heureFin)}';
  }
}
