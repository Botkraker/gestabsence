import 'package:flutter/material.dart';
import 'package:gestabsence/themeapp.dart';

class ProfessorFormScreen extends StatefulWidget {
  const ProfessorFormScreen({super.key, this.professor});

  /// Pass existing professor map to edit, null to add new
  final Map<String, dynamic>? professor;

  @override
  State<ProfessorFormScreen> createState() => _ProfessorFormScreenState();
}

class _ProfessorFormScreenState extends State<ProfessorFormScreen> {
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
      // Password left blank on edit — only filled if changing
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final result = <String, dynamic>{
      'nom': _nomController.text.trim(),
      'prenom': _prenomController.text.trim(),
      'email': _emailController.text.trim(),
      'matiere': _matiereController.text.trim(),
      if (_passwordController.text.isNotEmpty)
        'password': _passwordController.text,
      if (_isEditing)
        'id': int.tryParse(widget.professor!['id']?.toString() ?? '') ?? 0,
    };

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context, result);
  }

  Future<void> _addFromEdit() async {
    final addPayload = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const ProfessorFormScreen()),
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
              // Avatar placeholder
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: ThemeColors.primary.withValues(alpha: 0.12),
                  child: const Icon(Icons.person, size: 40, color: ThemeColors.primary),
                ),
              ),
              const SizedBox(height: 28),

              // Nom
              _buildField(
                controller: _nomController,
                label: 'Last Name (Nom)',
                icon: Icons.badge_outlined,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Last name is required' : null,
              ),
              const SizedBox(height: 16),

              // Prenom
              _buildField(
                controller: _prenomController,
                label: 'First Name (Prénom)',
                icon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'First name is required' : null,
              ),
              const SizedBox(height: 16),

              // Email
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

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: _isEditing ? 'New Password (leave blank to keep)' : 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
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

              // Matiere
              _buildField(
                controller: _matiereController,
                label: 'Subject (Matière)',
                icon: Icons.menu_book_outlined,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Subject is required' : null,
              ),
              const SizedBox(height: 32),

              // Submit button
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
                    _isSaving
                        ? 'Saving...'
                        : (_isEditing ? 'Save Changes' : 'Add Professor'),
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
