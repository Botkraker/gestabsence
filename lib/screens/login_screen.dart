import 'package:flutter/material.dart';
import '../config/api_config.dart';
import 'admin/admin_home.dart';
import 'enseignant/enseignant_home.dart';
import 'etudiant/etudiant_home.dart';

class LoginScreen extends StatefulWidget {
	const LoginScreen({super.key, required this.onLoginSuccess});

	final void Function(Widget screen) onLoginSuccess;

	@override
	State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
	final TextEditingController emailController = TextEditingController();
	final TextEditingController passwordController = TextEditingController();
	String? _errorMessage;


	Future<void> _handleLogin() async {
		final email = emailController.text.trim();
		final password = passwordController.text;

		if (email.isEmpty || password.isEmpty) {
			setState(() {
				_errorMessage = 'Please enter both email and password.';
			});
			return;
		}

		final response = await ApiService.login(email, password);

		if (!mounted) return;

		final success = response['success'] == true || response['success'] == 1;
		final userData = response['user'] is List
				? (response['user'] as List).isNotEmpty
					? response['user'][0]
					: null
				: response['user'];

		if (!success || userData is! Map<String, dynamic>) {
			setState(() {
				_errorMessage =
					response['message']?.toString() ?? 'Login failed. Please try again.';
			});
			return;
		}

		final role = (userData['role']?.toString() ?? '').toLowerCase().trim();
		final userId = int.tryParse(userData['id']?.toString() ?? '') ?? 0;
		final fullName =
				'${userData['name'] ?? ''} ${userData['lastname'] ?? ''}'.trim();

		Widget destination;
		switch (role) {
			case 'admin':
				destination = AdminHome(name: fullName);
				break;
			case 'enseignant':
				destination = EnseignantHome(userId: userId, name: fullName);
				break;
			case 'etudiant':
				destination = EtudiantHome(userId: userId, name: fullName);
				break;
			default:
				setState(() {
					_errorMessage = 'Unknown user role: $role';
				});
				return;
		}

		widget.onLoginSuccess(destination);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Stack(
				children: [
					Positioned.fill(
						child: Image.asset(
							'assets/background.png',
							fit: BoxFit.cover,
							filterQuality: FilterQuality.medium,
							errorBuilder: (context, error, stackTrace) {
								return Container(color: const Color(0xFF1E1E1E));
							},
						),
					),
					SafeArea(
					child: Center(
						child: SingleChildScrollView(
							padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
							child: Container(
							width: 380,
							padding: const EdgeInsets.all(24),
							decoration: BoxDecoration(
								color: const Color(0xFF2F2F2F),
								borderRadius: BorderRadius.circular(16),
								border: Border.all(color: const Color(0xFF565656)),
							),
							child: Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									Container(
										height: 90,
										width: 90,
										decoration: BoxDecoration(
											color: const Color(0xFF494949),
											borderRadius: BorderRadius.circular(14),
										),
										child: ClipRRect(
											borderRadius: BorderRadius.circular(12),
											child: Padding(
												padding: const EdgeInsets.all(8),
												child: Image.asset(
													'assets/logo.webp',
													fit: BoxFit.contain,
												),
											),
										),
									),
									const SizedBox(height: 12),
									const Text(
										'Fac Des Sciences Bizerte',
										style: TextStyle(color: Colors.white70),
									),
									const SizedBox(height: 22),
									TextField(
										controller: emailController,
										keyboardType: TextInputType.emailAddress,
										style: const TextStyle(color: Colors.white),
										decoration: _inputDecoration('Email'),
									),
									const SizedBox(height: 12),
									TextField(
										controller: passwordController,
										obscureText: true,
										style: const TextStyle(color: Colors.white),
										decoration: _inputDecoration('Password'),
									),
									if (_errorMessage != null) ...[
										const SizedBox(height: 12),
										Text(
											_errorMessage!,
											style: const TextStyle(color: Colors.redAccent),
											textAlign: TextAlign.center,
										),
									],
									const SizedBox(height: 18),
									SizedBox(
										width: double.infinity,
										child: ElevatedButton(
											onPressed: _handleLogin,
											style: ElevatedButton.styleFrom(
												backgroundColor: Colors.black,
												foregroundColor: Colors.white,
												padding: const EdgeInsets.symmetric(vertical: 14),
												shape: RoundedRectangleBorder(
													borderRadius: BorderRadius.circular(10),
													side: const BorderSide(color: Color(0xFF737373)),
												),
											),
											child: const Text('Connexion'),
										),
									),
									const SizedBox(height: 14),
									const Text(
										'Fac des sciences bizerte -\n 2026 © Tous droits réservés',
										style: TextStyle(color: Colors.white70, fontSize: 13),
										textAlign: TextAlign.center,
									),
								],
							),
							),
						),
					),
					),
				],
			),
		);
	}

	InputDecoration _inputDecoration(String hintText) {
		return InputDecoration(
			hintText: hintText,
			hintStyle: const TextStyle(color: Colors.white60),
			filled: true,
			fillColor: const Color(0xFF1E1E1E),
			contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
			border: OutlineInputBorder(
				borderRadius: BorderRadius.circular(10),
				borderSide: const BorderSide(color: Color(0xFF5B5B5B)),
			),
			enabledBorder: OutlineInputBorder(
				borderRadius: BorderRadius.circular(10),
				borderSide: const BorderSide(color: Color(0xFF5B5B5B)),
			),
			focusedBorder: OutlineInputBorder(
				borderRadius: BorderRadius.circular(10),
				borderSide: const BorderSide(color: Colors.white70),
			),
		);
	}
}
