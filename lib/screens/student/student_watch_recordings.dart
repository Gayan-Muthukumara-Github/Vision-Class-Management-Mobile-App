import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../services/lesson_paper_service.dart';

class StudentWatchRecordings extends StatefulWidget {
  final Student student;

  const StudentWatchRecordings({super.key, required this.student});

  @override
  State<StudentWatchRecordings> createState() => _StudentWatchRecordingsState();
}

class _StudentWatchRecordingsState extends State<StudentWatchRecordings> {
  final FirestoreService _firestoreService = FirestoreService();
  final LessonPaperService _lessonPaperService = LessonPaperService();

  List<Grade> _grades = [];
  List<Subject> _subjects = [];
  List<LessonRecording> _recordings = [];
  List<int> _availableNumbers = [];

  String? _selectedGradeId;
  String? _selectedSubjectId;
  int? _selectedQuestionNumber;

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
      _subjects = [];
      _recordings = [];
      _availableNumbers = [];
      _selectedQuestionNumber = null;
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

  Future<void> _loadRecordings(String gradeId, String subjectId) async {
    setState(() => _isLoadingData = true);

    try {
      final recordings = await _lessonPaperService
          .getRecordingsByGradeAndSubject(gradeId, subjectId);
      
      // Extract unique question numbers and sort them
      final numberSet = <int>{};
      for (var rec in recordings) {
        if (rec.questionNumber != null) {
          numberSet.add(rec.questionNumber!);
        } else {
          final extracted = _extractNumberFromTitle(rec.title);
          if (extracted != null) numberSet.add(extracted);
        }
      }
      final sortedNumbers = numberSet.toList()..sort();
      
      setState(() {
        _recordings = recordings;
        _availableNumbers = sortedNumbers;
        _selectedQuestionNumber = null;
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recordings: $e')),
        );
      }
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _launchYouTube(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      
      // Try to launch with external application first (YouTube app)
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        // If YouTube app not available, try launching in browser
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e2) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open URL: $e2')),
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

  bool _isQuestionGrade() {
    if (_selectedGradeId == null) return false;
    final grade = _grades.firstWhere(
      (g) => g.id == _selectedGradeId,
      orElse: () => Grade(id: '', name: '', createdAt: DateTime.now()),
    );
    final match = RegExp(r"(\d+)").firstMatch(grade.name);
    if (match != null) {
      final gnum = int.tryParse(match.group(0) ?? '0') ?? 0;
      return (gnum == 3 || gnum == 4 || gnum == 5);
    }
    return false;
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
                              setState(() => _selectedSubjectId = subject.id);
                              _loadRecordings(
                                  _selectedGradeId!, subject.id);
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

          // Question/Lesson Number Selection (if subject selected)
          if (_selectedSubjectId != null && _availableNumbers.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isQuestionGrade() ? 'Select Question Number' : 'Select Lesson Number',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                DropdownButton<int>(
                  isExpanded: true,
                  value: _selectedQuestionNumber,
                  hint: Text(_isQuestionGrade() ? 'Choose question number' : 'Choose lesson number'),
                  items: _availableNumbers
                      .map((n) => DropdownMenuItem(
                            value: n,
                            child: Text(_isQuestionGrade() ? 'Q$n' : 'Lesson $n'),
                          ))
                      .toList(),
                  onChanged: (num) {
                    setState(() => _selectedQuestionNumber = num);
                  },
                ),
              ],
            ),
          const SizedBox(height: 24),

          // Recordings List (if subject selected and optionally filtered by question number)
          if (_selectedSubjectId != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Recordings',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _isLoadingData
                    ? const Center(child: CircularProgressIndicator())
                    : (() {
                        // Filter recordings by selected question number if chosen
                        final filteredRecordings = _selectedQuestionNumber == null
                            ? _recordings
                            : _recordings
                                .where((rec) {
                                  final num = rec.questionNumber ?? _extractNumberFromTitle(rec.title);
                                  return num == _selectedQuestionNumber;
                                })
                                .toList();

                        return filteredRecordings.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text('No recordings available'),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredRecordings.length,
                                itemBuilder: (context, index) {
                                  final recording = filteredRecordings[index];

                              final displayNumber = recording.questionNumber ?? _extractNumberFromTitle(recording.title);
                              final isQType = _isQuestionGrade();
                              final label = isQType ? 'Q' : 'Lesson ';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                child: InkWell(
                                  onTap: () => _launchYouTube(
                                      recording.youtubeLink),
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
                                                color: Colors.red
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Icon(
                                                Icons.videocam,
                                                color: Colors.red,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          recording.title,
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .titleSmall,
                                                          maxLines: 2,
                                                          overflow:
                                                              TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      if (displayNumber != null)
                                                        Container(
                                                          margin: const EdgeInsets.only(left: 8),
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: Colors.orange.withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child: Text(
                                                            '$label$displayNumber',
                                                            style: const TextStyle(color: Colors.orange, fontSize: 12),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          recording.description,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton.icon(
                                          onPressed: () => _launchYouTube(
                                              recording.youtubeLink),
                                          icon: const Icon(Icons.play_arrow),
                                          label: const Text('Watch on YouTube'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                                },
                              );
                      }()),
              ],
            ),
        ],
      ),
    );
  }

  int? _extractNumberFromTitle(String title) {
    try {
      final matches = RegExp(r"(\d{1,3})").allMatches(title);
      if (matches.isEmpty) return null;
      final m = matches.last.group(0);
      return m != null ? int.tryParse(m) : null;
    } catch (_) {
      return null;
    }
  }
}
