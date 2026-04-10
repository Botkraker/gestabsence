import 'package:flutter/material.dart';
import 'package:gestabsence/models/absence.dart';
import 'package:gestabsence/services/absence_service.dart';
import 'package:gestabsence/themeapp.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AbsencesScreen extends StatefulWidget {
  const AbsencesScreen({super.key, required this.userId, required this.name});

  final int userId;
  final String name;

  @override
  State<AbsencesScreen> createState() => _AbsencesScreenState();
}

class _AbsencesScreenState extends State<AbsencesScreen> {
  late Future<(List<Absence>, int)?> _absencesFuture;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR');
    _absencesFuture = AbsenceService.getStudentAbsences(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(List<Absence>, int)?>(
      future: _absencesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (snapshot.data == null) {
          return const Center(
            child: Text('Error Accord in fetching data.'),
          );
        }
        final (absences, totalAbsences) = snapshot.data ?? ([], 0);

        return SingleChildScrollView(
          child: Column(
            children: [
              // Total Absences Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ThemeColors.primary,
                      ThemeColors.primaryLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL ABSENCES',
                      style: ThemeTextStyles.labelCaps.copyWith(
                        color: ThemeColors.textPrimary,
                        letterSpacing: 3.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          totalAbsences.toString().padLeft(2, '0'),
                          style: ThemeTextStyles.display.copyWith(
                            fontSize: 56,
                            color: ThemeColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Heures',
                          style: ThemeTextStyles.bodyLarge.copyWith(
                            color: ThemeColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Detailed History Section
              if (absences.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Historique Détaillé',
                            style: ThemeTextStyles.headlineMedium,
                          ),
                          Text(
                            '${absences.length} Sessions',
                            style: ThemeTextStyles.labelMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: absences.length,
                        itemBuilder: (context, index) {
                          final absence = absences[index];
                          final isAbsent =
                              absence.status.toUpperCase() == 'ABSENT';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: ThemeColors.surface,
                              border: Border.all(
                                color: ThemeColors.borderSubtle,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        absence.seance.matiere ?? 'N/A',
                                        style: ThemeTextStyles.headlineSmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isAbsent
                                            ? ThemeColors.tertiaryDim
                                            : const Color(0xFF1E3A2F),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        absence.status.toUpperCase(),
                                        style: ThemeTextStyles.labelMedium
                                            .copyWith(
                                          color: isAbsent
                                              ? ThemeColors.tertiaryLight
                                              : ThemeColors.liveGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: ThemeColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      absence.seance.date != null
                                          ? DateFormat('d MMMM yyyy',
                                                  'fr_FR')
                                              .format(absence.seance.date!)
                                          : 'N/A',
                                      style: ThemeTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: ThemeColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${absence.seance.heureDebut ?? 'N/A'} - ${absence.seance.heureFin ?? 'N/A'}',
                                      style: ThemeTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: ThemeColors.liveGreen,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune absence',
                        style: ThemeTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vous avez une présence parfaite!',
                        style: ThemeTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}