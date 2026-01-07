import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firestore_service.dart';
import '../../services/lesson_paper_service.dart';
import 'student_watch_recordings.dart';
import 'student_download_papers.dart';
import 'student_results_screen.dart';

class StudentDashboard extends StatefulWidget {
  final Student student;

  const StudentDashboard({super.key, required this.student});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  final LessonPaperService _lessonPaperService = LessonPaperService();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Portal'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Results', icon: Icon(Icons.assignment)),
            Tab(text: 'Recordings', icon: Icon(Icons.videocam)),
            Tab(text: 'Papers', icon: Icon(Icons.description)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StudentResultsScreen(student: widget.student),
          StudentWatchRecordings(student: widget.student),
          StudentDownloadPapers(student: widget.student),
        ],
      ),
    );
  }
}
