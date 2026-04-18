import 'package:flutter/material.dart';
import 'package:gestabsence/services/api_service.dart';
import 'package:gestabsence/themeapp.dart';

/// Admin teachers management screen.
///
/// Main capabilities:
/// - Load/search teachers.
/// - Add/edit/delete teacher records.
/// - Auto-open add flow when requested from parent navigation.
class EnseignantsScreen extends StatefulWidget {
	const EnseignantsScreen({super.key, this.openAddOnStart = false});

	final bool openAddOnStart;

	@override
	State<EnseignantsScreen> createState() => _EnseignantsScreenState();
}

class _EnseignantsScreenState extends State<EnseignantsScreen> {
	List<Map<String, dynamic>> _teachers = [];
	bool _isLoading = true;
	bool _didRunInitialAction = false;
	String _searchQuery = '';

	@override
	void initState() {
		super.initState();
		_loadTeachers();
	}

	// Fetches and normalizes teacher records for list rendering.
	Future<void> _loadTeachers() async {
		setState(() {
			_isLoading = true;
		});

		final response = await ApiService.get('/admin/enseignants.php');

		if (!mounted) return;

		final data = response['success'] == 1 && response['data'] is List
				? (response['data'] as List).whereType<Map<String, dynamic>>().map((row) {
						return {
							'id': int.tryParse(row['enseignant_id']?.toString() ?? '') ?? 0,
							'nom': row['nom']?.toString() ?? '',
							'prenom': row['prenom']?.toString() ?? '',
							'email': row['email']?.toString() ?? '',
							'matiere': row['specialite']?.toString() ?? '',
						};
					}).toList()
				: <Map<String, dynamic>>[];

		setState(() {
			_teachers = data;
			_isLoading = false;
		});

		if (!_didRunInitialAction && widget.openAddOnStart) {
			_didRunInitialAction = true;
			// Run navigation after initial frame to avoid build-time push issues.
			WidgetsBinding.instance.addPostFrameCallback((_) {
				if (!mounted) return;
				_navigateToAdd();
			});
		}
	}

	List<Map<String, dynamic>> get _filtered => _teachers.where((p) {
				final q = _searchQuery.toLowerCase();
				return '${p['nom']} ${p['prenom']} ${p['email']} ${p['matiere']}'
						.toLowerCase()
						.contains(q);
			}).toList();

	// Opens add form and sends result to API.
	Future<void> _navigateToAdd() async {
		final result = await Navigator.push<Map<String, dynamic>>(
			context,
			MaterialPageRoute(builder: (_) => const _ProfessorFormScreen()),
		);

		if (result != null) {
			await _createTeacher(result);
		}
	}

	// Persists new teacher and optionally jumps into edit for immediate adjustments.
	Future<void> _createTeacher(Map<String, dynamic> data) async {
		final response = await ApiService.post('/admin/enseignants.php', {
			'nom': data['nom'],
			'prenom': data['prenom'],
			'email': data['email'],
			'password': data['password'],
			'specialite': data['matiere'],
		});

		if (!mounted) return;

		if (response['success'] == 1) {
			_showSnack('Professor added successfully');
			await _loadTeachers();

			final createdId = int.tryParse(
				response['data']?['enseignant_id']?.toString() ?? '',
			);

			if (createdId != null && mounted) {
				final created = _teachers.where((p) => p['id'] == createdId).toList();
				if (created.isNotEmpty) {
					await _navigateToEdit(created.first);
				}
			}
		} else {
			_showSnack(response['message']?.toString() ?? 'Failed to add professor');
		}
	}

	// Opens edit form and applies updates via API.
	Future<void> _navigateToEdit(Map<String, dynamic> teacher) async {
		final result = await Navigator.push<Map<String, dynamic>>(
			context,
			MaterialPageRoute(
				builder: (_) => _ProfessorFormScreen(professor: teacher),
			),
		);

		if (result != null) {
			if (result['_action'] == 'add' && result['payload'] is Map<String, dynamic>) {
				await _createTeacher(result['payload'] as Map<String, dynamic>);
				return;
			}

			final response = await ApiService.put('/admin/enseignants.php', {
				'id': result['id'],
				'nom': result['nom'],
				'prenom': result['prenom'],
				'email': result['email'],
				'specialite': result['matiere'],
				if ((result['password']?.toString() ?? '').isNotEmpty) 'password': result['password'],
			});

			if (!mounted) return;

			if (response['success'] == 1) {
				_showSnack('Professor updated successfully');
				await _loadTeachers();
			} else {
				_showSnack(response['message']?.toString() ?? 'Failed to update professor');
			}
		}
	}

	// Asks for delete confirmation before irreversible removal.
	Future<void> _confirmDelete(Map<String, dynamic> teacher) async {
		final confirmed = await showDialog<bool>(
			context: context,
			builder: (ctx) => AlertDialog(
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
				title: const Text('Remove Professor'),
				content: Text(
					'Are you sure you want to remove ${teacher['prenom']} ${teacher['nom']}?',
				),
				actions: [
					TextButton(
						onPressed: () => Navigator.pop(ctx, false),
						child: const Text('Cancel'),
					),
					ElevatedButton(
						style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.errorRed),
						onPressed: () => Navigator.pop(ctx, true),
						child: const Text('Remove', style: TextStyle(color: Colors.white)),
					),
				],
			),
		);

		if (confirmed == true) {
			final response = await ApiService.delete('/admin/enseignants.php?id=${teacher['id']}');

			if (!mounted) return;

			if (response['success'] == 1) {
				_showSnack('Professor removed');
				await _loadTeachers();
			} else {
				_showSnack(response['message']?.toString() ?? 'Failed to remove professor');
			}
		}
	}

	void _showSnack(String message) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text(message)),
		);
	}

	@override
	Widget build(BuildContext context) {
		final filtered = _filtered;

		return Scaffold(
			backgroundColor: ThemeColors.background,
			appBar: AppBar(
				title: const Text('Professors'),
				backgroundColor: ThemeColors.surface,
				foregroundColor: ThemeColors.textPrimary,
				elevation: 0,
				leading: IconButton(
					icon: const Icon(Icons.arrow_back),
					onPressed: () => Navigator.of(context).maybePop(),
				),
			),
			body: Column(
				children: [
					Container(
						margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
						padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
						decoration: BoxDecoration(
							color: ThemeColors.primary.withValues(alpha: 0.08),
							borderRadius: BorderRadius.circular(12),
							border: Border.all(color: ThemeColors.primary.withValues(alpha: 0.2)),
						),
						child: Row(
							children: [
								const Icon(Icons.people, color: ThemeColors.primary, size: 20),
								const SizedBox(width: 8),
								Text(
									'${_teachers.length} professor${_teachers.length == 1 ? '' : 's'} registered',
									style: ThemeTextStyles.bodyMedium.copyWith(
										color: ThemeColors.primary,
										fontWeight: FontWeight.w600,
									),
								),
							],
						),
					),
					Padding(
						padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
						child: SizedBox(
							width: double.infinity,
							child: ElevatedButton.icon(
								style: ThemeButtonStyles.secondary,
								onPressed: _navigateToAdd,
								icon: const Icon(Icons.person_add_alt_1_outlined),
								label: const Text('Add Enseignant'),
							),
						),
					),
					Padding(
						padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
						child: TextField(
							decoration: InputDecoration(
								hintText: 'Search by name, email or subject...',
								prefixIcon: const Icon(Icons.search),
								border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
								filled: true,
								fillColor: ThemeColors.surfaceAlt,
								contentPadding: const EdgeInsets.symmetric(vertical: 0),
							),
							onChanged: (v) => setState(() => _searchQuery = v),
						),
					),
					Expanded(
						child: _isLoading
								? const Center(child: CircularProgressIndicator())
								: filtered.isEmpty
										? Center(
												child: Text(
													_searchQuery.isEmpty
															? 'No professors yet.\nTap "Add" to get started.'
															: 'No results for "$_searchQuery"',
													style: ThemeTextStyles.bodyMedium,
													textAlign: TextAlign.center,
												),
											)
										: ListView.separated(
												padding: const EdgeInsets.all(16),
												itemCount: filtered.length,
												separatorBuilder: (_, __) => const SizedBox(height: 10),
												itemBuilder: (context, index) {
													final teacher = filtered[index];
													return _TeacherTile(
														teacher: teacher,
														onEdit: () => _navigateToEdit(teacher),
														onDelete: () => _confirmDelete(teacher),
													);
												},
											),
					),
				],
			),
		);
	}
}

class _TeacherTile extends StatelessWidget {
	const _TeacherTile({
		required this.teacher,
		required this.onEdit,
		required this.onDelete,
	});

	final Map<String, dynamic> teacher;
	final VoidCallback onEdit;
	final VoidCallback onDelete;

	@override
	Widget build(BuildContext context) {
		final fullName = '${teacher['prenom']} ${teacher['nom']}';
		final initials = _initials(teacher['prenom'], teacher['nom']);

		return Container(
			decoration: BoxDecoration(
				color: ThemeColors.surface,
				borderRadius: BorderRadius.circular(14),
				border: Border.all(color: ThemeColors.borderSubtle),
				boxShadow: [
					BoxShadow(
						color: Colors.black.withValues(alpha: 0.04),
						blurRadius: 6,
						offset: const Offset(0, 2),
					),
				],
			),
			child: ListTile(
				contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
				leading: CircleAvatar(
					radius: 24,
					backgroundColor: ThemeColors.primary.withValues(alpha: 0.12),
					child: Text(
						initials,
						style: const TextStyle(
							color: ThemeColors.primary,
							fontWeight: FontWeight.bold,
							fontSize: 15,
						),
					),
				),
				title: Text(fullName, style: ThemeTextStyles.headlineSmall),
				isThreeLine: true,
				subtitle: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					mainAxisSize: MainAxisSize.min,
					children: [
						const SizedBox(height: 2),
						Row(
							children: [
								const Icon(Icons.email_outlined, size: 13, color: ThemeColors.textSecondary),
								const SizedBox(width: 4),
								Expanded(
									child: Text(
										teacher['email'] ?? '',
										style: ThemeTextStyles.bodySmall,
										overflow: TextOverflow.ellipsis,
										maxLines: 1,
									),
								),
							],
						),
						const SizedBox(height: 2),
						Row(
							children: [
								const Icon(Icons.menu_book_outlined, size: 13, color: ThemeColors.textSecondary),
								const SizedBox(width: 4),
								Expanded(
									child: Text(
										teacher['matiere'] ?? '',
										style: ThemeTextStyles.bodySmall,
										overflow: TextOverflow.ellipsis,
										maxLines: 1,
									),
								),
							],
						),
					],
				),
				trailing: Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						IconButton(
							icon: const Icon(Icons.edit_outlined, color: ThemeColors.primary),
							tooltip: 'Edit',
							onPressed: onEdit,
							padding: const EdgeInsets.all(8),
							constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
						),
						IconButton(
							icon: const Icon(Icons.delete_outline, color: ThemeColors.errorRed),
							tooltip: 'Remove',
							onPressed: onDelete,
							padding: const EdgeInsets.all(8),
							constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
						),
					],
				),
			),
		);
	}

	String _initials(String? prenom, String? nom) {
		final a = (prenom?.isNotEmpty == true) ? prenom![0].toUpperCase() : '';
		final b = (nom?.isNotEmpty == true) ? nom![0].toUpperCase() : '';
		return '$a$b';
	}
}

/// Reusable professor form used for both create and edit flows.
class _ProfessorFormScreen extends StatefulWidget {
	const _ProfessorFormScreen({this.professor});

	final Map<String, dynamic>? professor;

	@override
	State<_ProfessorFormScreen> createState() => _ProfessorFormScreenState();
}

class _ProfessorFormScreenState extends State<_ProfessorFormScreen> {
	final _formKey = GlobalKey<FormState>();
	final _nomController = TextEditingController();
	final _prenomController = TextEditingController();
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();
	final _matiereController = TextEditingController();
	bool _obscurePassword = true;
	bool _isSaving = false;

	bool get _isEditing => widget.professor != null;

	@override
	void initState() {
		super.initState();
		if (_isEditing) {
			final p = widget.professor!;
			_nomController.text = p['nom'] ?? '';
			_prenomController.text = p['prenom'] ?? '';
			_emailController.text = p['email'] ?? '';
			_matiereController.text = p['matiere'] ?? '';
		}
	}

	@override
	void dispose() {
		_nomController.dispose();
		_prenomController.dispose();
		_emailController.dispose();
		_passwordController.dispose();
		_matiereController.dispose();
		super.dispose();
	}

	// Validates fields and returns a normalized payload to parent screen.
	Future<void> _submit() async {
		if (!_formKey.currentState!.validate()) return;

		setState(() => _isSaving = true);

		final result = <String, dynamic>{
			'nom': _nomController.text.trim(),
			'prenom': _prenomController.text.trim(),
			'email': _emailController.text.trim(),
			'matiere': _matiereController.text.trim(),
			if (_passwordController.text.isNotEmpty) 'password': _passwordController.text,
			if (_isEditing) 'id': int.tryParse(widget.professor!['id']?.toString() ?? '') ?? 0,
		};

		if (!mounted) return;
		setState(() => _isSaving = false);
		Navigator.pop(context, result);
	}

	// Shortcut that lets users add another professor from edit context.
	Future<void> _addFromEdit() async {
		final addPayload = await Navigator.push<Map<String, dynamic>>(
			context,
			MaterialPageRoute(builder: (_) => const _ProfessorFormScreen()),
		);

		if (!mounted || addPayload == null) return;

		Navigator.pop(context, {
			'_action': 'add',
			'payload': addPayload,
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(_isEditing ? 'Edit Professor' : 'Add Professor'),
				backgroundColor: ThemeColors.surface,
				foregroundColor: ThemeColors.textPrimary,
				elevation: 0,
			),
			backgroundColor: ThemeColors.surface,
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(24),
				child: Form(
					key: _formKey,
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							Center(
								child: CircleAvatar(
									radius: 40,
									backgroundColor: ThemeColors.primary.withValues(alpha: 0.12),
									child: const Icon(Icons.person, size: 40, color: ThemeColors.primary),
								),
							),
							const SizedBox(height: 28),
							_buildField(
								controller: _nomController,
								label: 'Last Name (Nom)',
								icon: Icons.badge_outlined,
								validator: (v) => v == null || v.trim().isEmpty ? 'Last name is required' : null,
							),
							const SizedBox(height: 16),
							_buildField(
								controller: _prenomController,
								label: 'First Name (Prenom)',
								icon: Icons.person_outline,
								validator: (v) => v == null || v.trim().isEmpty ? 'First name is required' : null,
							),
							const SizedBox(height: 16),
							_buildField(
								controller: _emailController,
								label: 'Email',
								icon: Icons.email_outlined,
								keyboardType: TextInputType.emailAddress,
								validator: (v) {
									if (v == null || v.trim().isEmpty) return 'Email is required';
									if (!v.contains('@')) return 'Enter a valid email';
									return null;
								},
							),
							const SizedBox(height: 16),
							TextFormField(
								controller: _passwordController,
								obscureText: _obscurePassword,
								decoration: InputDecoration(
									labelText: _isEditing ? 'New Password (leave blank to keep)' : 'Password',
									prefixIcon: const Icon(Icons.lock_outline),
									suffixIcon: IconButton(
										icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
										onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
									),
									border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
									filled: true,
									fillColor: ThemeColors.surfaceAlt,
								),
								validator: (v) {
									if (!_isEditing && (v == null || v.trim().isEmpty)) {
										return 'Password is required';
									}
									return null;
								},
							),
							const SizedBox(height: 16),
							_buildField(
								controller: _matiereController,
								label: 'Subject (Matiere)',
								icon: Icons.menu_book_outlined,
								validator: (v) => v == null || v.trim().isEmpty ? 'Subject is required' : null,
							),
							const SizedBox(height: 32),
							SizedBox(
								height: 50,
								child: ElevatedButton.icon(
									style: ElevatedButton.styleFrom(
										backgroundColor: ThemeColors.primary,
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(12),
										),
									),
									onPressed: _isSaving ? null : _submit,
									icon: _isSaving
											? const SizedBox(
													width: 18,
													height: 18,
													child: CircularProgressIndicator(
														strokeWidth: 2,
														color: Colors.white,
													),
												)
											: Icon(_isEditing ? Icons.save_outlined : Icons.add),
									label: Text(
										_isSaving ? 'Saving...' : (_isEditing ? 'Save Changes' : 'Add Professor'),
										style: const TextStyle(color: Colors.white, fontSize: 16),
									),
								),
							),
							if (_isEditing) ...[
								const SizedBox(height: 12),
								SizedBox(
									height: 46,
									child: OutlinedButton.icon(
										onPressed: _isSaving ? null : _addFromEdit,
										icon: const Icon(Icons.person_add_alt_1_outlined),
										label: const Text('Add Professor'),
									),
								),
							],
						],
					),
				),
			),
		);
	}

	Widget _buildField({
		required TextEditingController controller,
		required String label,
		required IconData icon,
		TextInputType keyboardType = TextInputType.text,
		String? Function(String?)? validator,
	}) {
		return TextFormField(
			controller: controller,
			keyboardType: keyboardType,
			decoration: InputDecoration(
				labelText: label,
				prefixIcon: Icon(icon),
				border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
				filled: true,
				fillColor: ThemeColors.surfaceAlt,
			),
			validator: validator,
		);
	}
}
