import 'package:flutter/material.dart';
import 'package:gestabsence/screens/enseignant/enseignant_home.dart';
import 'package:gestabsence/screens/enseignant/mes_seances_screen.dart';
import 'package:gestabsence/themeapp.dart';

class AppelScreen extends StatefulWidget {
  const AppelScreen({super.key, required this.userId, required this.name});
  final int userId;
  final String name;

  @override
  State<AppelScreen> createState() => _AppelScreenState();
}

class _AppelScreenState extends State<AppelScreen> {
  int _currentIndex = 2;

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome, Dr.${widget.name},this page is Appel Screen',
                style: ThemeTextStyles.display,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 24),
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
                MaterialPageRoute(builder: (_) => EnseignantHome(userId: widget.userId, name: widget.name)),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>  MesSeancesScreen(userId: widget.userId, name: widget.name)),
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
}
