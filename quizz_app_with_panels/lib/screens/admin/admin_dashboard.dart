import 'package:flutter/material.dart';
import '../shared/role_selection.dart';
import 'manage_quizzes.dart';
import 'view_results.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _dashboardButton(
              context,
              icon: Icons.quiz,
              label: 'Manage Quizzes',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageQuizzes()),
                );
              },
            ),
            const SizedBox(height: 20),
            _dashboardButton(
              context,
              icon: Icons.bar_chart,
              label: 'View Results',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewResults()),
                );
              },
            ),
            const SizedBox(height: 20),
            _dashboardButton(
              context,
              icon: Icons.logout,
              label: 'Logout',
              onPressed: () {
                // Clear the whole navigation stack and go back to role selection
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const RoleSelection()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // A reusable button widget so we don't repeat the same styling 3 times
  Widget _dashboardButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        onPressed: onPressed,
      ),
    );
  }
}
