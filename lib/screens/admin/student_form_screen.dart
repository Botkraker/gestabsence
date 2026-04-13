import 'package:flutter/material.dart';
import 'package:gestabsence/themeapp.dart';

class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({
    super.key,
    required this.classes,
    this.student,
    this.showAddFromEditButton = false,
  });

  final List<Map<String, dynamic>> classes;
  final Map<String, dynamic>? student;
  final bool showAddFromEditButton;

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
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
      if (_passwordController.text.trim().isNotEmpty)
        'password': _passwordController.text,
      if (_isEditing)
        'id': int.tryParse(widget.student!['id']?.toString() ?? '0') ?? 0,
    };

    Navigator.pop(context, payload);
  }

  Future<void> _addFromEdit() async {
    final addPayload = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => StudentFormScreen(classes: widget.classes),
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
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Last name is required'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(labelText: 'First name'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'First name is required'
                    : null,
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
                  labelText: _isEditing
                      ? 'New password (optional)'
                      : 'Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
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
