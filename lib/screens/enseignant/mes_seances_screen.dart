import 'package:flutter/material.dart';
import 'package:gestabsence/screens/enseignant/appel_screen.dart';
import 'package:gestabsence/screens/enseignant/enseignant_home.dart';
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
                'Welcome, Dr.${widget.name},this page is Mes Seances Screen',
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
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>  AppelScreen(userId: widget.userId, name: widget.name)),
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