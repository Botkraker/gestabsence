class SeanceAbsenceStats {
  const SeanceAbsenceStats({
    required this.id,
    required this.title,
    required this.subjectName,
    required this.className,
    required this.teacherName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.absentCount,
    required this.totalCount,
  });

  final int id;
  final String title;
  final String subjectName;
  final String className;
  final String teacherName;
  final DateTime? date;
  final String? startTime;
  final String? endTime;
  final int absentCount;
  final int totalCount;

  factory SeanceAbsenceStats.fromJson(Map<String, dynamic> json) {
    final matiere = json['matiere_nom']?.toString().trim() ?? '';
    final classe = json['classe_nom']?.toString().trim() ?? '';
    final title = [matiere, classe].where((part) => part.isNotEmpty).join(' - ');
    final teacherName = [
      json['enseignant_nom']?.toString().trim() ?? '',
      json['enseignant_prenom']?.toString().trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ');

    return SeanceAbsenceStats(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: title.isEmpty ? 'Untitled Seance' : title,
      subjectName: matiere.isEmpty ? 'Untitled Subject' : matiere,
      className: classe.isEmpty ? 'N/A' : classe,
      teacherName: teacherName.isEmpty ? 'N/A' : teacherName,
      date: DateTime.tryParse(json['date_seance']?.toString() ?? ''),
      startTime: json['heure_debut']?.toString(),
      endTime: json['heure_fin']?.toString(),
      absentCount: int.tryParse(json['absent_count']?.toString() ?? '0') ?? 0,
      totalCount: int.tryParse(json['absence_total']?.toString() ?? '0') ?? 0,
    );
  }

  double get absenceRate {
    if (totalCount <= 0) return 0;
    return absentCount / totalCount;
  }

  int get absencePercent => (absenceRate * 100).round();
}