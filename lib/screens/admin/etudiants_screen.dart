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
	const EtudiantsScreen({super.key});

	@override
	State<EtudiantsScreen> createState() => _EtudiantsScreenState();
}

class _EtudiantsScreenState extends State<EtudiantsScreen> {
	List<Map<String, dynamic>> _students = <Map<String, dynamic>>[];
	List<Map<String, dynamic>> _classes = <Map<String, dynamic>>[];
	bool _isLoading = true;
	String _searchQuery = ''; // this is the search query that used to filter

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
    // verification if the user changed widget if he did it will stop the execution of the 2 functions 
    // else will continue 
    

    //hard part 
    // this will take response from api and convert it to a list 
    // of maps with the key value from the response and handle missing values 
    // and type mismatches
		final students = studentsResponse['success'] == 1 && studentsResponse['data'] is List
				? (studentsResponse['data'] as List)
						.whereType<Map<String, dynamic>>()
						.map((s) => {
              // first we try to parse id and if it fails we default to 0 
									'id': int.tryParse(s['etudiant_id']?.toString() ?? '') ?? 0,
                  // same with nom prenom email and classe_id we conver them to 0 or '' 
                  // this logic to prevent the app from crashing if api response is missing a field or has a type mismatch
									'nom': s['nom']?.toString() ?? '',
									'prenom': s['prenom']?.toString() ?? '',
									'email': s['email']?.toString() ?? '',
									'classe_id': int.tryParse(s['classe_id']?.toString() ?? '') ?? 0,
									'classe_nom': s['classe_nom']?.toString() ?? '',
								})
						.toList() // finally we convert the iterable to a list of maps<key, value>
				: <Map<String, dynamic>>[];
    // result example List = [{id:1 , nom:"Trabelsi", prenom:"Amine",email:"student@school.com",classe_id:2,classe_nom:"CI2"}]
		final classes = classesResponse['success'] == 1 && classesResponse['data'] is List
				? (classesResponse['data'] as List).whereType<Map<String, dynamic>>().toList()
				: <Map<String, dynamic>>[];
        // same logic for classes but simpler cause it doesn't have a lot of fields to handle

		setState(() { 
			_students = students;
			_classes = classes;
			_isLoading = false;
		});// after successful loading we update the state with new data 

		// ...existing code...
	}
// getter filter students 
// how this works check if the search query matches any student list from the _students list in database 
// if it does and returns a new list of all students that matches, it will be displayed instead of the student list
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
    // this will take the formulaire information key , value
    // (value can a dynamic type and push it to the create student method)
		final result = await Navigator.push<Map<String, dynamic>>(
			context,
			MaterialPageRoute(
				builder: (_) => StudentFormScreen(classes: _classes), // if this has student it will edit else it will add 
			),
		);

		if (result == null) return;

		await _createStudent(result);
	}

	// Creates a student and reloads the list.
	Future<void> _createStudent(Map<String, dynamic> data) async {
		final response = await ApiService.post('/admin/etudiants.php', data);
		if (!mounted) return;

		if (response['success'] == 1) {
			_showSnack('Student added successfully');
			await _loadData();
		} else {
			_showSnack(response['message']?.toString() ?? 'Failed to add student');
		}
	}

	// Edits student data.
	Future<void> _navigateToEdit(Map<String, dynamic> student) async {
		final result = await Navigator.push<Map<String, dynamic>>(
			context,
			MaterialPageRoute(
				builder: (_) => StudentFormScreen(
					classes: _classes,
					student: student,
				),
			),
		);

		if (result == null) return;

		final response = await ApiService.put('/admin/etudiants.php', result);
		if (!mounted) return;

		if (response['success'] == 1) {
			_showSnack('Student updated successfully');
			await _loadData();
		} else {
			_showSnack(response['message']?.toString() ?? 'Failed to update student');
		}
	}

	// Confirmation guard before deleting a student simple alert Dialog
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
// methode of snackbar to avoid code repetition and make it more user friendly
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
					onPressed: () => Navigator.of(context).pop(),
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
					? const Center(child: CircularProgressIndicator()) // if it's loading will show circular progress indicator
					: Column(
							children: [// first child container to display  number of students 
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
                //second child is the add button
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
                // third child is the search text field
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
																		const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
																title: Text(
																	'${student['prenom']} ${student['nom']}',
																	style: ThemeTextStyles.headlineSmall,
																),
																isThreeLine: true,
																subtitle: Column(
																	crossAxisAlignment: CrossAxisAlignment.start,
																	mainAxisSize: MainAxisSize.min,
																	children: [
																		const SizedBox(height: 2),
																		Row(
																			children: [
																				Expanded(
																					child: Text(
																						student['email']?.toString() ?? '',
																						style: ThemeTextStyles.bodySmall,
																						overflow: TextOverflow.ellipsis,
																						maxLines: 1,
																					),
																				),
																			],
																		),
																		Row(
																			children: [
																				Expanded(
																					child: Text(
																						'Class: ${student['classe_nom']?.toString() ?? 'Not assigned to a class yet'}',
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
																			icon: const Icon(
																				Icons.edit_outlined,
																				color: ThemeColors.primary,
																			),
																			tooltip: 'Edit',
																			onPressed: () => _navigateToEdit(student),
																			padding: const EdgeInsets.all(8),
																			constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
																		),
																		IconButton(
																			icon: const Icon(
																				Icons.delete_outline,
																				color: ThemeColors.errorRed,
																			),
																			tooltip: 'Remove',
																			onPressed: () => _confirmDelete(student),
																			padding: const EdgeInsets.all(8),
																			constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
																		),
																	],
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
class StudentFormScreen extends StatefulWidget {
	const StudentFormScreen({
		required this.classes,
		this.student,
	});

	final List<Map<String, dynamic>> classes;
	final Map<String, dynamic>? student;

	@override
	State<StudentFormScreen> createState() => _StudentFormScreenState();
}
// this where form is defined and handeled
class _StudentFormScreenState extends State<StudentFormScreen> {
	final _formKey = GlobalKey<FormState>();
	final _nomController = TextEditingController();
	final _prenomController = TextEditingController();
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();

	bool _obscurePassword = true;// this will hide password
	bool _isSaving = false; // used to handle submittion (disable button when saving)
	late int _selectedClassId;

	bool get _isEditing => widget.student != null;

	@override
	void initState() {
		super.initState();

		if (_isEditing) {
			final s = widget.student!;
			_nomController.text = s['nom']?.toString() ?? '';
			_prenomController.text = s['prenom']?.toString() ?? '';
			_emailController.text = s['email']?.toString() ?? '';
			_selectedClassId = int.tryParse(s['classe_id']?.toString() ?? '') ?? widget.classes.first['id'];
		} else {
			_selectedClassId = int.tryParse(widget.classes.first['id']?.toString() ?? '0') ?? 0;
		}
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
								decoration: const InputDecoration(
									labelText: 'Last name',
									border: OutlineInputBorder(),
								),
								validator: (v) => v == null || v.trim().isEmpty ? 'Last name is required' : null,
							),
							const SizedBox(height: 16),
							TextFormField(
								controller: _prenomController,
								decoration: const InputDecoration(
									labelText: 'First name',
									border: OutlineInputBorder(),
								),
								validator: (v) => v == null || v.trim().isEmpty ? 'First name is required' : null,
							),
							const SizedBox(height: 16),
							TextFormField(
								controller: _emailController,
								decoration: const InputDecoration(
									labelText: 'Email',
									border: OutlineInputBorder(),
								),
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
									labelText: _isEditing ? 'New password (optional)' : 'Password',
									border: const OutlineInputBorder(),
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
							const SizedBox(height: 16),
							FormField<int>(
								validator: (v) => v == null ? 'Please select a class' : null,
								builder: (FormFieldState<int> state) {
									return Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											DropdownButton<int>(
												value: _selectedClassId,
												icon: const Icon(Icons.arrow_downward),
												elevation: 16,
												isExpanded: true,
												onChanged: (int? value) {
													setState(() {
														_selectedClassId = value ?? _selectedClassId;
													});
													state.didChange(value);
												},
												items: widget.classes.map<DropdownMenuItem<int>>((Map<String, dynamic> classe) {
													final classId = int.tryParse(classe['id']?.toString() ?? '0') ?? 0;
													final className = classe['nom']?.toString() ?? 'Class';
													return DropdownMenuItem<int>(
														value: classId,
														child: Text(className),
													);
												}).toList(),
											),
											if (state.hasError)
												Padding(
													padding: const EdgeInsets.only(top: 8),
													child: Text(
														state.errorText ?? '',
														style: const TextStyle(color: Colors.red, fontSize: 12),
													),
												),
										],
									);
								},
							),
							const SizedBox(height: 24),
							ElevatedButton(
								onPressed: _isSaving ? null : _submit,
								child: Text(_isEditing ? 'Save Changes' : 'Add Student'),
							),

						],
					),
				),
			),
		);
	}
}
