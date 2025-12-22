import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login_selection_screen.dart';
import 'teachers_management_screen.dart';
import 'students_management_screen.dart';
import 'academic_structure_screen.dart';
import 'classrooms_management_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              context,
              'Teachers',
              Icons.person,
              Colors.blue,
                  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TeachersManagementScreen()),
              ),
            ),
            _buildDashboardCard(
              context,
              'Students',
              Icons.school,
              Colors.green,
                  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentsManagementScreen()),
              ),
            ),
            _buildDashboardCard(
              context,
              'Academic Structure',
              Icons.calendar_today,
              Colors.orange,
                  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AcademicStructureScreen()),
              ),
            ),
            _buildDashboardCard(
              context,
              'Classrooms',
              Icons.class_,
              Colors.purple,
                  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClassroomsManagementScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 50, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}