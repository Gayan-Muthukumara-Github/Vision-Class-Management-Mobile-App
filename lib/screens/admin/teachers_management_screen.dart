import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';

class TeachersManagementScreen extends StatefulWidget {
  const TeachersManagementScreen({super.key});

  @override
  State<TeachersManagementScreen> createState() => _TeachersManagementScreenState();
}

class _TeachersManagementScreenState extends State<TeachersManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _showAddTeacherDialog([Teacher? teacher]) {
    final isEdit = teacher != null;
    final firstNameController = TextEditingController(text: teacher?.firstName ?? '');
    final lastNameController = TextEditingController(text: teacher?.lastName ?? '');
    final nicController = TextEditingController(text: teacher?.nic ?? '');
    final phoneController = TextEditingController(text: teacher?.phoneNumber ?? '');
    final addressController = TextEditingController(text: teacher?.address ?? '');
    final usernameController = TextEditingController(text: teacher?.username ?? '');
    final passwordController = TextEditingController(text: isEdit ? '' : 'teacher123');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Teacher' : 'Add New Teacher'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: nicController,
                  decoration: const InputDecoration(labelText: 'NIC'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Required';
                    final phoneRegex = RegExp(r'^0\d{9}$');
                    if (!phoneRegex.hasMatch(v!)) {
                      return 'Invalid format (e.g., 0713442101)';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  enabled: !isEdit,
                ),
                if (!isEdit)
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password (One-time)'),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
              ],
            ),
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
                try {
                  if (isEdit) {
                    await _firestoreService.updateTeacher(teacher.id, {
                      'firstName': firstNameController.text.trim(),
                      'lastName': lastNameController.text.trim(),
                      'nic': nicController.text.trim(),
                      'phoneNumber': phoneController.text.trim(),
                      'address': addressController.text.trim(),
                    });
                  } else {
                    final uniqueId = await _firestoreService.generateUniqueId('teachers');
                    final newTeacher = Teacher(
                      id: '',
                      firstName: firstNameController.text.trim(),
                      lastName: lastNameController.text.trim(),
                      uniqueId: uniqueId,
                      nic: nicController.text.trim(),
                      phoneNumber: phoneController.text.trim(),
                      address: addressController.text.trim(),
                      username: usernameController.text.trim(),
                      password: passwordController.text,
                      isActive: true,
                      createdAt: DateTime.now(),
                    );
                    await _firestoreService.createTeacher(newTeacher);
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit ? 'Teacher updated' : 'Teacher created'),
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
            },
            child: Text(isEdit ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _toggleTeacherStatus(Teacher teacher) async {
    try {
      await _firestoreService.updateTeacher(teacher.id, {
        'isActive': !teacher.isActive,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(teacher.isActive ? 'Teacher deactivated' : 'Teacher activated'),
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

  void _deleteTeacher(Teacher teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: Text('Are you sure you want to delete ${teacher.firstName} ${teacher.lastName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await _firestoreService.deleteTeacher(teacher.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Teacher deleted'),
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
        title: const Text('Teachers Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTeacherDialog(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Teacher>>(
        stream: _firestoreService.getTeachers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final teachers = snapshot.data ?? [];

          if (teachers.isEmpty) {
            return const Center(child: Text('No teachers found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: teacher.isActive ? Colors.green : Colors.grey,
                    child: Text(teacher.firstName[0] + teacher.lastName[0]),
                  ),
                  title: Text('${teacher.firstName} ${teacher.lastName}'),
                  subtitle: Text(
                    'ID: ${teacher.uniqueId}\nUsername: ${teacher.username}\nPhone: ${teacher.phoneNumber}',
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(teacher.isActive ? Icons.block : Icons.check_circle),
                            const SizedBox(width: 8),
                            Text(teacher.isActive ? 'Deactivate' : 'Activate'),
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
                        case 'edit':
                          _showAddTeacherDialog(teacher);
                          break;
                        case 'toggle':
                          _toggleTeacherStatus(teacher);
                          break;
                        case 'delete':
                          _deleteTeacher(teacher);
                          break;
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