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
    final now = DateTime.now().millisecondsSinceEpoch;
    final email = 'auth_test_$now@example.com';
    const password = 'testpass123';

    final created = await TeacherService.createTeacher(
      nom: 'Auth',
      prenom: 'Tester',
      email: email,
      password: password,
      specialite: 'Testing',
    );

    if (created['success'] != 1) {
      print('  ✓ login(): ❌ FAILED');
      print('    Message: Could not prepare test user: ${created['message']}');
      print('');
      return;
    }

    final result = await AuthService.login(email, password);
    print('  ✓ login(): ${result['success'] == 1 ? '✅ SUCCESS' : '❌ FAILED'}');
    if (result['user'] != null) {
      print('    User: ${result['user']}');
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
      print('    First student: ${students[0].utilisateur.nom}');
    }
  } catch (e) {
    print('  ❌ getAllStudents() Error: $e');
  }

  try {
    // Test getStudent (assuming ID 1 exists)
    final student = await StudentService.getStudent(1);
    print('  ✓ getStudent(1): ${student != null ? '✅ Found' : '❌ Not found'}');
    if (student != null) {
      print('    Student: ${student.utilisateur.prenom} ${student.utilisateur.nom}');
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
    if (absences == null) {
      print('  ✓ getStudentAbsences(1): ❌ No absences');
    } else {
      print('  ✓ getStudentAbsences(1): ${absences.$1.isNotEmpty ? '✅ Found ${absences.$1.length} absences' : '❌ No absences'}');
    }
  } catch (e) {
    print('  ❌ getStudentAbsences() Error: $e');
  }

  try {
    // Test getStudentProfile
    final profile = await StudentService.getStudentProfile(1);
    print('  ✓ getStudentProfile(1): ${profile != null ? '✅ Retrieved' : '❌ Failed'}');
    if (profile != null) {
      print('    Data: $profile');
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
      print('    Session: ${session.matiere ?? 'N/A'} on ${session.date?.toIso8601String() ?? 'N/A'}');
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
    // Test getTeacherSession with a real session ID belonging to teacher 1
    final teacherSessions = await SessionService.getTeacherSessions(1);
    if (teacherSessions.isEmpty) {
      print('  ✓ getTeacherSession(dynamic): ❌ No sessions found for teacher 1');
    } else {
      final sessionId = teacherSessions.first.id;
      if (sessionId == null) {
        print('  ✓ getTeacherSession(dynamic): ❌ Session id is null');
      } else {
        final session = await SessionService.getTeacherSession(1, sessionId);
        print('  ✓ getTeacherSession(1, $sessionId): ${session != null ? '✅ Found' : '❌ Not found'}');
      }
    }
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
      heureDebut: '09:00:00',
      heureFin: '10:30:00',
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
    // Test recordAbsences with a real session and real students
    final sessions = await SessionService.getAllSessions();
    final students = await StudentService.getAllStudents();

    if (sessions.isEmpty || students.isEmpty) {
      print('  ✓ recordAbsences(): ❌ Missing sessions or students for test');
    } else {
      final seanceId = sessions.first.id;
      if (seanceId == null) {
        print('  ✓ recordAbsences(): ❌ Selected session has null id');
      } else {
        final selected = students.take(2).toList();
        final payload = <List<dynamic>>[];

        for (var i = 0; i < selected.length; i++) {
          payload.add([selected[i].id, i.isEven ? 'absent' : 'present']);
        }

        final result = await AbsenceService.recordAbsences(
          seanceId: seanceId,
          listAbsence: payload,
        );

        print('  ✓ recordAbsences(): ${result['success'] == 1 ? '✅ Recorded' : '❌ Failed'}');
        print('    Message: ${result['message'] ?? 'No message'}');
        print('    Payload: seanceId=$seanceId, listAbsence=$payload');
      }
    }
  } catch (e) {
    print('  ❌ recordAbsences() Error: $e');
  }

  try {
    // Test getStudentAbsences
    final absences = await AbsenceService.getStudentAbsences(1);
    if (absences == null) {
      print('  ✓ getStudentAbsences(1): ❌ No absences');
    } else {
      print('  ✓ getStudentAbsences(1): ${absences.$1.isNotEmpty ? '✅ Found ${absences.$1.length} absences' : '❌ No absences'}');
      if (absences.$1.isNotEmpty) {
        print('    First absence: ${absences.$1[0].status}');
      }
    }
  } catch (e) {
    print('  ❌ getStudentAbsences() Error: $e');
  }

  print('');
}
