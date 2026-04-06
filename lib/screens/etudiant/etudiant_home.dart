import 'package:flutter/material.dart';

class EtudiantHome extends StatelessWidget {
	const EtudiantHome({super.key, required this.userId, required this.name});

	final int userId;
	final String name;

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Etudiant Home')),
			body: Center(
				child: Text(
					name.isEmpty
							? 'Welcome, Etudiant (ID: $userId)'
							: 'Welcome, $name (ID: $userId)',
					style: const TextStyle(fontSize: 20, color: Colors.white),
					textAlign: TextAlign.center,
				),
			),
		);
	}
}
