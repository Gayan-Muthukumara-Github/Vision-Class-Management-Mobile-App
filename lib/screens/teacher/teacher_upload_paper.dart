import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/lesson_paper_service.dart';

class TeacherUploadPaper extends StatefulWidget {
  const TeacherUploadPaper({super.key});

  @override
  State<TeacherUploadPaper> createState() => _TeacherUploadPaperState();
}

class _TeacherUploadPaperState extends State<TeacherUploadPaper> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final LessonPaperService _lessonPaperService = LessonPaperService();

  late Teacher _teacher;
  List<Grade> _grades = [];
  List<Subject> _subjects = [];

  String? _selectedGradeId;
  String? _selectedSubjectId;
  String? _selectedTerm;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _fileUrlController = TextEditingController();

  bool _isLoading = false;

  final List<String> _terms = ['1st Term', '2nd Term', '3rd Term'];

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
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading subjects: $e')),
        );
      }
    }
  }

  Future<void> _uploadPaper() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGradeId == null ||
        _selectedSubjectId == null ||
        _selectedTerm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select grade, subject, and term')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _lessonPaperService.addExamPaper(
        teacherId: _teacher.id,
        gradeId: _selectedGradeId!,
        subjectId: _selectedSubjectId!,
        term: _selectedTerm!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        fileUrl: _fileUrlController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paper uploaded successfully'),
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
        title: const Text('Upload Exam Paper'),
        backgroundColor: Colors.orange,
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
                          setState(() => _selectedGradeId = gradeId);
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

                    // Term Selection
                    Text(
                      'Select Term',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedTerm,
                      hint: const Text('Choose a term'),
                      items: _terms.map((term) {
                        return DropdownMenuItem(
                          value: term,
                          child: Text(term),
                        );
                      }).toList(),
                      onChanged: (term) {
                        if (term != null) {
                          setState(() => _selectedTerm = term);
                        }
                      },
                      validator: (value) =>
                          value == null ? 'Please select a term' : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      'Paper Title',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Mathematics Exam Paper 1',
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
                        hintText: 'Provide details about this exam paper',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Description is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // File URL
                    Text(
                      'File URL (PDF)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _fileUrlController,
                      decoration: InputDecoration(
                        hintText: 'Upload file link or URL',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.attachment),
                        helperText: 'File should be in PDF format',
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'File URL is required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Upload Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _uploadPaper,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Upload Paper'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.orange,
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
    _fileUrlController.dispose();
    super.dispose();
  }
}
