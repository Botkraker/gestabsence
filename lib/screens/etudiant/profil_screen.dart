import 'package:flutter/material.dart';
import 'package:gestabsence/themeapp.dart';
import 'package:gestabsence/services/student_service.dart';
import 'package:gestabsence/models/etudiant.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key, required this.userId, required this.name});

  final int userId;
  final String name;

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Etudiant?>(
      future: StudentService.getStudentProfileByUserId(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Text(
              snapshot.error != null ? 'Error: ${snapshot.error}' : 'Student not found',
              style: ThemeTextStyles.bodyMedium,
            ),
          );
        }

        final student = snapshot.data!;
        final fullName = '${student.utilisateur.prenom} ${student.utilisateur.nom}';
        final initials = (student.utilisateur.prenom?[0] ?? '') +
            (student.utilisateur.nom?[0] ?? '');

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar with border
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ThemeColors.primary,
                      width: 3,
                    ),
                    color: ThemeColors.surface,
                  ),
                  child: Center(
                    child: Text(
                      initials.toUpperCase(),
                      style: ThemeTextStyles.display.copyWith(
                        fontSize: 40,
                        color: ThemeColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  fullName,
                  style: ThemeTextStyles.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                // Class Code
                Text(
                  student.classe ?? 'N/A',
                  style: ThemeTextStyles.bodyMedium.copyWith(
                    color: ThemeColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Level Card
                _buildInfoCard(
                  icon: Icons.school_outlined,
                  label: 'LEVEL',
                  value: student.niveau ?? 'N/A',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.class_,
                  label: 'Classe',
                  value: student.classe ?? 'N/A',
                ),
                const SizedBox(height: 12),
                // Email Card
                _buildInfoCard(
                  icon: Icons.email_outlined,
                  label: 'EMAIL',
                  value: student.utilisateur.email ?? 'N/A',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ThemeColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: ThemeColors.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: ThemeTextStyles.bodySmall.copyWith(
                    color: ThemeColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: ThemeTextStyles.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}