import 'package:flutter/material.dart';
import 'package:gestabsence/themeapp.dart';


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
                icon: Icon(Icons.arrow_back),
              ),
              // Avatar
              const SizedBox(width: 25),
              // App name
              Text('DASHBOARD', style: ThemeTextStyles.headlineSmall),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.notifications, size: 28),
              color: ThemeColors.textSecondary,
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              widget.name.isEmpty
                  ? 'Welcome, Enseignant (ID: ${widget.userId})'
                  : 'Welcome, ${widget.name} (ID: ${widget.userId})',
              style: const TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
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
              print("Dashboard clicked");
              break;
            case 1:
              print("Seances clicked");
              break;
            case 2:
              print("Appel clicked");
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
        ],backgroundColor: ThemeColors.borderSubtle,elevation: 0,
      ),
    );
  }
}