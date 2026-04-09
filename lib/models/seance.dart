class Seance {
    int? id;
    String? classe;
    String? matiere;
    DateTime? date;
    String? heureDebut;
    String? heureFin;
    String? enseignantNom;
    String? enseignantPrenom;

    Seance({
        this.id,
        this.classe,
        this.matiere,
        this.date,
        this.heureDebut,
        this.heureFin,
        this.enseignantNom,
        this.enseignantPrenom,
    });

    factory Seance.fromJson(Map<String, dynamic> json) {
        return Seance(
            id: int.tryParse(json['id']?.toString() ?? ''),
            classe: json['classe_nom'] as String? ?? json['classe'] as String?,
            matiere: json['matiere_nom'] as String? ?? json['matiere'] as String?,
            date: DateTime.tryParse(json['date_seance']?.toString() ?? ''),
            heureDebut: json['heure_debut']?.toString(),
            heureFin: json['heure_fin']?.toString(),
            enseignantNom: json['enseignant_nom']?.toString(),
            enseignantPrenom: json['enseignant_prenom']?.toString(),
        );
    }

    String get enseignantFullName {
        final nom = enseignantNom?.trim() ?? '';
        final prenom = enseignantPrenom?.trim() ?? '';
        final full = '$nom $prenom'.trim();
        return full.isEmpty ? 'N/A' : full;
    }
}