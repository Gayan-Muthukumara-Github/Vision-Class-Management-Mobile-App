import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';

class ClassroomsManagementScreen extends StatefulWidget {
  const ClassroomsManagementScreen({super.key});

  @override
  State<ClassroomsManagementScreen> createState() => _ClassroomsManagementScreenState();
}

class _ClassroomsManagementScreenState extends State<ClassroomsManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _showCreateClassroomDialog() async {
    String? selectedSchoolYearId;
    String? selectedGradeId;
    String? selectedSubjectId;
    String? selectedTeacherId;

    final schoolYears = await _firestoreService.getSchoolYears().first;
    final grades = await _firestoreService.getGrades().first;
    final subjects = await _firestoreService.getSubjects().first;
    final teachers = await _firestoreService.getTeachers().first;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Classroom'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'School Year'),
                  value: selectedSchoolYearId,
                  items: schoolYears.map((sy) {
                    return DropdownMenuItem(value: sy.id, child: Text(sy.year));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedSchoolYearId = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Grade'),
                  value: selectedGradeId,
                  items: grades.map((g) {
                    return DropdownMenuItem(value: g.id, child: Text(g.name));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedGradeId = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Subject'),
                  value: selectedSubjectId,
                  items: subjects.map((s) {
                    return DropdownMenuItem(value: s.id, child: Text(s.name));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedSubjectId = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Teacher (Optional)'),
                  value: selectedTeacherId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('No teacher')),
                    ...teachers.where((t) => t.isActive).map((t) {
                      return DropdownMenuItem(
                        value: t.id,
                        child: Text('${t.firstName} ${t.lastName}'),
                      );
                    }),
                  ],
                  onChanged: (value) => setState(() => selectedTeacherId = value),
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
                if (selectedSchoolYearId == null ||
                    selectedGradeId == null ||
                    selectedSubjectId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select school year, grade, and subject'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Check if classroom already exists
                final exists = await _firestoreService.checkClassroomExists(
                  selectedSchoolYearId!,
                  selectedGradeId!,
                  selectedSubjectId!,
                );

                if (exists) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('This classroom already exists'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                try {
                  final classroom = Classroom(
                    id: '',
                    schoolYearId: selectedSchoolYearId!,
                    gradeId: selectedGradeId!,
                    subjectId: selectedSubjectId!,
                    teacherId: selectedTeacherId,
                    createdAt: DateTime.now(),
                  );
                  await _firestoreService.createClassroom(classroom);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Classroom created'),
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
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignTeacherDialog(Classroom classroom) async {
    final teachers = await _firestoreService.getTeachers().first;
    String? selectedTeacherId = classroom.teacherId;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Assign Teacher'),
          content: DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Teacher'),
            value: selectedTeacherId,
            items: [
              const DropdownMenuItem(value: null, child: Text('No teacher')),
              ...teachers.where((t) => t.isActive).map((t) {
                return DropdownMenuItem(
                  value: t.id,
                  child: Text('${t.firstName} ${t.lastName}'),
                );
              }),
            ],
            onChanged: (value) => setState(() => selectedTeacherId = value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _firestoreService.updateClassroom(classroom.id, {
                    'teacherId': selectedTeacherId,
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Teacher assigned'),
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
              },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  void _showManageStudentsDialog(Classroom classroom) async {
    final allStudents = await _firestoreService.getActiveStudents().first;
    final assignedStudents = await _firestoreService.getClassroomStudents(classroom.id);
    final assignedStudentIds = assignedStudents.map((s) => s.id).toSet();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Students'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: allStudents.length,
            itemBuilder: (context, index) {
              final student = allStudents[index];
              final isAssigned = assignedStudentIds.contains(student.id);

              return CheckboxListTile(
                title: Text('${student.firstName} ${student.lastName}'),
                subtitle: Text('Index: ${student.uniqueId}'),
                value: isAssigned,
                onChanged: (value) async {
                  if (value == true) {
                    await _firestoreService.assignStudentToClassroom(
                      student.id,
                      classroom.id,
                    );
                  } else {
                    await _firestoreService.removeStudentFromClassroom(
                      student.id,
                      classroom.id,
                    );
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    _showManageStudentsDialog(classroom);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteClassroom(Classroom classroom) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Classroom'),
        content: const Text('Are you sure you want to delete this classroom?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await _firestoreService.deleteClassroom(classroom.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Classroom deleted'),
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
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classrooms Management'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateClassroomDialog,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Classroom>>(
        stream: _firestoreService.getClassrooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final classrooms = snapshot.data ?? [];

          if (classrooms.isEmpty) {
            return const Center(child: Text('No classrooms found'));
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
                      return StreamBuilder<List<Teacher>>(
                        stream: _firestoreService.getTeachers(),
                        builder: (context, teacherSnapshot) {
                          final schoolYears = sySnapshot.data ?? [];
                          final grades = gradeSnapshot.data ?? [];
                          final subjects = subjectSnapshot.data ?? [];
                          final teachers = teacherSnapshot.data ?? [];

                          return ListView.builder(
                            padding: const EdgeInsets.all(8),
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
                              final teacher = classroom.teacherId != null
                                  ? teachers.firstWhere(
                                    (t) => t.id == classroom.teacherId,
                                orElse: () => Teacher(
                                  id: '',
                                  firstName: 'No',
                                  lastName: 'Teacher',
                                  uniqueId: '',
                                  nic: '',
                                  phoneNumber: '',
                                  address: '',
                                  username: '',
                                  password: '',
                                  createdAt: DateTime.now(),
                                ),
                              )
                                  : null;

                              return Card(
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.purple,
                                    child: Icon(Icons.class_, color: Colors.white),
                                  ),
                                  title: Text('${schoolYear.year} - ${grade.name} - ${subject.name}'),
                                  subtitle: Text(
                                    teacher != null
                                        ? 'Teacher: ${teacher.firstName} ${teacher.lastName}'
                                        : 'No teacher assigned',
                                  ),
                                  trailing: PopupMenuButton(
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'assign_teacher',
                                        child: Row(
                                          children: [
                                            Icon(Icons.person_add),
                                            SizedBox(width: 8),
                                            Text('Assign Teacher'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'manage_students',
                                        child: Row(
                                          children: [
                                            Icon(Icons.group),
                                            SizedBox(width: 8),
                                            Text('Manage Students'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'assign_teacher':
                                          _showAssignTeacherDialog(classroom);
                                          break;
                                        case 'manage_students':
                                          _showManageStudentsDialog(classroom);
                                          break;
                                        case 'delete':
                                          _deleteClassroom(classroom);
                                          break;
                                      }
                                    },
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
        },
      ),
    );
  }
}