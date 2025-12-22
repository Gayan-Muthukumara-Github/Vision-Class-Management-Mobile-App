import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';

class StudentsManagementScreen extends StatefulWidget {
  const StudentsManagementScreen({super.key});

  @override
  State<StudentsManagementScreen> createState() => _StudentsManagementScreenState();
}

class _StudentsManagementScreenState extends State<StudentsManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _showAddStudentDialog([Student? student]) {
    final isEdit = student != null;
    final firstNameController = TextEditingController(text: student?.firstName ?? '');
    final lastNameController = TextEditingController(text: student?.lastName ?? '');
    final emergencyContactController = TextEditingController(text: student?.emergencyContactNo ?? '');
    final relationshipController = TextEditingController(text: student?.relationshipToContact ?? '');
    final schoolController = TextEditingController(text: student?.school ?? '');
    final addressController = TextEditingController(text: student?.address ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Student' : 'Add New Student'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isEdit)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Student Index: ${student.uniqueId}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emergencyContactController,
                  decoration: const InputDecoration(
                    labelText: 'Emergency Contact No',
                    border: OutlineInputBorder(),
                    helperText: 'Format: 0713442101',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Required';
                    final phoneRegex = RegExp(r'^0\d{9}$');
                    if (!phoneRegex.hasMatch(v!)) return 'Invalid format (e.g., 0713442101)';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: relationshipController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship to Contact',
                    border: OutlineInputBorder(),
                    helperText: 'e.g., Father, Mother, Guardian',
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: schoolController,
                  decoration: const InputDecoration(labelText: 'School', border: OutlineInputBorder()),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                  maxLines: 2,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  if (isEdit) {
                    await _firestoreService.updateStudent(student.id, {
                      'firstName': firstNameController.text.trim(),
                      'lastName': lastNameController.text.trim(),
                      'emergencyContactNo': emergencyContactController.text.trim(),
                      'relationshipToContact': relationshipController.text.trim(),
                      'school': schoolController.text.trim(),
                      'address': addressController.text.trim(),
                    });
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Student updated successfully'), backgroundColor: Colors.green),
                      );
                    }
                  } else {
                    final uniqueId = await _firestoreService.generateUniqueId('students');
                    final newStudent = Student(
                      id: '',
                      firstName: firstNameController.text.trim(),
                      lastName: lastNameController.text.trim(),
                      uniqueId: uniqueId,
                      emergencyContactNo: emergencyContactController.text.trim(),
                      relationshipToContact: relationshipController.text.trim(),
                      school: schoolController.text.trim(),
                      address: addressController.text.trim(),
                      isActive: true,
                      createdAt: DateTime.now(),
                    );
                    await _firestoreService.createStudent(newStudent);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Student created with Index Number: $uniqueId'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: Text(isEdit ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _toggleStudentStatus(Student student) async {
    try {
      await _firestoreService.updateStudent(student.id, {'isActive': !student.isActive});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(student.isActive ? 'Student deactivated' : 'Student activated'),
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
  }

  void _deleteStudent(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete ${student.firstName} ${student.lastName}?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                await _firestoreService.deleteStudent(student.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Student deleted successfully'), backgroundColor: Colors.green),
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
        title: const Text('Students Management'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudentDialog(),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
      ),
      body: StreamBuilder<List<Student>>(
        stream: _firestoreService.getStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final students = snapshot.data ?? [];

          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No students found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Tap the + button to add a new student', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: student.isActive ? Colors.green : Colors.grey,
                    foregroundColor: Colors.white,
                    child: Text(student.firstName[0].toUpperCase() + student.lastName[0].toUpperCase()),
                  ),
                  title: Text('${student.firstName} ${student.lastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Index: ${student.uniqueId}\n'
                        'School: ${student.school}\n'
                        'Contact: ${student.emergencyContactNo} (${student.relationshipToContact})',
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text('Edit')]),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(student.isActive ? Icons.block : Icons.check_circle, color: student.isActive ? Colors.orange : Colors.green),
                            const SizedBox(width: 8),
                            Text(student.isActive ? 'Deactivate' : 'Activate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))]),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'edit': _showAddStudentDialog(student); break;
                        case 'toggle': _toggleStudentStatus(student); break;
                        case 'delete': _deleteStudent(student); break;
                      }
                    },
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}