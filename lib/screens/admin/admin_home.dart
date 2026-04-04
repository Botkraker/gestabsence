import 'package:flutter/material.dart';

class AdminHome extends StatelessWidget {
	const AdminHome({super.key, required this.name});

	final String name;

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Admin Home')),
			body: Center(
				child: Text(
					name.isEmpty ? 'Welcome, Admin' : 'Welcome, $name',
					style: const TextStyle(fontSize: 20,color: Colors.white),
				),
			),
		);
	}
}
