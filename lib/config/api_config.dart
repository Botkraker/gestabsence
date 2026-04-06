// On this setup, the PHP server listens on localhost:8067.
const String baseUrl = 'http://localhost:8067';

/*
=============================================================================
                         API ENDPOINTS DOCUMENTATION
=============================================================================

AUTHENTICATION:
  POST /auth/login.php
    - Body: { email, password }
    - Returns: { success, user: { id, name, lastname, role } }

ADMIN ENDPOINTS:
  GET  /admin/etudiants.php           - Get all students
  GET  /admin/etudiants.php?id=<id>   - Get specific student
  POST /admin/etudiants.php           - Create new student
       Body: { nom, prenom, email, password, classe_id }
  
  GET  /admin/enseignants.php         - Get all teachers
  GET  /admin/enseignants.php?id=<id> - Get specific teacher
  POST /admin/enseignants.php         - Create new teacher
       Body: { nom, prenom, email, password, specialite }
  
  GET  /admin/seances.php             - Get all sessions
  GET  /admin/seances.php?id=<id>     - Get specific session
  POST /admin/seances.php             - Create new session
       Body: { enseignant_id, classe_id, matiere_id, date_seance, heure_debut, heure_fin }
  
  GET  /admin/classes.php             - Get all classes
  GET  /admin/classes.php?id=<id>     - Get specific class
  POST /admin/classes.php             - Create new class
       Body: { nom, niveau }

STUDENT ENDPOINTS:
  GET /etudiant/absences.php?id=<student_id>  - Get student absences
       Returns: { success, abscounter, data: [{nom, statut, ...}] }
  
  GET /etudiant/profil.php?id=<student_id>    - Get student profile
       Returns: { success, data: [{nom, prenom, email, classe, niveau}] }

TEACHER ENDPOINTS:
  GET  /enseignant/seances.php?enseignant_id=<id>     - Get teacher's sessions
  GET  /enseignant/seances.php?enseignant_id=<id>&id=<seance_id> - Get specific session
  
  POST /enseignant/absences.php                       - Record absences
       Body: { enseignant_id, seance_id, listabsence: [[etudiant_id, statut], ...] }

=============================================================================
*/

