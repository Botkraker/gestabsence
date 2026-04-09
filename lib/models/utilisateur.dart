class Utilisateur {
  int? id;
  String? nom;
  String? prenom;
  String? email;
  String? role;
  Utilisateur({
    this.id,
    this.nom,
    this.prenom,
    this.email,
    this.role,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: int.tryParse(json['utilisateur_id']?.toString() ?? json['id']?.toString() ?? ''),
      nom: json['nom']?.toString(),
      prenom: json['prenom']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
    );
  }
}