import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate unique ID
  Future<String> generateUniqueId(String collection) async {
    final querySnapshot = await _firestore
        .collection(collection)
        .orderBy('uniqueId', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return '00001';
    }

    final lastId = querySnapshot.docs.first.data()['uniqueId'] as String;
    final nextId = (int.parse(lastId) + 1).toString().padLeft(5, '0');
    return nextId;
  }

  // Teacher CRUD
  Future<void> createTeacher(Teacher teacher) async {
    await _firestore.collection('teachers').add(teacher.toFirestore());
  }

  Future<void> updateTeacher(String id, Map<String, dynamic> data) async {
    await _firestore.collection('teachers').doc(id).update(data);
  }

  Future<void> deleteTeacher(String id) async {
    await _firestore.collection('teachers').doc(id).delete();
  }

  Stream<List<Teacher>> getTeachers() {
    return _firestore.collection('teachers').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Teacher.fromFirestore(doc)).toList());
  }

  // Student CRUD
  Future<void> createStudent(Student student) async {
    await _firestore.collection('students').add(student.toFirestore());
  }

  Future<void> updateStudent(String id, Map<String, dynamic> data) async {
    await _firestore.collection('students').doc(id).update(data);
  }

  Future<void> deleteStudent(String id) async {
    await _firestore.collection('students').doc(id).delete();
  }

  Stream<List<Student>> getStudents() {
    return _firestore.collection('students').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList());
  }

  Stream<List<Student>> getActiveStudents() {
    return _firestore
        .collection('students')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList());
  }

  // School Year CRUD
  Future<void> createSchoolYear(SchoolYear schoolYear) async {
    await _firestore.collection('school_years').add(schoolYear.toFirestore());
  }

  Future<void> updateSchoolYear(String id, String year) async {
    await _firestore.collection('school_years').doc(id).update({'year': year});
  }

  Future<void> deleteSchoolYear(String id) async {
    await _firestore.collection('school_years').doc(id).delete();
  }

  Stream<List<SchoolYear>> getSchoolYears() {
    return _firestore.collection('school_years').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => SchoolYear.fromFirestore(doc)).toList());
  }

  // Grade CRUD
  Future<void> createGrade(Grade grade) async {
    await _firestore.collection('grades').add(grade.toFirestore());
  }

  Future<void> updateGrade(String id, String name) async {
    await _firestore.collection('grades').doc(id).update({'name': name});
  }

  Future<void> deleteGrade(String id) async {
    await _firestore.collection('grades').doc(id).delete();
  }

  Stream<List<Grade>> getGrades() {
    return _firestore.collection('grades').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Grade.fromFirestore(doc)).toList());
  }

  // Subject CRUD
  Future<void> createSubject(Subject subject) async {
    await _firestore.collection('subjects').add(subject.toFirestore());
  }

  Future<void> updateSubject(String id, String name) async {
    await _firestore.collection('subjects').doc(id).update({'name': name});
  }

  Future<void> deleteSubject(String id) async {
    await _firestore.collection('subjects').doc(id).delete();
  }

  Stream<List<Subject>> getSubjects() {
    return _firestore.collection('subjects').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Subject.fromFirestore(doc)).toList());
  }

  // Classroom CRUD
  Future<bool> checkClassroomExists(
      String schoolYearId, String gradeId, String subjectId) async {
    final querySnapshot = await _firestore
        .collection('classrooms')
        .where('schoolYearId', isEqualTo: schoolYearId)
        .where('gradeId', isEqualTo: gradeId)
        .where('subjectId', isEqualTo: subjectId)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> createClassroom(Classroom classroom) async {
    await _firestore.collection('classrooms').add(classroom.toFirestore());
  }

  Future<void> updateClassroom(String id, Map<String, dynamic> data) async {
    await _firestore.collection('classrooms').doc(id).update(data);
  }

  Future<void> deleteClassroom(String id) async {
    await _firestore.collection('classrooms').doc(id).delete();
    // Delete student assignments
    final assignments = await _firestore
        .collection('student_classroom_assignments')
        .where('classroomId', isEqualTo: id)
        .get();
    for (var doc in assignments.docs) {
      await doc.reference.delete();
    }
  }

  Stream<List<Classroom>> getClassrooms() {
    return _firestore.collection('classrooms').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Classroom.fromFirestore(doc)).toList());
  }

  Stream<List<Classroom>> getTeacherClassrooms(String teacherId) {
    return _firestore
        .collection('classrooms')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Classroom.fromFirestore(doc)).toList());
  }

  // Student Classroom Assignments
  Future<void> assignStudentToClassroom(String studentId, String classroomId) async {
    // Check if already assigned
    final existing = await _firestore
        .collection('student_classroom_assignments')
        .where('studentId', isEqualTo: studentId)
        .where('classroomId', isEqualTo: classroomId)
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      await _firestore.collection('student_classroom_assignments').add({
        'studentId': studentId,
        'classroomId': classroomId,
        'createdAt': Timestamp.now(),
      });
    }
  }

  Future<void> removeStudentFromClassroom(String studentId, String classroomId) async {
    final querySnapshot = await _firestore
        .collection('student_classroom_assignments')
        .where('studentId', isEqualTo: studentId)
        .where('classroomId', isEqualTo: classroomId)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<List<Student>> getClassroomStudents(String classroomId) async {
    final assignments = await _firestore
        .collection('student_classroom_assignments')
        .where('classroomId', isEqualTo: classroomId)
        .get();

    final studentIds = assignments.docs.map((doc) => doc.data()['studentId'] as String).toList();

    if (studentIds.isEmpty) return [];

    final students = await _firestore
        .collection('students')
        .where(FieldPath.documentId, whereIn: studentIds)
        .get();

    return students.docs.map((doc) => Student.fromFirestore(doc)).toList();
  }

  // Exam Marks
  Future<void> createOrUpdateExamMark(ExamMark examMark) async {
    final existing = await _firestore
        .collection('exam_marks')
        .where('classroomId', isEqualTo: examMark.classroomId)
        .where('studentId', isEqualTo: examMark.studentId)
        .where('month', isEqualTo: examMark.month)
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      await _firestore.collection('exam_marks').add(examMark.toFirestore());
    } else {
      await _firestore
          .collection('exam_marks')
          .doc(existing.docs.first.id)
          .update({
        'marks': examMark.marks,
        'remarks': examMark.remarks,
        'examType': examMark.examType,
        'updatedAt': Timestamp.now(),
        'updatedBy': examMark.updatedBy,
      });
    }
  }

  Future<List<ExamMark>> getStudentMarks(String classroomId, String month) async {
    final querySnapshot = await _firestore
        .collection('exam_marks')
        .where('classroomId', isEqualTo: classroomId)
        .where('month', isEqualTo: month)
        .get();

    return querySnapshot.docs.map((doc) => ExamMark.fromFirestore(doc)).toList();
  }

  Future<List<ExamMark>> getStudentAllMarks(
      String studentId, String schoolYearId, String gradeId, String subjectId) async {
    // First get the classroom
    final classrooms = await _firestore
        .collection('classrooms')
        .where('schoolYearId', isEqualTo: schoolYearId)
        .where('gradeId', isEqualTo: gradeId)
        .where('subjectId', isEqualTo: subjectId)
        .limit(1)
        .get();

    if (classrooms.docs.isEmpty) return [];

    final classroomId = classrooms.docs.first.id;

    final marks = await _firestore
        .collection('exam_marks')
        .where('classroomId', isEqualTo: classroomId)
        .where('studentId', isEqualTo: studentId)
        .get();

    return marks.docs.map((doc) => ExamMark.fromFirestore(doc)).toList();
  }

  // Get student's school years, grades, subjects
  Future<List<Map<String, dynamic>>> getStudentAcademicData(String studentId) async {
    final assignments = await _firestore
        .collection('student_classroom_assignments')
        .where('studentId', isEqualTo: studentId)
        .get();

    final classroomIds = assignments.docs.map((doc) => doc.data()['classroomId'] as String).toList();

    if (classroomIds.isEmpty) return [];

    final classrooms = await _firestore
        .collection('classrooms')
        .where(FieldPath.documentId, whereIn: classroomIds)
        .get();

    return classrooms.docs.map((doc) {
      final data = doc.data();
      return {
        'classroomId': doc.id,
        'schoolYearId': data['schoolYearId'],
        'gradeId': data['gradeId'],
        'subjectId': data['subjectId'],
      };
    }).toList();
  }
}