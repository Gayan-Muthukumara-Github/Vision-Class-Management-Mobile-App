# LessonPaperService API Documentation

Complete reference for the LessonPaperService class for managing lesson recordings and exam papers.

---

## Service Overview

The `LessonPaperService` provides methods to manage lesson recordings and exam papers in Firestore.

**Location**: `lib/services/lesson_paper_service.dart`

---

## 📚 Lesson Recording Methods

### 1. `addLessonRecording()`

Upload a new lesson recording.

```dart
Future<String> addLessonRecording({
  required String teacherId,
  required String gradeId,
  required String subjectId,
  required String title,
  required String description,
  required String youtubeLink,
})
```

**Parameters:**
- `teacherId` - ID of the teacher uploading
- `gradeId` - ID of the grade
- `subjectId` - ID of the subject
- `title` - Recording title (e.g., "Lesson 1")
- `description` - Description of the content
- `youtubeLink` - Complete YouTube URL

**Returns:** Document ID of the created recording

**Example:**
```dart
final recordingId = await lessonPaperService.addLessonRecording(
  teacherId: "teacher123",
  gradeId: "grade5",
  subjectId: "math001",
  title: "Lesson 1: Algebra Basics",
  description: "Introduction to algebraic expressions",
  youtubeLink: "https://www.youtube.com/watch?v=abc123",
);
```

---

### 2. `getTeacherRecordings()`

Get all recordings uploaded by a specific teacher.

```dart
Future<List<LessonRecording>> getTeacherRecordings(String teacherId)
```

**Parameters:**
- `teacherId` - ID of the teacher

**Returns:** List of LessonRecording objects, ordered by creation date (newest first)

**Example:**
```dart
final recordings = await lessonPaperService.getTeacherRecordings("teacher123");
for (var recording in recordings) {
  print('${recording.title}: ${recording.youtubeLink}');
}
```

---

### 3. `getRecordingsByGradeAndSubject()`

Get all recordings for a specific grade and subject.

```dart
Future<List<LessonRecording>> getRecordingsByGradeAndSubject(
  String gradeId,
  String subjectId,
)
```

**Parameters:**
- `gradeId` - ID of the grade
- `subjectId` - ID of the subject

**Returns:** List of LessonRecording objects available for students

**Example:**
```dart
final recordings = await lessonPaperService.getRecordingsByGradeAndSubject(
  "grade5",
  "math001",
);
```

---

### 4. `updateLessonRecording()`

Update details of an existing recording.

```dart
Future<void> updateLessonRecording(
  String recordingId, {
  String? title,
  String? description,
  String? youtubeLink,
})
```

**Parameters:**
- `recordingId` - ID of the recording to update
- `title` - (optional) New title
- `description` - (optional) New description
- `youtubeLink` - (optional) New YouTube link

**Example:**
```dart
await lessonPaperService.updateLessonRecording(
  "recording123",
  title: "Lesson 1: Updated Title",
  description: "Updated description",
);
```

---

### 5. `deleteLessonRecording()`

Delete a lesson recording.

```dart
Future<void> deleteLessonRecording(String recordingId)
```

**Parameters:**
- `recordingId` - ID of the recording to delete

**Example:**
```dart
await lessonPaperService.deleteLessonRecording("recording123");
```

---

## 📄 Exam Paper Methods

### 6. `addExamPaper()`

Upload a new exam paper.

```dart
Future<String> addExamPaper({
  required String teacherId,
  required String gradeId,
  required String subjectId,
  required String term,
  required String title,
  required String description,
  required String fileUrl,
})
```

**Parameters:**
- `teacherId` - ID of the teacher uploading
- `gradeId` - ID of the grade
- `subjectId` - ID of the subject
- `term` - Term selection: "1st Term", "2nd Term", or "3rd Term"
- `title` - Paper title
- `description` - Description of the paper
- `fileUrl` - URL to the PDF file

**Returns:** Document ID of the created paper

**Example:**
```dart
final paperId = await lessonPaperService.addExamPaper(
  teacherId: "teacher123",
  gradeId: "grade5",
  subjectId: "math001",
  term: "1st Term",
  title: "Mathematics Exam Paper 1",
  description: "First term mathematics examination",
  fileUrl: "https://storage.example.com/math_exam_1.pdf",
);
```

---

### 7. `getTeacherPapers()`

Get all papers uploaded by a specific teacher.

```dart
Future<List<ExamPaper>> getTeacherPapers(String teacherId)
```

**Parameters:**
- `teacherId` - ID of the teacher

**Returns:** List of ExamPaper objects, ordered by creation date (newest first)

**Example:**
```dart
final papers = await lessonPaperService.getTeacherPapers("teacher123");
```

---

### 8. `getPapersByGradeSubjectAndTerm()`

Get papers for a specific grade, subject, and term.

```dart
Future<List<ExamPaper>> getPapersByGradeSubjectAndTerm(
  String gradeId,
  String subjectId,
  String term,
)
```

**Parameters:**
- `gradeId` - ID of the grade
- `subjectId` - ID of the subject
- `term` - Term: "1st Term", "2nd Term", or "3rd Term"

**Returns:** List of ExamPaper objects available for download

**Example:**
```dart
final papers = await lessonPaperService.getPapersByGradeSubjectAndTerm(
  "grade5",
  "math001",
  "1st Term",
);
```

---

### 9. `getPapersByGradeAndSubject()`

Get all papers for a specific grade and subject (all terms).

```dart
Future<List<ExamPaper>> getPapersByGradeAndSubject(
  String gradeId,
  String subjectId,
)
```

**Parameters:**
- `gradeId` - ID of the grade
- `subjectId` - ID of the subject

**Returns:** List of all ExamPaper objects for that grade and subject

**Example:**
```dart
final allPapers = await lessonPaperService.getPapersByGradeAndSubject(
  "grade5",
  "math001",
);
```

---

### 10. `updateExamPaper()`

Update details of an existing paper.

```dart
Future<void> updateExamPaper(
  String paperId, {
  String? title,
  String? description,
  String? fileUrl,
})
```

**Parameters:**
- `paperId` - ID of the paper to update
- `title` - (optional) New title
- `description` - (optional) New description
- `fileUrl` - (optional) New file URL

**Example:**
```dart
await lessonPaperService.updateExamPaper(
  "paper123",
  title: "Updated Paper Title",
);
```

---

### 11. `deleteExamPaper()`

Delete an exam paper.

```dart
Future<void> deleteExamPaper(String paperId)
```

**Parameters:**
- `paperId` - ID of the paper to delete

**Example:**
```dart
await lessonPaperService.deleteExamPaper("paper123");
```

---

## 🛠️ Utility Methods

### 12. `getTeacherSubjects()`

Get all unique subjects that a teacher has content for.

```dart
Future<List<Subject>> getTeacherSubjects(String teacherId)
```

**Parameters:**
- `teacherId` - ID of the teacher

**Returns:** List of Subject objects

**Example:**
```dart
final subjects = await lessonPaperService.getTeacherSubjects("teacher123");
```

---

### 13. `getTeacherGrades()`

Get all unique grades that a teacher has content for.

```dart
Future<List<Grade>> getTeacherGrades(String teacherId)
```

**Parameters:**
- `teacherId` - ID of the teacher

**Returns:** List of Grade objects

**Example:**
```dart
final grades = await lessonPaperService.getTeacherGrades("teacher123");
```

---

### 14. `getSubjectsForGrade()`

Get all subjects available in a specific grade.

```dart
Future<List<Subject>> getSubjectsForGrade(String gradeId)
```

**Parameters:**
- `gradeId` - ID of the grade

**Returns:** List of Subject objects

**Example:**
```dart
final subjects = await lessonPaperService.getSubjectsForGrade("grade5");
```

---

## 🔄 Data Models

### LessonRecording
```dart
class LessonRecording {
  final String id;                    // Document ID
  final String teacherId;             // Teacher who uploaded
  final String gradeId;               // Grade level
  final String subjectId;             // Subject
  final String title;                 // Recording title
  final String description;           // Recording description
  final String youtubeLink;           // YouTube URL
  final DateTime createdAt;           // Upload date
  final DateTime? updatedAt;          // Last modified
}
```

### ExamPaper
```dart
class ExamPaper {
  final String id;                    // Document ID
  final String teacherId;             // Teacher who uploaded
  final String gradeId;               // Grade level
  final String subjectId;             // Subject
  final String term;                  // 1st/2nd/3rd Term
  final String title;                 // Paper title
  final String description;           // Paper description
  final String fileUrl;               // PDF URL
  final DateTime createdAt;           // Upload date
  final DateTime? updatedAt;          // Last modified
}
```

---

## ⚠️ Error Handling

All methods throw exceptions on failure. Always wrap calls in try-catch:

```dart
try {
  final recordings = await lessonPaperService.getRecordingsByGradeAndSubject(
    gradeId,
    subjectId,
  );
} catch (e) {
  print('Error: $e');
  // Handle error
}
```

---

## 📝 Complete Example

### Teacher Upload Flow
```dart
class TeacherUploadExample {
  final LessonPaperService _service = LessonPaperService();
  
  Future<void> uploadLessonRecording() async {
    try {
      final recordingId = await _service.addLessonRecording(
        teacherId: "currentTeacherId",
        gradeId: "grade5",
        subjectId: "math",
        title: "Quadratic Equations",
        description: "Learn about quadratic equations and solutions",
        youtubeLink: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      );
      
      print("Recording created: $recordingId");
      
      // View all recordings
      final recordings = await _service.getTeacherRecordings("currentTeacherId");
      print("Total recordings: ${recordings.length}");
      
    } catch (e) {
      print("Error uploading: $e");
    }
  }
}
```

### Student View Flow
```dart
class StudentViewExample {
  final LessonPaperService _service = LessonPaperService();
  
  Future<void> viewContent() async {
    try {
      // Get recordings for a subject
      final recordings = await _service.getRecordingsByGradeAndSubject(
        "grade5",
        "math",
      );
      
      // Watch first recording
      if (recordings.isNotEmpty) {
        final url = recordings[0].youtubeLink;
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
      
      // Get papers for a term
      final papers = await _service.getPapersByGradeSubjectAndTerm(
        "grade5",
        "math",
        "1st Term",
      );
      
      // Download first paper
      if (papers.isNotEmpty) {
        final url = papers[0].fileUrl;
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
      
    } catch (e) {
      print("Error viewing: $e");
    }
  }
}
```

---

## 🔍 Firestore Queries Used

The service uses the following Firestore queries:

```firestore
// Get teacher's recordings
/lesson_recordings where teacherId == "teacher123" orderBy createdAt desc

// Get recordings by grade and subject
/lesson_recordings where gradeId == "grade5" AND subjectId == "math" orderBy createdAt desc

// Get teacher's papers
/exam_papers where teacherId == "teacher123" orderBy createdAt desc

// Get papers by grade, subject, and term
/exam_papers where gradeId == "grade5" AND subjectId == "math" AND term == "1st Term" orderBy createdAt desc

// Get papers by grade and subject
/exam_papers where gradeId == "grade5" AND subjectId == "math" orderBy createdAt desc
```

---

## 🎯 Performance Tips

1. **Cache Results**: Store results in local variables to avoid repeated queries
2. **Pagination**: For large lists, implement pagination
3. **Query Optimization**: Always filter by necessary fields
4. **Indexing**: Create Firestore indexes for complex queries

---

## 📱 Platform Compatibility

✅ Works on:
- Android
- iOS
- Web
- macOS
- Windows
- Linux

---

**Last Updated**: December 24, 2025  
**Version**: 1.0
