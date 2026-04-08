import 'package:flutter/material.dart';
import 'package:gestabsence/main.dart';
import 'package:gestabsence/themeapp.dart';
import 'package:gestabsence/screens/enseignant/appel_screen.dart';
import 'package:gestabsence/screens/enseignant/mes_seances_screen.dart';

class EnseignantHome extends StatefulWidget {
  const EnseignantHome({super.key, required this.userId, required this.name});
  final int userId;
  final String name;

  @override
  State<EnseignantHome> createState() => _EnseignantHomeState();
}

class _EnseignantHomeState extends State<EnseignantHome> {
  int _currentIndex = 0;

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
              Text('DASHBOARD', style: ThemeTextStyles.headlineLarge),
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
              _buildStatCard(
                title: 'Total étudiants',
                value: '124',
                height: 150,
              ),
              const SizedBox(height: 16),
              _buildStatCard(title: 'Présence Moy', value: '85%', height: 150),
              const SizedBox(height: 16),
              _buildStatCard(
                title: 'Prochaine séance',
                value: 'Math 101 - 08:30, Salle B2',
                subtitle: 'La séance la plus proche est dans 45 minutes.',
                height: 170,
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
              Text(title, style: ThemeTextStyles.bodyLarge),
              const SizedBox(height: 12),
              Text(value, style: ThemeTextStyles.statNumber),
              if (subtitle != null) ...[
                const SizedBox(height: 10),
                Text(subtitle, style: ThemeTextStyles.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
