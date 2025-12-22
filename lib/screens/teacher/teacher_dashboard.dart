import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../login_selection_screen.dart';
import 'exam_marks_entry_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final FirestoreService _firestoreService = FirestoreService();

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
      body: StreamBuilder<List<Classroom>>(
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
                                            crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }
}