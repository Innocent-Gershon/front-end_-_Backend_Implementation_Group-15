import 'package:flutter/material.dart';

// Enum to define different user types
enum UserType { teacher, student, parent, guest }

class HomeScreen extends StatefulWidget {
  final UserType userType;

  const HomeScreen({super.key, required this.userType});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // For bottom navigation bar

  // Helper method to get the correct icon for the bottom navigation
  IconData _getBottomNavIcon(int index) {
    switch (widget.userType) {
      case UserType.student:
        if (index == 0) return Icons.home;
        if (index == 1) return Icons.chat_bubble;
        if (index == 2) return Icons.school; // Classes for students
        if (index == 3) return Icons.settings;
        break;
      case UserType.teacher:
        if (index == 0) return Icons.home;
        if (index == 1) return Icons.chat_bubble;
        if (index == 2) return Icons.assignment; // Assignments for teachers
        if (index == 3) return Icons.settings;
        break;
      case UserType.parent:
        if (index == 0) return Icons.home;
        if (index == 1) return Icons.chat_bubble;
        if (index == 2) return Icons.child_care; // Child tracking for parents
        if (index == 3) return Icons.settings;
        break;
      case UserType.guest:
        if (index == 0) return Icons.home;
        if (index == 1) return Icons.info; // Info for guests
        if (index == 2) return Icons.login; // Login/Register for guests
        if (index == 3) return Icons.settings;
        break;
    }
    return Icons.error; // Should not happen
  }