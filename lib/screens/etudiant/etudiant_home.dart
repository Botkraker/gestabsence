import 'package:flutter/material.dart';
import 'package:gestabsence/main.dart';
import 'package:gestabsence/screens/etudiant/absences_screen.dart';
import 'package:gestabsence/screens/etudiant/profil_screen.dart';
import 'package:gestabsence/themeapp.dart';

class EtudiantHome extends StatefulWidget {
	const EtudiantHome({super.key, required this.userId, required this.name});
	final int userId;
	final String name;

	@override
	State<EtudiantHome> createState() => _EtudiantHomeState();
}

class _EtudiantHomeState extends State<EtudiantHome> {
	int _selectedIndex = 0;

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
        leadingWidth: 250,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              Text(["Profile","Absences"][_selectedIndex], style: ThemeTextStyles.headlineLarge),
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
			body: _buildBody(),
			bottomNavigationBar: BottomNavigationBar(
				currentIndex: _selectedIndex,
				onTap: (index) {
					setState(() {
						_selectedIndex = index;
					});
				},
				items: const [
					BottomNavigationBarItem(
						icon: Icon(Icons.person),
						label: 'Profile',
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.assignment),
						label: 'Absences',
					),
				],
			),
		);
	}

	Widget _buildBody() {
		switch (_selectedIndex) {
			case 0:
				return  ProfilScreen(userId: widget.userId, name: widget.name);
			case 1:
				return  AbsencesScreen(userId: widget.userId, name: widget.name);
			default:
				return  ProfilScreen(userId: widget.userId, name: widget.name);
		}
	}
}
