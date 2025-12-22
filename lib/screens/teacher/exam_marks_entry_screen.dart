import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';

class ExamMarksEntryScreen extends StatefulWidget {
  final Classroom classroom;
  final SchoolYear schoolYear;
  final Grade grade;
  final Subject subject;

  const ExamMarksEntryScreen({
    super.key,
    required this.classroom,
    required this.schoolYear,
    required this.grade,
    required this.subject,
  });

  @override
  State<ExamMarksEntryScreen> createState() => _ExamMarksEntryScreenState();
}

class _ExamMarksEntryScreenState extends State<ExamMarksEntryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _selectedMonth;
  String _selectedExamType = 'Mid-term';
  List<Student> _students = [];
  Map<String, ExamMark> _existingMarks = {};
  bool _isLoading = true;

  final List<String> _examTypes = ['Mid-term', 'Final', 'Quiz', 'Assignment'];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    final students = await _firestoreService.getClassroomStudents(widget.classroom.id);
    final marks = await _firestoreService.getStudentMarks(widget.classroom.id, _selectedMonth!);

    setState(() {
      _students = students;
      _existingMarks = {for (var mark in marks) mark.studentId: mark};
      _isLoading = false;
    });
  }

  bool _canEditMarks() {
    final now = DateTime.now();
    final selectedDate = DateTime.parse('$_selectedMonth-01');
    return now.year == selectedDate.year && now.month == selectedDate.month;
  }

  void _showMarkEntryDialog(Student student) {
    final existingMark = _existingMarks[student.id];
    final marksController = TextEditingController(
      text: existingMark?.marks.toString() ?? '',
    );
    final remarksController = TextEditingController(
      text: existingMark?.remarks ?? '',
    );
    String selectedExamType = existingMark?.examType ?? _selectedExamType;
    final formKey = GlobalKey<FormState>();

    if (!_canEditMarks()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only edit marks for the current month'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${student.firstName} ${student.lastName}'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Exam Type'),
                    value: selectedExamType,
                    items: _examTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedExamType = value!);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: marksController,
                    decoration: const InputDecoration(
                      labelText: 'Marks (0-100)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Required';
                      final marks = double.tryParse(v!);
                      if (marks == null || marks < 0 || marks > 100) {
                        return 'Enter a value between 0 and 100';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: remarksController,
                    decoration: const InputDecoration(
                      labelText: 'Remarks (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
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
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final examMark = ExamMark(
                      id: existingMark?.id ?? '',
                      classroomId: widget.classroom.id,
                      studentId: student.id,
                      month: _selectedMonth!,
                      examType: selectedExamType,
                      marks: double.parse(marksController.text),
                      remarks: remarksController.text.isEmpty ? null : remarksController.text,
                      createdAt: existingMark?.createdAt ?? DateTime.now(),
                      updatedAt: existingMark != null ? DateTime.now() : null,
                      createdBy: existingMark?.createdBy ?? authProvider.userId!,
                      updatedBy: existingMark != null ? authProvider.userId : null,
                    );

                    await _firestoreService.createOrUpdateExamMark(examMark);

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Marks saved successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadStudents();
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
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject.name} - ${widget.grade.name}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Month',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            value: _selectedMonth,
                            items: List.generate(12, (index) {
                              final date = DateTime.now().subtract(Duration(days: index * 30));
                              final month = DateFormat('yyyy-MM').format(date);
                              final display = DateFormat('MMMM yyyy').format(date);
                              return DropdownMenuItem(value: month, child: Text(display));
                            }),
                            onChanged: (value) {
                              setState(() {
                                _selectedMonth = value;
                                _loadStudents();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!_canEditMarks())
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You can only edit marks for the current month',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                ? const Center(child: Text('No students assigned to this classroom'))
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                final mark = _existingMarks[student.id];

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: mark != null ? Colors.green : Colors.grey,
                      child: Text(student.firstName[0] + student.lastName[0]),
                    ),
                    title: Text('${student.firstName} ${student.lastName}'),
                    subtitle: Text(
                      mark != null
                          ? 'Marks: ${mark.marks} | Type: ${mark.examType}\n${mark.remarks ?? "No remarks"}'
                          : 'No marks entered yet',
                    ),
                    trailing: _canEditMarks()
                        ? IconButton(
                      icon: Icon(
                        mark != null ? Icons.edit : Icons.add,
                        color: Colors.green,
                      ),
                      onPressed: () => _showMarkEntryDialog(student),
                    )
                        : null,
                    isThreeLine: mark != null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}