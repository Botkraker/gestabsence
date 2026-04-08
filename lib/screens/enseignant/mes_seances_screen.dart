import 'dart:ffi';

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
                        'No sessions found',
                        style: ThemeTextStyles.bodyMedium,
                      ),
                    );
                  }

                  final seancesForDate = snapshot.data!
                      .where(
                        (seance) =>
                            seance.date?.year == _selectedDate.year &&
                            seance.date?.month == _selectedDate.month &&
                            seance.date?.day == _selectedDate.day,
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
    final isOngoing = _isSeanceOngoing(seance);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isOngoing ? ThemeColors.primary : Colors.grey[400]!,
              width: 4,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge and time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOngoing
                        ? ThemeColors.primary.withOpacity(0.2)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isOngoing ? 'EN COURS' : 'À VENIR',
                    style: ThemeTextStyles.bodySmall.copyWith(
                      color: isOngoing ? ThemeColors.primary : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${seance.heureDebut} — ${seance.heureFin}',
                  style: ThemeTextStyles.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Course title
            Text(
              seance.matiere ?? 'Not found',
              style: ThemeTextStyles.headlineLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Class and location info
            Row(
              children: [
                Icon(Icons.people, size: 18, color: ThemeColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  seance.classe ?? 'Not found',
                  style: ThemeTextStyles.bodyMedium.copyWith(
                    color: ThemeColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            isOngoing?
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AppelScreen(
                        userId: widget.userId,
                        name: widget.name,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Faire l\'appel',
                  style: ThemeTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ):Container(),
          ],
        ),
      ),
    );
  }
  
  bool _isSeanceOngoing(Seance seance) {
    if (seance.heureDebut == null || seance.heureFin == null) return false;
    
    final now = TimeOfDay.now();
    final startTime = _parseTime(seance.heureDebut!);
    final endTime = _parseTime(seance.heureFin!);
    
    return now.hour > startTime.hour ||
        (now.hour == startTime.hour && now.minute >= startTime.minute) &&
        (now.hour < endTime.hour ||
            (now.hour == endTime.hour && now.minute < endTime.minute));
  }
  
  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
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
