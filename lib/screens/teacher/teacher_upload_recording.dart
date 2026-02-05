import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/lesson_paper_service.dart';

class TeacherUploadRecording extends StatefulWidget {
  const TeacherUploadRecording({super.key});

  @override
  State<TeacherUploadRecording> createState() => _TeacherUploadRecordingState();
}

class _TeacherUploadRecordingState extends State<TeacherUploadRecording> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final LessonPaperService _lessonPaperService = LessonPaperService();

  late Teacher _teacher;
  List<Grade> _grades = [];
  List<Subject> _subjects = [];
  
  String? _selectedGradeId;
  String? _selectedSubjectId;
  int? _selectedQuestionNumber;
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _youtubeLinkController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTeacherAndGrades();
  }

  Future<void> _loadTeacherAndGrades() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final teacherId = authProvider.userId!;
      final teacherDoc = await _firestoreService.getTeacherById(teacherId);
      if (teacherDoc != null && mounted) {
        setState(() => _teacher = teacherDoc);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading teacher: $e')),
        );
      }
    }
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    try {
      final grades = await _firestoreService.getGrades().first;
      setState(() {
        _grades = grades;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading grades: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSubjects(String gradeId) async {
    try {
      final subjects = await _lessonPaperService.getSubjectsForGrade(gradeId);
      setState(() {
        _subjects = subjects;
        _selectedSubjectId = null;
        _selectedQuestionNumber = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading subjects: $e')),
        );
      }
    }
  }

  Future<void> _uploadRecording() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGradeId == null || _selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select grade and subject')),
      );
      return;
    }
    if (_selectedQuestionNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select question number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _lessonPaperService.addLessonRecording(
        teacherId: _teacher.id,
        gradeId: _selectedGradeId!,
        subjectId: _selectedSubjectId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        youtubeLink: _youtubeLinkController.text.trim(),
        questionNumber: _selectedQuestionNumber!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recording uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Recording'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grade Selection
                    Text(
                      'Select Grade',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedGradeId,
                      hint: const Text('Choose a grade'),
                      items: _grades.map((grade) {
                        return DropdownMenuItem(
                          value: grade.id,
                          child: Text(grade.name),
                        );
                      }).toList(),
                      onChanged: (gradeId) {
                        if (gradeId != null) {
                          setState(() {
                            _selectedGradeId = gradeId;
                            _selectedQuestionNumber = null;
                          });
                          _loadSubjects(gradeId);
                        }
                      },
                      validator: (value) =>
                          value == null ? 'Please select a grade' : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Question/Lesson Number Selection (dynamic)
                    Builder(builder: (context) {
                      bool isQuestionType = false;
                      if (_selectedGradeId != null) {
                        final gradeObj = _grades.firstWhere(
                            (g) => g.id == _selectedGradeId,
                            orElse: () => Grade(id: '', name: '', createdAt: DateTime.now()));
                        final match = RegExp(r"(\d+)").firstMatch(gradeObj.name);
                        if (match != null) {
                          final gnum = int.tryParse(match.group(0) ?? '0') ?? 0;
                          isQuestionType = (gnum == 3 || gnum == 4 || gnum == 5);
                        }
                      }

                      final label = isQuestionType ? 'Select Question Number' : 'Select Lesson Number';
                      final hint = isQuestionType ? 'Choose question number' : 'Choose lesson number';
                      final validatorMsg = isQuestionType ? 'Please select a question number' : 'Please select a lesson number';

                      int max = isQuestionType ? 240 : 40;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _selectedQuestionNumber,
                            hint: Text(hint),
                            items: List<int>.generate(max, (i) => i + 1)
                                .map((n) => DropdownMenuItem(
                                      value: n,
                                      child: Text(isQuestionType ? 'Q$n' : 'Lesson$n'),
                                    ))
                                .toList(),
                            onChanged: (num) {
                              if (num != null) setState(() => _selectedQuestionNumber = num);
                            },
                            validator: (value) => value == null ? validatorMsg : null,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),

                    // Subject Selection
                    Text(
                      'Select Subject',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSubjectId,
                      hint: const Text('Choose a subject'),
                      items: _subjects.map((subject) {
                        return DropdownMenuItem(
                          value: subject.id,
                          child: Text(subject.name),
                        );
                      }).toList(),
                      onChanged: (subjectId) {
                        if (subjectId != null) {
                          setState(() => _selectedSubjectId = subjectId);
                        }
                      },
                      validator: (value) =>
                          value == null ? 'Please select a subject' : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      'Title',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Lesson 1, Question 3',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Describe the content of this recording',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Description is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // YouTube Link
                    Text(
                      'YouTube Link',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _youtubeLinkController,
                      decoration: InputDecoration(
                        hintText: 'https://www.youtube.com/watch?v=...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.link),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'YouTube link is required';
                        }
                        if (!value!.contains('youtube.com')) {
                          return 'Please enter a valid YouTube link';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Upload Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _uploadRecording,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Upload Recording'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _youtubeLinkController.dispose();
    super.dispose();
  }
}
