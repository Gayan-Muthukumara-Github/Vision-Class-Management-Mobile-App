import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';

class StudentResultsScreen extends StatefulWidget {
  final Student student;

  const StudentResultsScreen({super.key, required this.student});

  @override
  State<StudentResultsScreen> createState() => _StudentResultsScreenState();
}

class _StudentResultsScreenState extends State<StudentResultsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  List<SchoolYear> _schoolYears = [];
  List<Grade> _grades = [];
  List<Subject> _subjects = [];
  List<Map<String, dynamic>> _studentClassrooms = [];

  String? _selectedSchoolYearId;
  String? _selectedGradeId;
  String? _selectedSubjectId;

  List<ExamMark> _marks = [];
  bool _isLoading = true;
  bool _showingResults = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final schoolYears = await _firestoreService.getSchoolYears().first;
      final grades = await _firestoreService.getGrades().first;
      final subjects = await _firestoreService.getSubjects().first;
      final classrooms = await _firestoreService.getStudentAcademicData(widget.student.id);

      // Get unique school years, grades, subjects for this student
      final studentSchoolYearIds = classrooms.map((c) => c['schoolYearId'] as String).toSet();
      final studentGradeIds = classrooms.map((c) => c['gradeId'] as String).toSet();
      final studentSubjectIds = classrooms.map((c) => c['subjectId'] as String).toSet();

      setState(() {
        _schoolYears = schoolYears.where((sy) => studentSchoolYearIds.contains(sy.id)).toList();
        _grades = grades.where((g) => studentGradeIds.contains(g.id)).toList();
        _subjects = subjects.where((s) => studentSubjectIds.contains(s.id)).toList();
        _studentClassrooms = classrooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _updateGradesForSchoolYear() {
    if (_selectedSchoolYearId == null) {
      setState(() {
        _grades = [];
        _selectedGradeId = null;
      });
      return;
    }

    final relevantClassrooms = _studentClassrooms
        .where((c) => c['schoolYearId'] == _selectedSchoolYearId)
        .toList();

    final gradeIds = relevantClassrooms.map((c) => c['gradeId'] as String).toSet();

    setState(() {
      _grades = _grades.where((g) => gradeIds.contains(g.id)).toList();
      if (_selectedGradeId != null && !gradeIds.contains(_selectedGradeId)) {
        _selectedGradeId = null;
      }
    });
  }

  void _updateSubjectsForGrade() {
    if (_selectedSchoolYearId == null || _selectedGradeId == null) {
      setState(() {
        _subjects = [];
        _selectedSubjectId = null;
      });
      return;
    }

    final relevantClassrooms = _studentClassrooms
        .where((c) =>
    c['schoolYearId'] == _selectedSchoolYearId &&
        c['gradeId'] == _selectedGradeId)
        .toList();

    final subjectIds = relevantClassrooms.map((c) => c['subjectId'] as String).toSet();

    setState(() {
      _subjects = _subjects.where((s) => subjectIds.contains(s.id)).toList();
      if (_selectedSubjectId != null && !subjectIds.contains(_selectedSubjectId)) {
        _selectedSubjectId = null;
      }
    });
  }

  Future<void> _viewResults() async {
    if (_selectedSchoolYearId == null || _selectedGradeId == null || _selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select school year, grade, and subject'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final marks = await _firestoreService.getStudentAllMarks(
        widget.student.id,
        _selectedSchoolYearId!,
        _selectedGradeId!,
        _selectedSubjectId!,
      );

      setState(() {
        _marks = marks;
        _showingResults = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Student Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Name: ${widget.student.firstName} ${widget.student.lastName}'),
                    Text('Index Number: ${widget.student.uniqueId}'),
                    Text('School: ${widget.student.school}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'School Year',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedSchoolYearId,
                      items: _schoolYears.map((sy) {
                        return DropdownMenuItem(
                          value: sy.id,
                          child: Text(sy.year),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSchoolYearId = value;
                          _selectedGradeId = null;
                          _selectedSubjectId = null;
                          _showingResults = false;
                        });
                        _updateGradesForSchoolYear();
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Grade',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedGradeId,
                      items: _grades.map((g) {
                        return DropdownMenuItem(
                          value: g.id,
                          child: Text(g.name),
                        );
                      }).toList(),
                      onChanged: _selectedSchoolYearId == null
                          ? null
                          : (value) {
                        setState(() {
                          _selectedGradeId = value;
                          _selectedSubjectId = null;
                          _showingResults = false;
                        });
                        _updateSubjectsForGrade();
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedSubjectId,
                      items: _subjects.map((s) {
                        return DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name),
                        );
                      }).toList(),
                      onChanged: _selectedGradeId == null
                          ? null
                          : (value) {
                        setState(() {
                          _selectedSubjectId = value;
                          _showingResults = false;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _viewResults,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('View Results'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showingResults) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Exam Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_marks.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No results available yet'),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _marks.length,
                          itemBuilder: (context, index) {
                            final mark = _marks[index];
                            final date = DateTime.parse('${mark.month}-01');
                            final monthYear = DateFormat('MMMM yyyy').format(date);

                            return Card(
                              color: Colors.orange.shade50,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: mark.marks >= 50
                                      ? Colors.green
                                      : Colors.red,
                                  child: Text(
                                    mark.marks.toInt().toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text('$monthYear - ${mark.examType}'),
                                subtitle: mark.remarks != null
                                    ? Text('Remarks: ${mark.remarks}')
                                    : null,
                                trailing: Text(
                                  '${mark.marks}/100',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
  }
}