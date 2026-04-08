class Utilisateur {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'role': role,
    };
  }
}