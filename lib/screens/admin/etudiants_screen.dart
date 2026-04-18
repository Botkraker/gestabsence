import 'package:flutter/material.dart';
import 'package:gestabsence/services/api_service.dart';
import 'package:gestabsence/themeapp.dart';

/// Admin students management screen.
///
/// Main capabilities:
/// - Load students and classes.
/// - Add/edit/delete students.
/// - Search by identity and class.
class EtudiantsScreen extends StatefulWidget {
	const EtudiantsScreen({super.key, this.openAddOnStart = false});

	final bool openAddOnStart;

	@override
	State<EtudiantsScreen> createState() => _EtudiantsScreenState();
}

class _EtudiantsScreenState extends State<EtudiantsScreen> {
	List<Map<String, dynamic>> _students = <Map<String, dynamic>>[];
	List<Map<String, dynamic>> _classes = <Map<String, dynamic>>[];
	bool _isLoading = true;
	bool _didRunInitialAction = false;
	String _searchQuery = '';

	@override
	void initState() {
		super.initState();
		_loadData();
	}

	// Loads students list and classes lookup needed for forms.
	Future<void> _loadData() async {
		setState(() {
			_isLoading = true;
		});

		final studentsResponse = await ApiService.get('/admin/etudiants.php');
		final classesResponse = await ApiService.get('/admin/classes.php');

		if (!mounted) return;

		final students = studentsResponse['success'] == 1 && studentsResponse['data'] is List
				? (studentsResponse['data'] as List)
						.whereType<Map<String, dynamic>>()
						.map((s) => {
									'id': int.tryParse(s['etudiant_id']?.toString() ?? '') ?? 0,
									'nom': s['nom']?.toString() ?? '',
									'prenom': s['prenom']?.toString() ?? '',
									'email': s['email']?.toString() ?? '',
									'classe_id': int.tryParse(s['classe_id']?.toString() ?? '') ?? 0,
									'classe_nom': s['classe_nom']?.toString() ?? '',
								})
						.toList()
				: <Map<String, dynamic>>[];

		final classes = classesResponse['success'] == 1 && classesResponse['data'] is List
				? (classesResponse['data'] as List).whereType<Map<String, dynamic>>().toList()
				: <Map<String, dynamic>>[];

		setState(() {
			_students = students;
			_classes = classes;
			_isLoading = false;
		});

		if (!_didRunInitialAction && widget.openAddOnStart) {
			_didRunInitialAction = true;
			// Trigger add flow after first frame for safer navigation.
			WidgetsBinding.instance.addPostFrameCallback((_) {
				if (!mounted) return;
				_navigateToAdd();
			});
		}
	}

	List<Map<String, dynamic>> get _filtered => _students.where((s) {
				final q = _searchQuery.toLowerCase();
				return '${s['nom']} ${s['prenom']} ${s['email']} ${s['classe_nom']}'
						.toLowerCase()
						.contains(q);
			}).toList();

	// Navigates to add form and forwards returned payload to API create endpoint.
	Future<void> _navigateToAdd() async {
		if (_classes.isEmpty) {
			_showSnack('Create classes first before adding students.');
			return;
		}

		final result = await Navigator.push<Map<String, dynamic>>(
			context,
			MaterialPageRoute(
				builder: (_) => _StudentFormScreen(classes: _classes),
			),
		);

		if (result == null) return;

		await _createStudent(result);
	}

	// Creates a student and optionally reopens edit mode for the created record.
	Future<void> _createStudent(Map<String, dynamic> data) async {
		final response = await ApiService.post('/admin/etudiants.php', data);
		if (!mounted) return;

		if (response['success'] == 1) {
			_showSnack('Student added successfully');
			await _loadData();

			final createdId = int.tryParse(response['data']?['etudiant_id']?.toString() ?? '');
			if (createdId != null && mounted) {
				final created = _students.where((s) => s['id'] == createdId).toList();
				if (created.isNotEmpty) {
					await _navigateToEdit(created.first);
				}
			}
		} else {
			_showSnack(response['message']?.toString() ?? 'Failed to add student');
		}
	}

	// Edits student data or dispatches an add request from edit screen shortcut.
	Future<void> _navigateToEdit(Map<String, dynamic> student) async {
		final result = await Navigator.push<Map<String, dynamic>>(
			context,
			MaterialPageRoute(
				builder: (_) => _StudentFormScreen(
					classes: _classes,
					student: student,
					showAddFromEditButton: true,
				),
			),
		);

		if (result == null) return;

		if (result['_action'] == 'add' && result['payload'] is Map<String, dynamic>) {
			await _createStudent(result['payload'] as Map<String, dynamic>);
			return;
		}

		final response = await ApiService.put('/admin/etudiants.php', result);
		if (!mounted) return;

		if (response['success'] == 1) {
			_showSnack('Student updated successfully');
			await _loadData();
		} else {
			_showSnack(response['message']?.toString() ?? 'Failed to update student');
		}
	}

	// Confirmation guard before deleting a student.
	Future<void> _confirmDelete(Map<String, dynamic> student) async {
		final confirmed = await showDialog<bool>(
			context: context,
			builder: (ctx) => AlertDialog(
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
				title: const Text('Remove Student'),
				content: Text(
					'Are you sure you want to remove ${student['prenom']} ${student['nom']}?',
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

		if (confirmed != true) return;

		final response = await ApiService.delete('/admin/etudiants.php?id=${student['id']}');
		if (!mounted) return;

		if (response['success'] == 1) {
			_showSnack('Student removed');
			await _loadData();
		} else {
			_showSnack(response['message']?.toString() ?? 'Failed to remove student');
		}
	}

	void _showSnack(String message) {
		ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
	}

	@override
	Widget build(BuildContext context) {
		final filtered = _filtered;

		return Scaffold(
			backgroundColor: ThemeColors.background,
			appBar: AppBar(
				title: const Text('Students'),
				leading: IconButton(
					icon: const Icon(Icons.arrow_back),
					onPressed: () => Navigator.of(context).maybePop(),
				),
				actions: [
					IconButton(
						tooltip: 'Add Student',
						onPressed: _navigateToAdd,
						icon: const Icon(Icons.person_add_alt_1_outlined),
					),
					const SizedBox(width: 4),
				],
			),
			body: _isLoading
					? const Center(child: CircularProgressIndicator())
					: Column(
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
											const Icon(Icons.groups_outlined, color: ThemeColors.primary, size: 20),
											const SizedBox(width: 8),
											Text(
												'${_students.length} student${_students.length == 1 ? '' : 's'} registered',
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
											label: const Text('Add Student'),
										),
									),
								),
								Padding(
									padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
									child: TextField(
										decoration: InputDecoration(
											hintText: 'Search by name, email or class...',
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
									child: filtered.isEmpty
											? Center(
													child: Text(
														_searchQuery.isEmpty
																? 'No students yet.\nTap Add Student to get started.'
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
														final student = filtered[index];
														return Container(
															decoration: BoxDecoration(
																color: ThemeColors.surface,
																borderRadius: BorderRadius.circular(14),
																border: Border.all(color: ThemeColors.borderSubtle),
															),
															child: ListTile(
																contentPadding:
																		const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
																title: Text(
																	'${student['prenom']} ${student['nom']}',
																	style: ThemeTextStyles.headlineSmall,
																),
																subtitle: Column(
																	crossAxisAlignment: CrossAxisAlignment.start,
																	children: [
																		const SizedBox(height: 2),
																		Text(
																			student['email']?.toString() ?? '',
																			style: ThemeTextStyles.bodySmall,
																		),
																		Text(
																			'Class: ${student['classe_nom']?.toString() ?? 'N/A'}',
																			style: ThemeTextStyles.bodySmall,
																		),
																	],
																),
																trailing: SizedBox(
																	width: 96,
																	child: Row(
																		mainAxisAlignment: MainAxisAlignment.end,
																		children: [
																			IconButton(
																				icon: const Icon(
																					Icons.edit_outlined,
																					color: ThemeColors.primary,
																				),
																				tooltip: 'Edit',
																				onPressed: () => _navigateToEdit(student),
																			),
																			IconButton(
																				icon: const Icon(
																					Icons.delete_outline,
																					color: ThemeColors.errorRed,
																				),
																				tooltip: 'Remove',
																				onPressed: () => _confirmDelete(student),
																			),
																		],
																	),
																),
															),
														);
													},
												),
								),
							],
						),
		);
	}
}

/// Reusable student form used for both create and edit flows.
class _StudentFormScreen extends StatefulWidget {
	const _StudentFormScreen({
		required this.classes,
		this.student,
		this.showAddFromEditButton = false,
	});

	final List<Map<String, dynamic>> classes;
	final Map<String, dynamic>? student;
	final bool showAddFromEditButton;

	@override
	State<_StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<_StudentFormScreen> {
	final _formKey = GlobalKey<FormState>();
	final _nomController = TextEditingController();
	final _prenomController = TextEditingController();
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();

	bool _obscurePassword = true;
	bool _isSaving = false;
	int? _selectedClassId;

	bool get _isEditing => widget.student != null;

	@override
	void initState() {
		super.initState();

		if (_isEditing) {
			final s = widget.student!;
			_nomController.text = s['nom']?.toString() ?? '';
			_prenomController.text = s['prenom']?.toString() ?? '';
			_emailController.text = s['email']?.toString() ?? '';
			_selectedClassId = int.tryParse(s['classe_id']?.toString() ?? '');
		}

		_selectedClassId ??= int.tryParse(widget.classes.first['id']?.toString() ?? '');
	}

	@override
	void dispose() {
		_nomController.dispose();
		_prenomController.dispose();
		_emailController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	// Validates fields and returns a normalized payload to parent screen.
	void _submit() {
		if (!_formKey.currentState!.validate()) return;
		if (_selectedClassId == null) return;

		setState(() {
			_isSaving = true;
		});

		final payload = <String, dynamic>{
			'nom': _nomController.text.trim(),
			'prenom': _prenomController.text.trim(),
			'email': _emailController.text.trim(),
			'classe_id': _selectedClassId,
			if (_passwordController.text.trim().isNotEmpty) 'password': _passwordController.text,
			if (_isEditing) 'id': int.tryParse(widget.student!['id']?.toString() ?? '0') ?? 0,
		};

		Navigator.pop(context, payload);
	}

	// Allows creating a second student directly from edit mode.
	Future<void> _addFromEdit() async {
		final addPayload = await Navigator.push<Map<String, dynamic>>(
			context,
			MaterialPageRoute(
				builder: (_) => _StudentFormScreen(classes: widget.classes),
			),
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
			backgroundColor: ThemeColors.background,
			appBar: AppBar(
				title: Text(_isEditing ? 'Edit Student' : 'Add Student'),
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(24),
				child: Form(
					key: _formKey,
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							TextFormField(
								controller: _nomController,
								decoration: const InputDecoration(labelText: 'Last name'),
								validator: (v) => v == null || v.trim().isEmpty ? 'Last name is required' : null,
							),
							const SizedBox(height: 14),
							TextFormField(
								controller: _prenomController,
								decoration: const InputDecoration(labelText: 'First name'),
								validator: (v) => v == null || v.trim().isEmpty ? 'First name is required' : null,
							),
							const SizedBox(height: 14),
							TextFormField(
								controller: _emailController,
								decoration: const InputDecoration(labelText: 'Email'),
								keyboardType: TextInputType.emailAddress,
								validator: (v) {
									if (v == null || v.trim().isEmpty) return 'Email is required';
									if (!v.contains('@')) return 'Enter a valid email';
									return null;
								},
							),
							const SizedBox(height: 14),
							TextFormField(
								controller: _passwordController,
								obscureText: _obscurePassword,
								decoration: InputDecoration(
									labelText: _isEditing ? 'New password (optional)' : 'Password',
									suffixIcon: IconButton(
										onPressed: () {
											setState(() {
												_obscurePassword = !_obscurePassword;
											});
										},
										icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
									),
								),
								validator: (v) {
									if (!_isEditing && (v == null || v.trim().isEmpty)) {
										return 'Password is required';
									}
									return null;
								},
							),
							const SizedBox(height: 14),
							DropdownButtonFormField<int>(
								value: _selectedClassId,
								items: widget.classes
										.map(
											(c) => DropdownMenuItem<int>(
												value: int.tryParse(c['id']?.toString() ?? ''),
												child: Text(c['nom']?.toString() ?? 'Class'),
											),
										)
										.toList(),
								onChanged: (value) {
									setState(() {
										_selectedClassId = value;
									});
								},
								decoration: const InputDecoration(labelText: 'Class'),
							),
							const SizedBox(height: 24),
							SizedBox(
								height: 50,
								child: ElevatedButton.icon(
									style: ThemeButtonStyles.secondary,
									onPressed: _isSaving ? null : _submit,
									icon: Icon(_isEditing ? Icons.save_outlined : Icons.add),
									label: Text(_isEditing ? 'Save Changes' : 'Add Student'),
								),
							),
							if (_isEditing && widget.showAddFromEditButton) ...[
								const SizedBox(height: 12),
								SizedBox(
									height: 46,
									child: OutlinedButton.icon(
										onPressed: _isSaving ? null : _addFromEdit,
										icon: const Icon(Icons.person_add_alt_1_outlined),
										label: const Text('Add Student'),
									),
								),
							],
						],
					),
				),
			),
		);
	}
}
