import 'package:gestabsence/services/auth_service.dart';
import 'package:gestabsence/services/student_service.dart';
import 'package:gestabsence/services/teacher_service.dart';
import 'package:gestabsence/services/session_service.dart';
import 'package:gestabsence/services/absence_service.dart';
import 'package:gestabsence/services/class_service.dart';

void main() async {
  print('🧪 Starting Service Tests...\n');

  // Test Auth Service
  await testAuthService();
  // Test Student Service
  await testStudentService();

  // Test Teacher Service
  await testTeacherService();

  // Test Session Service
  await testSessionService();

  // Test Class Service
  await testClassService();

  // Test Absence Service
  await testAbsenceService();

  print('\n✅ All tests completed!');
}

Future<void> testAuthService() async {
  print('📋 Testing AuthService...');
  try {
    final result = await AuthService.login('prof', 'prof123');
    print('  ✓ login(): ${result['success'] == 1 ? '✅ SUCCESS' : '❌ FAILED'}');
    if (result['data'] != null) {
      print('    Data: ${result['data']}');
    } else {
      print('    Message: ${result['message']}');
    }
  } catch (e) {
    print('  ❌ login() Error: $e');
  }
  print('');
}

Future<void> testStudentService() async {
  print('👨‍🎓 Testing StudentService...');

  try {
    // Test getAllStudents
    final students = await StudentService.getAllStudents();
    print('  ✓ getAllStudents(): ${students.isNotEmpty ? '✅ Found ${students.length} students' : '❌ No students found'}');
    if (students.isNotEmpty) {
      print('    First student: ${students[0].utilisateur?.nom}');
    }
  } catch (e) {
    print('  ❌ getAllStudents() Error: $e');
  }

  try {
    // Test getStudent (assuming ID 1 exists)
    final student = await StudentService.getStudent(1);
    print('  ✓ getStudent(1): ${student != null ? '✅ Found' : '❌ Not found'}');
    if (student != null) {
      print('    Student: ${student.utilisateur?.prenom} ${student.utilisateur?.nom}');
    }
  } catch (e) {
    print('  ❌ getStudent() Error: $e');
  }

  try {
    // Test createStudent
    final result = await StudentService.createStudent(
      nom: 'Test',
      prenom: 'Student',
      email: 'student_test@example.com',
      password: 'testpass123',
      classeId: 1,
    );
    print('  ✓ createStudent(): ${result['success'] == 1 ? '✅ Created' : '❌ Failed'}');
    if (result['message'] != null) {
      print('    Message: ${result['message']}');
    }
  } catch (e) {
    print('  ❌ createStudent() Error: $e');
  }

  try {
    // Test getStudentAbsences
    final absences = await AbsenceService.getStudentAbsences(1);
    print('  ✓ getStudentAbsences(1): ${absences.isNotEmpty ? '✅ Found ${absences.length} absences' : '❌ No absences'}');
  } catch (e) {
    print('  ❌ getStudentAbsences() Error: $e');
  }

  try {
    // Test getStudentProfile
    final profile = await StudentService.getStudentProfile(1);
    print('  ✓ getStudentProfile(1): ${profile['success'] == 1 ? '✅ Retrieved' : '❌ Failed'}');
    if (profile['data'] != null) {
      print('    Data: ${profile['data']}');
    }
  } catch (e) {
    print('  ❌ getStudentProfile() Error: $e');
  }

  print('');
}

Future<void> testTeacherService() async {
  print('👨‍🏫 Testing TeacherService...');

  try {
    // Test getAllTeachers
    final teachers = await TeacherService.getAllTeachers();
    print('  ✓ getAllTeachers(): ${teachers.isNotEmpty ? '✅ Found ${teachers.length} teachers' : '❌ No teachers found'}');
    if (teachers.isNotEmpty) {
      print('    First teacher: ${teachers[0].nom}');
    }
  } catch (e) {
    print('  ❌ getAllTeachers() Error: $e');
  }

  try {
    // Test getTeacher (assuming ID 1 exists)
    final teacher = await TeacherService.getTeacher(1);
    print('  ✓ getTeacher(1): ${teacher != null ? '✅ Found' : '❌ Not found'}');
    if (teacher != null) {
      print('    Teacher: ${teacher.prenom} ${teacher.nom}');
    }
  } catch (e) {
    print('  ❌ getTeacher() Error: $e');
  }

  try {
    // Test createTeacher
    final result = await TeacherService.createTeacher(
      nom: 'Dupont',
      prenom: 'Jean',
      email: 'jean.dupont@example.com',
      password: 'testpass123',
      specialite: 'Mathematics',
    );
    print('  ✓ createTeacher(): ${result['success'] == 1 ? '✅ Created' : '❌ Failed'}');
    if (result['message'] != null) {
      print('    Message: ${result['message']}');
    }
  } catch (e) {
    print('  ❌ createTeacher() Error: $e');
  }

  print('');
}

Future<void> testSessionService() async {
  print('📅 Testing SessionService...');

  try {
    // Test getAllSessions
    final sessions = await SessionService.getAllSessions();
    print('  ✓ getAllSessions(): ${sessions.isNotEmpty ? '✅ Found ${sessions.length} sessions' : '❌ No sessions found'}');
    if (sessions.isNotEmpty) {
      print('    First session: ${sessions[0].matiere} - ${sessions[0].classe}');
    }
  } catch (e) {
    print('  ❌ getAllSessions() Error: $e');
  }

  try {
    // Test getSession (assuming ID 1 exists)
    final session = await SessionService.getSession(1);
    print('  ✓ getSession(1): ${session != null ? '✅ Found' : '❌ Not found'}');
    if (session != null) {
      print('    Session: ${session.matiere} on ${session.date}');
    }
  } catch (e) {
    print('  ❌ getSession() Error: $e');
  }

  try {
    // Test getTeacherSessions (assuming teacher ID 1 exists)
    final sessions = await SessionService.getTeacherSessions(1);
    print('  ✓ getTeacherSessions(1): ${sessions.isNotEmpty ? '✅ Found ${sessions.length} sessions' : '❌ No sessions'}');
    if (sessions.isNotEmpty) {
      print('    First session: ${sessions[0].matiere}');
    }
  } catch (e) {
    print('  ❌ getTeacherSessions() Error: $e');
  }

  try {
    // Test getTeacherSession
    final session = await SessionService.getTeacherSession(1, 1);
    print('  ✓ getTeacherSession(1, 1): ${session != null ? '✅ Found' : '❌ Not found'}');
  } catch (e) {
    print('  ❌ getTeacherSession() Error: $e');
  }

  try {
    // Test createSession
    final result = await SessionService.createSession(
      enseignantId: 1,
      classeId: 1,
      matiereId: 1,
      dateSeance: '2026-04-15',
      heureDebut: '09:00',
      heureFin: '10:30',
    );
    print('  ✓ createSession(): ${result['success'] == 1 ? '✅ Created' : '❌ Failed'}');
    if (result['message'] != null) {
      print('    Message: ${result['message']}');
    }
  } catch (e) {
    print('  ❌ createSession() Error: $e');
  }

  print('');
}

Future<void> testClassService() async {
  print('🏫 Testing ClassService...');

  try {
    // Test getAllClasses
    final classes = await ClassService.getAllClasses();
    print('  ✓ getAllClasses(): ${classes.isNotEmpty ? '✅ Found ${classes.length} classes' : '❌ No classes found'}');
    if (classes.isNotEmpty) {
      print('    First class: ${classes[0]['nom']}');
    }
  } catch (e) {
    print('  ❌ getAllClasses() Error: $e');
  }

  try {
    // Test getClass (assuming ID 1 exists)
    final classe = await ClassService.getClass(1);
    print('  ✓ getClass(1): ${classe != null ? '✅ Found' : '❌ Not found'}');
    if (classe != null) {
      print('    Class: ${classe['nom']}');
    }
  } catch (e) {
    print('  ❌ getClass() Error: $e');
  }

  try {
    // Test createClass
    final result = await ClassService.createClass(
      nom: 'Test Class',
      niveau: 'Level 1',
    );
    print('  ✓ createClass(): ${result['success'] == 1 ? '✅ Created' : '❌ Failed'}');
    if (result['message'] != null) {
      print('    Message: ${result['message']}');
    }
  } catch (e) {
    print('  ❌ createClass() Error: $e');
  }

  try {
    // Test getAdminStats
    final stats = await ClassService.getAdminStats();
    print('  ✓ getAdminStats(): ${stats['success'] == 1 ? '✅ Retrieved' : '❌ Failed'}');
    if (stats['data'] != null) {
      print('    Stats: ${stats['data']}');
    }
  } catch (e) {
    print('  ❌ getAdminStats() Error: $e');
  }

  print('');
}

Future<void> testAbsenceService() async {
  print('📝 Testing AbsenceService...');

  try {
    // Test recordAbsences
    final result = await AbsenceService.recordAbsences(
      seanceId: 1,
      listAbsence: [
        [1,'absent'],
        [2,'present'],
      ],
    );

    print('  ✓ recordAbsences(): ${result ? '✅ Recorded' : '❌ Failed'}');
  } catch (e) {
    print('  ❌ recordAbsences() Error: $e');
  }

  try {
    // Test getStudentAbsences
    final absences = await AbsenceService.getStudentAbsences(1);
    print('  ✓ getStudentAbsences(1): ${absences.isNotEmpty ? '✅ Found ${absences.length} absences' : '❌ No absences'}');
    if (absences.isNotEmpty) {
      print('    First absence: ${absences[0].status}');
    }
  } catch (e) {
    print('  ❌ getStudentAbsences() Error: $e');
  }

  print('');
}
