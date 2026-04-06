import 'package:flutter/material.dart';

class EnseignantHome extends StatelessWidget {
	const EnseignantHome({super.key, required this.userId, required this.name});

	final int userId;
	final String name;

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Enseignant Home')),
			body: Center(
				child: Text(
					name.isEmpty
							? 'Welcome, Enseignant (ID: $userId)'
							: 'Welcome, $name (ID: $userId)',
					style: const TextStyle(fontSize: 20 ,color: Colors.white),
					textAlign: TextAlign.center,
				),
			),
		);
	}
}
