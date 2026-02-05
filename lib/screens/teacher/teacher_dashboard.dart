import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../services/lesson_paper_service.dart';
import '../login_selection_screen.dart';
import 'exam_marks_entry_screen.dart';
import 'teacher_upload_recording.dart';
import 'teacher_upload_paper.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final LessonPaperService _lessonPaperService = LessonPaperService();
  late TabController _tabController;

  // Recordings tab filter state
  String? _recordingSelectedGradeId;
  String? _recordingSelectedSubjectId;
  List<Grade> _recordingGrades = [];
  List<Subject> _recordingSubjects = [];

  // Papers tab filter state
  String? _paperSelectedGradeId;
  String? _paperSelectedSubjectId;
  List<Grade> _paperGrades = [];
  List<Subject> _paperSubjects = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldPasswordController,
                decoration: const InputDecoration(labelText: 'Current Password'),
                obscureText: true,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm New Password'),
                obscureText: true,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Required';
                  if (v != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                // Verify old password
                final success = await authProvider.loginTeacher(
                  authProvider.username!,
                  oldPasswordController.text,
                );

                if (success) {
                  try {
                    await _firestoreService.updateTeacher(authProvider.userId!, {
                      'password': newPasswordController.text,
                    });
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password changed successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Current password is incorrect'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Classrooms', icon: Icon(Icons.class_)),
            Tab(text: 'Recordings', icon: Icon(Icons.videocam)),
            Tab(text: 'Papers', icon: Icon(Icons.description)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: _showChangePasswordDialog,
            tooltip: 'Change Password',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClassroomsTab(authProvider),
          _buildRecordingsTab(authProvider),
          _buildPapersTab(authProvider),
        ],
      ),
    );
  }

  int? _extractNumberFromTitle(String title) {
    try {
      final matches = RegExp(r"(\d{1,3})").allMatches(title);
      if (matches.isEmpty) return null;
      // Prefer the last match (often numbering at end)
      final m = matches.last.group(0);
      return m != null ? int.tryParse(m) : null;
    } catch (_) {
      return null;
    }
  }

  bool _isQuestionGrade(String gradeId, List<Grade> grades) {
    final grade = grades.firstWhere((g) => g.id == gradeId, orElse: () => Grade(id: '', name: '', createdAt: DateTime.now()));
    final match = RegExp(r"(\d+)").firstMatch(grade.name);
    if (match != null) {
      final gnum = int.tryParse(match.group(0) ?? '0') ?? 0;
      return (gnum == 3 || gnum == 4 || gnum == 5);
    }
    return false;
  }

  Widget _buildClassroomsTab(AuthProvider authProvider) {
    return StreamBuilder<List<Classroom>>(
      stream: _firestoreService.getTeacherClassrooms(authProvider.userId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final classrooms = snapshot.data ?? [];

        if (classrooms.isEmpty) {
          return const Center(
            child: Text(
              'No classrooms assigned yet',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return StreamBuilder<List<SchoolYear>>(
          stream: _firestoreService.getSchoolYears(),
          builder: (context, sySnapshot) {
            return StreamBuilder<List<Grade>>(
              stream: _firestoreService.getGrades(),
              builder: (context, gradeSnapshot) {
                return StreamBuilder<List<Subject>>(
                  stream: _firestoreService.getSubjects(),
                  builder: (context, subjectSnapshot) {
                    final schoolYears = sySnapshot.data ?? [];
                    final grades = gradeSnapshot.data ?? [];
                    final subjects = subjectSnapshot.data ?? [];

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: classrooms.length,
                      itemBuilder: (context, index) {
                        final classroom = classrooms[index];
                        final schoolYear = schoolYears.firstWhere(
                          (sy) => sy.id == classroom.schoolYearId,
                          orElse: () => SchoolYear(
                            id: '',
                            year: 'Unknown',
                            createdAt: DateTime.now(),
                          ),
                        );
                        final grade = grades.firstWhere(
                          (g) => g.id == classroom.gradeId,
                          orElse: () => Grade(
                            id: '',
                            name: 'Unknown',
                            createdAt: DateTime.now(),
                          ),
                        );
                        final subject = subjects.firstWhere(
                          (s) => s.id == classroom.subjectId,
                          orElse: () => Subject(
                            id: '',
                            name: 'Unknown',
                            createdAt: DateTime.now(),
                          ),
                        );

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExamMarksEntryScreen(
                                    classroom: classroom,
                                    schoolYear: schoolYear,
                                    grade: grade,
                                    subject: subject,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.class_,
                                          color: Colors.green,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              subject.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${grade.name} • ${schoolYear.year}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios, size: 16),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRecordingsTab(AuthProvider authProvider) {
    return Stack(
      children: [
        FutureBuilder<List<Grade>>(
          future: _firestoreService.getGrades().first,
          builder: (context, gradeSnapshot) {
            if (gradeSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (gradeSnapshot.hasError) {
              return Center(child: Text('Error: ${gradeSnapshot.error}'));
            }

            final allGrades = gradeSnapshot.data ?? [];
            _recordingGrades = allGrades;

            return Column(
              children: [
                // Grade Filter
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Grade', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: _recordingSelectedGradeId,
                        hint: const Text('Choose a grade'),
                        items: allGrades
                            .map((g) => DropdownMenuItem(value: g.id, child: Text(g.name)))
                            .toList(),
                        onChanged: (gradeId) {
                          setState(() {
                            _recordingSelectedGradeId = gradeId;
                            _recordingSelectedSubjectId = null;
                            _recordingSubjects = [];
                          });
                          if (gradeId != null) _loadRecordingSubjects(gradeId);
                        },
                      ),
                      if (_recordingSelectedGradeId != null) ...[
                        const SizedBox(height: 16),
                        Text('Select Subject', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: _recordingSelectedSubjectId,
                          hint: const Text('Choose a subject'),
                          items: _recordingSubjects
                              .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                              .toList(),
                          onChanged: (subjectId) {
                            setState(() => _recordingSelectedSubjectId = subjectId);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                // Filtered Recordings List
                if (_recordingSelectedGradeId != null && _recordingSelectedSubjectId != null)
                  Expanded(
                    child: FutureBuilder<List<LessonRecording>>(
                      future: _lessonPaperService.getRecordingsByGradeAndSubject(
                        _recordingSelectedGradeId!,
                        _recordingSelectedSubjectId!,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        final recordings = snapshot.data ?? [];

                        if (recordings.isEmpty) {
                          return const Center(child: Text('No recordings for this selection'));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: recordings.length,
                          itemBuilder: (context, index) {
                            final recording = recordings[index];
                            final displayNumber = recording.questionNumber ?? _extractNumberFromTitle(recording.title);
                            final isQType = _isQuestionGrade(_recordingSelectedGradeId!, _recordingGrades);
                            final label = isQType ? 'Q' : 'Lesson ';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: const Icon(Icons.videocam, color: Colors.blue),
                                title: Row(
                                  children: [
                                    Expanded(child: Text(recording.title)),
                                    if (displayNumber != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '$label$displayNumber',
                                          style: const TextStyle(color: Colors.blue, fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(recording.description),
                                    if (displayNumber != null) const SizedBox(height: 4),
                                    if (displayNumber != null)
                                      Text(
                                        '${isQType ? 'Question' : 'Lesson'} Number: $displayNumber',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                      ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const Text('Edit'),
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Edit coming soon')),
                                        );
                                      },
                                    ),
                                    PopupMenuItem(
                                      child: const Text('Delete'),
                                      onTap: () {
                                        _showDeleteConfirmation(
                                          'Delete Recording',
                                          'Are you sure you want to delete this recording?',
                                          () async {
                                            await _lessonPaperService.deleteLessonRecording(recording.id);
                                            if (mounted) {
                                              setState(() {});
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Recording deleted'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TeacherUploadRecording(),
                ),
              ).then((_) {
                if (mounted) setState(() {});
              });
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Future<void> _loadRecordingSubjects(String gradeId) async {
    try {
      final subjects = await _lessonPaperService.getSubjectsForGrade(gradeId);
      setState(() => _recordingSubjects = subjects);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading subjects: $e')),
        );
      }
    }
  }

  Widget _buildPapersTab(AuthProvider authProvider) {
    return Stack(
      children: [
        FutureBuilder<List<Grade>>(
          future: _firestoreService.getGrades().first,
          builder: (context, gradeSnapshot) {
            if (gradeSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (gradeSnapshot.hasError) {
              return Center(child: Text('Error: ${gradeSnapshot.error}'));
            }

            final allGrades = gradeSnapshot.data ?? [];
            _paperGrades = allGrades;

            return Column(
              children: [
                // Grade Filter
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Grade', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: _paperSelectedGradeId,
                        hint: const Text('Choose a grade'),
                        items: allGrades
                            .map((g) => DropdownMenuItem(value: g.id, child: Text(g.name)))
                            .toList(),
                        onChanged: (gradeId) {
                          setState(() {
                            _paperSelectedGradeId = gradeId;
                            _paperSelectedSubjectId = null;
                            _paperSubjects = [];
                          });
                          if (gradeId != null) _loadPaperSubjects(gradeId);
                        },
                      ),
                      if (_paperSelectedGradeId != null) ...[
                        const SizedBox(height: 16),
                        Text('Select Subject', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: _paperSelectedSubjectId,
                          hint: const Text('Choose a subject'),
                          items: _paperSubjects
                              .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                              .toList(),
                          onChanged: (subjectId) {
                            setState(() => _paperSelectedSubjectId = subjectId);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                // Filtered Papers List
                if (_paperSelectedGradeId != null && _paperSelectedSubjectId != null)
                  Expanded(
                    child: FutureBuilder<List<ExamPaper>>(
                      future: _lessonPaperService.getPapersByGradeAndSubject(
                        _paperSelectedGradeId!,
                        _paperSelectedSubjectId!,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        final papers = snapshot.data ?? [];

                        if (papers.isEmpty) {
                          return const Center(child: Text('No papers for this selection'));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: papers.length,
                          itemBuilder: (context, index) {
                            final paper = papers[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: const Icon(Icons.description, color: Colors.orange),
                                title: Text(paper.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(paper.description),
                                    const SizedBox(height: 4),
                                    Chip(
                                      label: Text(paper.term),
                                      backgroundColor: Colors.orange.withOpacity(0.2),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const Text('Edit'),
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Edit coming soon')),
                                        );
                                      },
                                    ),
                                    PopupMenuItem(
                                      child: const Text('Delete'),
                                      onTap: () {
                                        _showDeleteConfirmation(
                                          'Delete Paper',
                                          'Are you sure you want to delete this paper?',
                                          () async {
                                            await _lessonPaperService.deleteExamPaper(paper.id);
                                            if (mounted) {
                                              setState(() {});
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Paper deleted'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TeacherUploadPaper(),
                ),
              ).then((_) {
                if (mounted) setState(() {});
              });
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Future<void> _loadPaperSubjects(String gradeId) async {
    try {
      final subjects = await _lessonPaperService.getSubjectsForGrade(gradeId);
      setState(() => _paperSubjects = subjects);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading subjects: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}