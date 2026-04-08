import 'package:flutter/material.dart';
import 'package:gestabsence/main.dart';
import 'package:gestabsence/models/seance.dart';
import 'package:gestabsence/screens/enseignant/appel_screen.dart';
import 'package:gestabsence/screens/enseignant/enseignant_home.dart';
import 'package:gestabsence/services/session_service.dart';
import 'package:gestabsence/themeapp.dart';

class MesSeancesScreen extends StatefulWidget {
  const MesSeancesScreen({super.key, required this.userId, required this.name});

  final int userId;
  final String name;

  @override
  State<MesSeancesScreen> createState() => _MesSeancesScreenState();
}

class _MesSeancesScreenState extends State<MesSeancesScreen> {
  int _currentIndex = 1;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
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
              Text('Mes Séances', style: ThemeTextStyles.headlineLarge),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Today, you have 3 sessions scheduled.',
                style: ThemeTextStyles.display,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 24),
              Text(
                DateTime.now().toLocal().toString().split(' ')[0],
                style: ThemeTextStyles.headlineMedium,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 24),
              _buildDateRangeSelector(),
              const SizedBox(height: 24),
              FutureBuilder<List<Seance>>(
                future: SessionService.getTeacherSessions(widget.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if(snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                        style: ThemeTextStyles.bodyMedium,
                      ),
                    );
                  } 
                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "No sessions found",
                        style: ThemeTextStyles.bodyMedium,
                      ),
                    );
                  }

                  final seancesForDate = snapshot.data!
                      .where(
                        (seance) =>
                            seance.date.year == _selectedDate.year &&
                            seance.date.month == _selectedDate.month &&
                            seance.date.day == _selectedDate.day,
                      )
                      .toList();

                  if (seancesForDate.isEmpty) {
                    return Center(
                      child: Text(
                        'No sessions for this date',
                        style: ThemeTextStyles.bodyMedium,
                      ),
                    );
                  }

                  return Column(
                    children: seancesForDate
                        .map((seance) => _buildSeanceCard(seance))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
                  builder: (_) =>
                      EnseignantHome(userId: widget.userId, name: widget.name),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AppelScreen(userId: widget.userId, name: widget.name),
                ),
              );
              break;
            default:
          }
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
  Widget _buildSeanceCard(Seance seance) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(seance.classe, style: ThemeTextStyles.cardTitle),
        subtitle: Text(
          '${seance.heureDebut} - ${seance.heureFin}',
          style: ThemeTextStyles.bodyMedium,
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16)
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    final today = DateTime.now();
    final dates = <DateTime>[];
    int offset = -1;
    while (dates.length < 5) {
      final date = today.add(Duration(days: offset));
      if (date.weekday != 7) {
        dates.add(date);
      }
      offset++;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: dates.map((date) {
          final isSelected =
              date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;

          final dayNames = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM'];
          final dayName = dayNames[date.weekday - 1];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? ThemeColors.primary
                    : ThemeColors.borderSubtle,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: ThemeTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? Colors.white
                          : ThemeColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${date.day}',
                    style: ThemeTextStyles.headlineLarge.copyWith(
                      color: isSelected
                          ? Colors.white
                          : ThemeColors.textPrimary,
                    ),
                  ),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
