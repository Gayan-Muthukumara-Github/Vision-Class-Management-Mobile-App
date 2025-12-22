import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';

class AcademicStructureScreen extends StatefulWidget {
  const AcademicStructureScreen({super.key});

  @override
  State<AcademicStructureScreen> createState() => _AcademicStructureScreenState();
}

class _AcademicStructureScreenState extends State<AcademicStructureScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

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

  void _showAddSchoolYearDialog([SchoolYear? schoolYear]) {
    final isEdit = schoolYear != null;
    final controller = TextEditingController(text: schoolYear?.year ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit School Year' : 'Add School Year'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'School Year', hintText: 'e.g., 2024-2025', border: OutlineInputBorder()),
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Required';
              if (!RegExp(r'^\d{4}-\d{4}$').hasMatch(v!)) return 'Format should be YYYY-YYYY (e.g., 2024-2025)';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  if (isEdit) {
                    await _firestoreService.updateSchoolYear(schoolYear.id, controller.text.trim());
                  } else {
                    await _firestoreService.createSchoolYear(SchoolYear(id: '', year: controller.text.trim(), createdAt: DateTime.now()));
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEdit ? 'School year updated' : 'School year created'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
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

  void _deleteSchoolYear(SchoolYear schoolYear) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete School Year'),
        content: Text('Are you sure you want to delete ${schoolYear.year}?\n\nThis will affect all classrooms using this year.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                await _firestoreService.deleteSchoolYear(schoolYear.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('School year deleted'), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddGradeDialog([Grade? grade]) {
    final isEdit = grade != null;
    final controller = TextEditingController(text: grade?.name ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Grade' : 'Add Grade'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Grade', hintText: 'e.g., Grade 1, Grade 2', border: OutlineInputBorder()),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  if (isEdit) {
                    await _firestoreService.updateGrade(grade.id, controller.text.trim());
                  } else {
                    await _firestoreService.createGrade(Grade(id: '', name: controller.text.trim(), createdAt: DateTime.now()));
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEdit ? 'Grade updated' : 'Grade created'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
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

  void _deleteGrade(Grade grade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Grade'),
        content: Text('Are you sure you want to delete ${grade.name}?\n\nThis will affect all classrooms using this grade.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                await _firestoreService.deleteGrade(grade.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Grade deleted'), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddSubjectDialog([Subject? subject]) {
    final isEdit = subject != null;
    final controller = TextEditingController(text: subject?.name ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Subject' : 'Add Subject'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Subject', hintText: 'e.g., Mathematics, Science', border: OutlineInputBorder()),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  if (isEdit) {
                    await _firestoreService.updateSubject(subject.id, controller.text.trim());
                  } else {
                    await _firestoreService.createSubject(Subject(id: '', name: controller.text.trim(), createdAt: DateTime.now()));
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEdit ? 'Subject updated' : 'Subject created'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
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

  void _deleteSubject(Subject subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete ${subject.name}?\n\nThis will affect all classrooms using this subject.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                await _firestoreService.deleteSubject(subject.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subject deleted'), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
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
        title: const Text('Academic Structure'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today), text: 'School Years'),
            Tab(icon: Icon(Icons.grade), text: 'Grades'),
            Tab(icon: Icon(Icons.book), text: 'Subjects'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSchoolYearsTab(), _buildGradesTab(), _buildSubjectsTab()],
      ),
    );
  }

  Widget _buildSchoolYearsTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSchoolYearDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<SchoolYear>>(
        stream: _firestoreService.getSchoolYears(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.calendar_today, size: 80, color: Colors.grey), SizedBox(height: 16), Text('No school years found', style: TextStyle(fontSize: 16))],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.calendar_today, color: Colors.white)),
                  title: Text(item.year, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAddSchoolYearDialog(item)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteSchoolYear(item)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGradesTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGradeDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Grade>>(
        stream: _firestoreService.getGrades(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.grade, size: 80, color: Colors.grey), SizedBox(height: 16), Text('No grades found', style: TextStyle(fontSize: 16))],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.grade, color: Colors.white)),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAddGradeDialog(item)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteGrade(item)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSubjectsTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubjectDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Subject>>(
        stream: _firestoreService.getSubjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.book, size: 80, color: Colors.grey), SizedBox(height: 16), Text('No subjects found', style: TextStyle(fontSize: 16))],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.book, color: Colors.white)),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAddSubjectDialog(item)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteSubject(item)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}