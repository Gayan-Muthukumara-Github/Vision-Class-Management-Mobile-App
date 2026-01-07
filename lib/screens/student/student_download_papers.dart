import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../services/lesson_paper_service.dart';

class StudentDownloadPapers extends StatefulWidget {
  final Student student;

  const StudentDownloadPapers({super.key, required this.student});

  @override
  State<StudentDownloadPapers> createState() => _StudentDownloadPapersState();
}

class _StudentDownloadPapersState extends State<StudentDownloadPapers> {
  final FirestoreService _firestoreService = FirestoreService();
  final LessonPaperService _lessonPaperService = LessonPaperService();

  List<Grade> _grades = [];
  List<Subject> _subjects = [];
  List<String> _terms = ['1st Term', '2nd Term', '3rd Term'];
  List<ExamPaper> _papers = [];

  String? _selectedGradeId;
  String? _selectedSubjectId;
  String? _selectedTerm;

  bool _isLoadingGrades = true;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    try {
      final grades = await _firestoreService.getGrades().first;
      setState(() {
        _grades = grades;
        _isLoadingGrades = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading grades: $e')),
        );
        setState(() => _isLoadingGrades = false);
      }
    }
  }

  Future<void> _loadSubjects(String gradeId) async {
    setState(() {
      _selectedSubjectId = null;
      _selectedTerm = null;
      _subjects = [];
      _papers = [];
      _isLoadingData = true;
    });

    try {
      final subjects = await _lessonPaperService.getSubjectsForGrade(gradeId);
      setState(() {
        _subjects = subjects;
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading subjects: $e')),
        );
      }
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _loadPapers(
      String gradeId, String subjectId, String term) async {
    setState(() => _isLoadingData = true);

    try {
      final papers = await _lessonPaperService
          .getPapersByGradeSubjectAndTerm(gradeId, subjectId, term);
      setState(() {
        _papers = papers;
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading papers: $e')),
        );
      }
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _downloadPaper(ExamPaper paper) async {
    try {
      final Uri uri = Uri.parse(paper.fileUrl);
      
      // Try to launch with external application first (Google Drive app)
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        // If Google Drive app not available, try launching in browser
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e2) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open file: $e2')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing URL: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingGrades) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grade Selection
          Text(
            'Select Grade',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _grades.length,
              itemBuilder: (context, index) {
                final grade = _grades[index];
                final isSelected = _selectedGradeId == grade.id;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedGradeId = grade.id);
                      _loadSubjects(grade.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isSelected ? Colors.orange : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          grade.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Subject Selection (if grade selected)
          if (_selectedGradeId != null && _subjects.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Subject',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _isLoadingData
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _subjects.length,
                        itemBuilder: (context, index) {
                          final subject = _subjects[index];
                          final isSelected = _selectedSubjectId == subject.id;

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedSubjectId = subject.id;
                                _selectedTerm = null;
                                _papers = [];
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.orange.withOpacity(0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.subject,
                                    color: isSelected
                                        ? Colors.orange
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    subject.name,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.orange
                                          : Colors.black,
                                    ),
                                  ),
                                  if (isSelected)
                                    const Spacer(),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.orange,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          const SizedBox(height: 24),

          // Term Selection (if subject selected)
          if (_selectedSubjectId != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Term',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _terms.length,
                  itemBuilder: (context, index) {
                    final term = _terms[index];
                    final isSelected = _selectedTerm == term;

                    return InkWell(
                      onTap: () {
                        setState(() => _selectedTerm = term);
                        _loadPapers(_selectedGradeId!, _selectedSubjectId!,
                            term);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.orange.withOpacity(0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Colors.orange
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.date_range,
                              color:
                                  isSelected ? Colors.orange : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              term,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color:
                                    isSelected ? Colors.orange : Colors.black,
                              ),
                            ),
                            if (isSelected)
                              const Spacer(),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.orange,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          const SizedBox(height: 24),

          // Papers List (if term selected)
          if (_selectedTerm != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Papers',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _isLoadingData
                    ? const Center(child: CircularProgressIndicator())
                    : _papers.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text('No papers available for this term'),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _papers.length,
                            itemBuilder: (context, index) {
                              final paper = _papers[index];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.orange
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Icon(
                                              Icons.description,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  paper.title,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  paper.term,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        paper.description,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _downloadPaper(paper),
                                        icon: const Icon(Icons.download),
                                        label: const Text('Download PDF'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ],
            ),
        ],
      ),
    );
  }
}
