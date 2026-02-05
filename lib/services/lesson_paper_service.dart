import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class LessonPaperService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ LESSON RECORDING METHODS ============

  /// Add a new lesson recording
  Future<String> addLessonRecording({
    required String teacherId,
    required String gradeId,
    required String subjectId,
    required String title,
    required String description,
    required String youtubeLink,
    required int questionNumber,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('lesson_recordings').add({
        'teacherId': teacherId,
        'gradeId': gradeId,
        'subjectId': subjectId,
        'title': title,
        'description': description,
        'youtubeLink': youtubeLink,
        'questionNumber': questionNumber,
        'createdAt': Timestamp.now(),
        'updatedAt': null,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add lesson recording: $e');
    }
  }

  /// Get all lesson recordings for a teacher
  Future<List<LessonRecording>> getTeacherRecordings(String teacherId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('lesson_recordings')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      List<LessonRecording> recordings = snapshot.docs
          .map((doc) => LessonRecording.fromFirestore(doc))
          .toList();
      
      // Sort by createdAt descending in Dart
      recordings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return recordings;
    } catch (e) {
      throw Exception('Failed to fetch teacher recordings: $e');
    }
  }

  /// Get lesson recordings by grade and subject
  Future<List<LessonRecording>> getRecordingsByGradeAndSubject(
    String gradeId,
    String subjectId,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('lesson_recordings')
          .where('gradeId', isEqualTo: gradeId)
          .where('subjectId', isEqualTo: subjectId)
          .get();

      List<LessonRecording> recordings = snapshot.docs
          .map((doc) => LessonRecording.fromFirestore(doc))
          .toList();
      
      // Sort by createdAt descending in Dart
      recordings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return recordings;
    } catch (e) {
      throw Exception('Failed to fetch recordings: $e');
    }
  }

  /// Update lesson recording
  Future<void> updateLessonRecording(
    String recordingId, {
    String? title,
    String? description,
    String? youtubeLink,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (youtubeLink != null) updates['youtubeLink'] = youtubeLink;
      updates['updatedAt'] = Timestamp.now();

      await _firestore
          .collection('lesson_recordings')
          .doc(recordingId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update lesson recording: $e');
    }
  }

  /// Delete lesson recording
  Future<void> deleteLessonRecording(String recordingId) async {
    try {
      await _firestore.collection('lesson_recordings').doc(recordingId).delete();
    } catch (e) {
      throw Exception('Failed to delete lesson recording: $e');
    }
  }

  // ============ EXAM PAPER METHODS ============

  /// Add a new exam paper
  Future<String> addExamPaper({
    required String teacherId,
    required String gradeId,
    required String subjectId,
    required String term,
    required String title,
    required String description,
    required String fileUrl,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('exam_papers').add({
        'teacherId': teacherId,
        'gradeId': gradeId,
        'subjectId': subjectId,
        'term': term,
        'title': title,
        'description': description,
        'fileUrl': fileUrl,
        'createdAt': Timestamp.now(),
        'updatedAt': null,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add exam paper: $e');
    }
  }

  /// Get all exam papers for a teacher
  Future<List<ExamPaper>> getTeacherPapers(String teacherId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('exam_papers')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      List<ExamPaper> papers = snapshot.docs
          .map((doc) => ExamPaper.fromFirestore(doc))
          .toList();
      
      // Sort by createdAt descending in Dart
      papers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return papers;
    } catch (e) {
      throw Exception('Failed to fetch teacher papers: $e');
    }
  }

  /// Get exam papers by grade, subject, and term
  Future<List<ExamPaper>> getPapersByGradeSubjectAndTerm(
    String gradeId,
    String subjectId,
    String term,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('exam_papers')
          .where('gradeId', isEqualTo: gradeId)
          .where('subjectId', isEqualTo: subjectId)
          .where('term', isEqualTo: term)
          .get();

      List<ExamPaper> papers = snapshot.docs
          .map((doc) => ExamPaper.fromFirestore(doc))
          .toList();
      
      // Sort by createdAt descending in Dart
      papers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return papers;
    } catch (e) {
      throw Exception('Failed to fetch exam papers: $e');
    }
  }

  /// Get exam papers by grade and subject (all terms)
  Future<List<ExamPaper>> getPapersByGradeAndSubject(
    String gradeId,
    String subjectId,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('exam_papers')
          .where('gradeId', isEqualTo: gradeId)
          .where('subjectId', isEqualTo: subjectId)
          .get();

      List<ExamPaper> papers = snapshot.docs
          .map((doc) => ExamPaper.fromFirestore(doc))
          .toList();
      
      // Sort by createdAt descending in Dart
      papers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return papers;
    } catch (e) {
      throw Exception('Failed to fetch exam papers: $e');
    }
  }

  /// Update exam paper
  Future<void> updateExamPaper(
    String paperId, {
    String? title,
    String? description,
    String? fileUrl,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (fileUrl != null) updates['fileUrl'] = fileUrl;
      updates['updatedAt'] = Timestamp.now();

      await _firestore
          .collection('exam_papers')
          .doc(paperId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update exam paper: $e');
    }
  }

  /// Delete exam paper
  Future<void> deleteExamPaper(String paperId) async {
    try {
      await _firestore.collection('exam_papers').doc(paperId).delete();
    } catch (e) {
      throw Exception('Failed to delete exam paper: $e');
    }
  }

  // ============ UTILITY METHODS ============

  /// Get all unique subjects for a teacher across all grades
  Future<List<Subject>> getTeacherSubjects(String teacherId) async {
    try {
      QuerySnapshot recordingsSnapshot = await _firestore
          .collection('lesson_recordings')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      QuerySnapshot papersSnapshot = await _firestore
          .collection('exam_papers')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      Set<String> subjectIds = {};
      for (var doc in recordingsSnapshot.docs) {
        subjectIds.add(doc['subjectId']);
      }
      for (var doc in papersSnapshot.docs) {
        subjectIds.add(doc['subjectId']);
      }

      List<Subject> subjects = [];
      for (String subjectId in subjectIds) {
        DocumentSnapshot doc =
            await _firestore.collection('subjects').doc(subjectId).get();
        if (doc.exists) {
          subjects.add(Subject.fromFirestore(doc));
        }
      }

      return subjects;
    } catch (e) {
      throw Exception('Failed to fetch teacher subjects: $e');
    }
  }

  /// Get all unique grades for a teacher across all recordings and papers
  Future<List<Grade>> getTeacherGrades(String teacherId) async {
    try {
      QuerySnapshot recordingsSnapshot = await _firestore
          .collection('lesson_recordings')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      QuerySnapshot papersSnapshot = await _firestore
          .collection('exam_papers')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      Set<String> gradeIds = {};
      for (var doc in recordingsSnapshot.docs) {
        gradeIds.add(doc['gradeId']);
      }
      for (var doc in papersSnapshot.docs) {
        gradeIds.add(doc['gradeId']);
      }

      List<Grade> grades = [];
      for (String gradeId in gradeIds) {
        DocumentSnapshot doc =
            await _firestore.collection('grades').doc(gradeId).get();
        if (doc.exists) {
          grades.add(Grade.fromFirestore(doc));
        }
      }

      return grades;
    } catch (e) {
      throw Exception('Failed to fetch teacher grades: $e');
    }
  }

  /// Get subjects for a specific grade
  Future<List<Subject>> getSubjectsForGrade(String gradeId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('classrooms')
          .where('gradeId', isEqualTo: gradeId)
          .get();

      Set<String> subjectIds = {};
      for (var doc in snapshot.docs) {
        subjectIds.add(doc['subjectId']);
      }

      List<Subject> subjects = [];
      for (String subjectId in subjectIds) {
        DocumentSnapshot doc =
            await _firestore.collection('subjects').doc(subjectId).get();
        if (doc.exists) {
          subjects.add(Subject.fromFirestore(doc));
        }
      }

      return subjects;
    } catch (e) {
      throw Exception('Failed to fetch subjects for grade: $e');
    }
  }
}
