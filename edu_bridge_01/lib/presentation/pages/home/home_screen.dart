import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/auth/auth_event.dart';

/*
 * ============================================================================
 * EDUBRIDGE HOME SCREEN - ROLE-BASED UI ARCHITECTURE
 * ============================================================================
 * 
 * This screen implements a role-based dashboard system with clear relationships
 * between different user types. The UI is designed with glassmorphism effects
 * for a modern, premium look and feel.
 * 
 * USER ROLE RELATIONSHIPS & BACKEND REQUIREMENTS:
 * ============================================================================
 * 
 * 1. TEACHER → STUDENT RELATIONSHIP (Content Creation → Consumption)
 *    -----------------------------------------------------------------
 *    Teachers CREATE content that Students CONSUME:
 * 
 *    TEACHER ACTIONS                    →  STUDENT VIEWS
 *    -----------------                     --------------
 *    • Create Assignments               →  My Assignments (view & submit)
 *    • Mark Attendance                  →  My Attendance (view records)
 *    • Grade Students                   →  My Grades (check grades)
 *    • Manage Classes (schedule)        →  My Classes (view schedule)
 *    • Post Announcements               →  Announcements (read updates)
 *    • Upload Study Resources           →  Study Resources (access materials)
 * 
 *    Backend Implementation:
 *    - Assignment collection: { teacherId, studentIds[], title, description, dueDate, status }
 *    - Attendance collection: { teacherId, classId, studentId, date, status }
 *    - Grades collection: { teacherId, studentId, subject, grade, remarks }
 *    - Classes collection: { teacherId, studentIds[], schedule, subject }
 *    - Announcements collection: { teacherId, classId, message, timestamp }
 * 
 * 2. TEACHER/STUDENT → PARENT RELATIONSHIP (Monitoring & Communication)
 *    -----------------------------------------------------------------
 *    Parents MONITOR their child's activities and COMMUNICATE with teachers:
 * 
 *    PARENT VIEWS                           ← DATA SOURCE
 *    ------------                             -----------
 *    • Child's Assignments                 ← Student's assignment data
 *    • Child's Attendance                  ← Student's attendance records
 *    • Child's Grades                      ← Student's academic performance
 *    • Class Schedule                      ← Student's class timetable
 *    • Teacher Communication               ← Messages from teachers
 *    • School Announcements                ← School-wide updates
 * 
 *    Backend Implementation:
 *    - Parent-Child relationship: { parentId, childId (studentId) }
 *    - Parent dashboard queries student data filtered by childId
 *    - Teacher-Parent messaging: { teacherId, parentId, studentId, message, timestamp }
 * 
 * 3. GUEST USER (Limited Access)
 *    -----------------------------------------------------------------
 *    • Explore Features (view app capabilities)
 *    • Sign Up (create new account)
 *    • About Us (learn about the platform)
 * 
 * ============================================================================
 * UI DESIGN CONSISTENCY:
 * ============================================================================
 * All user types (Teacher, Student, Parent) use the SAME glassmorphism design:
 * - Glassmorphic app bar with blur effects
 * - Category cards with gradient overlays
 * - Task section with gradient buttons (Active/Completed)
 * - Recent updates with glassmorphic containers
 * - Minimalistic "Create Task" modal with clean, white background
 * 
 * Color Schemes (User-specific):
 * - Student: Purple gradient (#6C63FF → #9C95FF)
 * - Teacher: Blue gradient (#2D9CDB → #56CCF2)
 * - Parent: Red-Orange gradient (#EB5757 → #F2994A)
 * 
 * ============================================================================
 * BACKEND INTEGRATION GUIDE:
 * ============================================================================
 * 
 * To integrate this UI with the backend:
 * 
 * 1. Replace placeholder data in _getAllCategories() with Firestore queries:
 *    - Teachers: Query assignments, attendance records, grades to create
 *    - Students: Query their assigned tasks, attendance, grades to view
 *    - Parents: Query child's data using parent-child relationship
 * 
 * 2. Implement _buildMyTaskSection() with real task data:
 *    - Fetch active/completed tasks based on user type
 *    - Teachers: Tasks to review/grade
 *    - Students: Assigned homework/projects
 *    - Parents: Child's pending tasks
 * 
 * 3. Implement _buildRecentUpdatesSection() with real-time updates:
 *    - Use Firestore snapshots for live updates
 *    - Teachers: Student submissions, new messages
 *    - Students: New assignments, grade updates
 *    - Parents: Teacher messages, child's progress updates
 * 
 * 4. Connect Create Task modal (_showAddTaskModal) to Firestore:
 *    - Save task with userId, userType, priority, dueDate, etc.
 *    - Implement proper error handling and success feedback
 * 
 * ============================================================================
 */

enum UserType { teacher, student, parent, guest }

UserType stringToUserType(String roleString) {
  switch (roleString.toLowerCase()) {
    case 'student':
      return UserType.student;
    case 'teacher':
      return UserType.teacher;
    case 'parent':
      return UserType.parent;
    case 'admin':
      return UserType.teacher;
    default:
      return UserType.guest;
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final userType = stringToUserType(state.userType);
          return _HomeScreenContent(
            userType: userType,
            userName: state.name,
            userEmail: state.email,
          );
        }
        
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  final UserType userType;
  final String userName;
  final String userEmail;

  const _HomeScreenContent({
    Key? key,
    required this.userType,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showAllCategoriesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'All Categories',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _getAllCategories().length,
                      itemBuilder: (context, index) {
                        final category = _getAllCategories()[index];
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: value,
                                child: _buildEmptyCategoryCard(
                                  title: category['title']!,
                                  placeholder: category['placeholder']!,
                                  color: category['color'] as Color,
                                  context: context,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAllCategories() {
    if (widget.userType == UserType.teacher) {
      // Teacher creates/manages content that students consume
      return [
        {'title': 'Create Assignments', 'placeholder': 'Create new assignments', 'color': Colors.blue[800]!},
        {'title': 'Mark Attendance', 'placeholder': 'Track student attendance', 'color': Colors.teal[700]!},
        {'title': 'Grade Students', 'placeholder': 'Enter student grades', 'color': Colors.orange[800]!},
        {'title': 'Manage Classes', 'placeholder': 'Schedule & organize classes', 'color': Colors.purple[700]!},
        {'title': 'Student Reports', 'placeholder': 'Generate progress reports', 'color': Colors.indigo[700]!},
        {'title': 'Announcements', 'placeholder': 'Post updates & notices', 'color': Colors.green[700]!},
      ];
    } else if (widget.userType == UserType.student) {
      // Student consumes content created by teachers
      return [
        {'title': 'My Assignments', 'placeholder': 'View & submit assignments', 'color': Colors.blue[800]!},
        {'title': 'My Attendance', 'placeholder': 'View attendance records', 'color': Colors.teal[700]!},
        {'title': 'My Grades', 'placeholder': 'Check your grades', 'color': Colors.orange[800]!},
        {'title': 'My Classes', 'placeholder': 'View class schedule', 'color': Colors.purple[700]!},
        {'title': 'Study Resources', 'placeholder': 'Access learning materials', 'color': Colors.indigo[700]!},
        {'title': 'Announcements', 'placeholder': 'Read school updates', 'color': Colors.green[700]!},
      ];
    } else if (widget.userType == UserType.parent) {
      // Parent monitors child's activities (student data + teacher communications)
      return [
        {'title': "Child's Assignments", 'placeholder': 'Track assignment progress', 'color': Colors.blue[800]!},
        {'title': "Child's Attendance", 'placeholder': 'Monitor attendance records', 'color': Colors.teal[700]!},
        {'title': "Child's Grades", 'placeholder': 'View academic performance', 'color': Colors.orange[800]!},
        {'title': 'Class Schedule', 'placeholder': "View child's timetable", 'color': Colors.purple[700]!},
        {'title': 'Teacher Communication', 'placeholder': 'Messages from teachers', 'color': Colors.indigo[700]!},
        {'title': 'School Announcements', 'placeholder': 'Important updates', 'color': Colors.green[700]!},
      ];
    } else {
      return [
        {'title': 'Explore Features', 'placeholder': 'Discover EduBridge', 'color': Colors.blue[800]!},
        {'title': 'Sign Up', 'placeholder': 'Create account', 'color': Colors.green[700]!},
        {'title': 'About Us', 'placeholder': 'Learn more', 'color': Colors.purple[700]!},
      ];
    }
  }

  void _showAddTaskModal(BuildContext context) {
    final taskNameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedPriority = 'Medium';
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.95,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) => ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Create Task',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, size: 24),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              shape: const CircleBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                                const Text(
                                  'Task Name',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: taskNameController,
                                    style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                                    decoration: InputDecoration(
                                      hintText: 'Enter task name',
                                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: descriptionController,
                                    maxLines: 3,
                                    style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                                    decoration: InputDecoration(
                                      hintText: 'Add details (optional)',
                                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                const Text(
                                  'Priority',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildPriorityChip(
                                        'Low',
                                        const Color(0xFF27AE60),
                                        selectedPriority == 'Low',
                                        () => setState(() => selectedPriority = 'Low'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildPriorityChip(
                                        'Medium',
                                        const Color(0xFFF2994A),
                                        selectedPriority == 'Medium',
                                        () => setState(() => selectedPriority = 'Medium'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildPriorityChip(
                                        'High',
                                        const Color(0xFFEB5757),
                                        selectedPriority == 'High',
                                        () => setState(() => selectedPriority = 'High'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                const Text(
                                  'Due Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: _getPrimaryGradientColor(),
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                              onSurface: Colors.black,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (date != null) {
                                      setState(() => selectedDate = date);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          selectedDate != null
                                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                              : 'Select date',
                                          style: TextStyle(
                                            color: selectedDate != null ? Colors.black87 : Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                const Text(
                                  'Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: _getPrimaryGradientColor(),
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                              onSurface: Colors.black,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (time != null) {
                                      setState(() => selectedTime = time);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.access_time, color: Colors.grey[600], size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          selectedTime != null
                                              ? '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                              : 'Select time',
                                          style: TextStyle(
                                            color: selectedTime != null ? Colors.black87 : Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                ElevatedButton(
                                  onPressed: () {
                                    if (taskNameController.text.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Please enter a task name'),
                                          backgroundColor: Colors.red[400],
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          margin: const EdgeInsets.all(16),
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Task created successfully'),
                                        backgroundColor: const Color(0xFF27AE60),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        margin: const EdgeInsets.all(16),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _getPrimaryGradientColor(),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Create Task',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            );
        },
      ),
    );
  }

  Widget _buildPriorityChip(String label, Color color, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  // User-specific theme colors
  Color _getPrimaryGradientColor() {
    switch (widget.userType) {
      case UserType.student:
        return const Color(0xFF6C63FF);
      case UserType.teacher:
        return const Color(0xFF2D9CDB);
      case UserType.parent:
        return const Color(0xFFEB5757);
      case UserType.guest:
        return const Color(0xFF27AE60);
    }
  }

  Color _getSecondaryGradientColor() {
    switch (widget.userType) {
      case UserType.student:
        return const Color(0xFF9C95FF);
      case UserType.teacher:
        return const Color(0xFF56CCF2);
      case UserType.parent:
        return const Color(0xFFF2994A);
      case UserType.guest:
        return const Color(0xFF6FCF97);
    }
  }

  // Navigation configuration for different user types
  IconData _getBottomNavIcon(int index) {
    const navConfig = {
      UserType.student: [Icons.home, Icons.chat_bubble, Icons.school, Icons.settings],
      UserType.teacher: [Icons.home, Icons.chat_bubble, Icons.assignment, Icons.settings],
      UserType.parent: [Icons.home, Icons.chat_bubble, Icons.child_care, Icons.settings],
      UserType.guest: [Icons.home, Icons.info, Icons.login, Icons.settings],
    };
    return navConfig[widget.userType]?[index] ?? Icons.error;
  }

  String _getBottomNavLabel(int index) {
    const navLabels = {
      UserType.student: ['Home', 'Chats', 'Classes', 'Settings'],
      UserType.teacher: ['Home', 'Chats', 'Assignments', 'Settings'],
      UserType.parent: ['Home', 'Chats', 'Children', 'Settings'],
      UserType.guest: ['Home', 'About', 'Sign In', 'Settings'],
    };
    return navLabels[widget.userType]?[index] ?? 'Error';
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    print("Navigating to: ${_getBottomNavLabel(index)} for ${widget.userType}");
  }

  // Reusable glassmorphic icon button for app bar
  Widget _buildAppBarIconButton(IconData icon, VoidCallback onTap, {bool showBadge = false}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.7),
                    Colors.white.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: IconButton(
                icon: Icon(icon, color: Colors.grey[800], size: 22),
                onPressed: onTap,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            ),
          ),
        ),
        if (showBadge)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.6),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getPrimaryGradientColor(),
                      _getSecondaryGradientColor(),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getPrimaryGradientColor().withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      widget.userName,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[900],
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              _buildAppBarIconButton(Icons.search, () {}),
              const SizedBox(width: 8),
              _buildAppBarIconButton(Icons.notifications_none, () {}, showBadge: true),
              const SizedBox(width: 8),
              _buildAppBarIconButton(Icons.logout, () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Row(
                      children: [
                        Icon(Icons.logout, color: Colors.redAccent),
                        SizedBox(width: 12),
                        Text('Logout'),
                      ],
                    ),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getPrimaryGradientColor().withOpacity(0.1),
              _getSecondaryGradientColor().withOpacity(0.05),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Category Section
                      _buildCategorySection(context),
                      const SizedBox(height: 24),

                      if (widget.userType == UserType.student || widget.userType == UserType.teacher)
                        _buildMyTaskSection(context),
                      if (widget.userType == UserType.student || widget.userType == UserType.teacher)
                        const SizedBox(height: 24),

                      _buildRecentUpdatesSection(context),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.9),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(_getBottomNavIcon(0)),
                  label: _getBottomNavLabel(0),
                ),
                BottomNavigationBarItem(
                  icon: Icon(_getBottomNavIcon(1)),
                  label: _getBottomNavLabel(1),
                ),
                BottomNavigationBarItem(
                  icon: Icon(_getBottomNavIcon(2)),
                  label: _getBottomNavLabel(2),
                ),
                BottomNavigationBarItem(
                  icon: Icon(_getBottomNavIcon(3)),
                  label: _getBottomNavLabel(3),
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: _getPrimaryGradientColor(),
              unselectedItemColor: Colors.grey[500], 
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.3,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.2,
              ),
              selectedFontSize: 12,
              unselectedFontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () {
                _showAllCategoriesModal(context);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            children: [
              if (widget.userType == UserType.teacher) ...[
                _buildEmptyCategoryCard(
                  title: 'Create Assignments',
                  placeholder: 'Create new assignments',
                  color: Colors.blue[800]!,
                  context: context,
                ),
                const SizedBox(width: 16),
                _buildEmptyCategoryCard(
                  title: 'Mark Attendance',
                  placeholder: 'Track student attendance',
                  color: Colors.teal[700]!,
                  context: context,
                ),
              ],

              if (widget.userType == UserType.student) ...[
                _buildEmptyCategoryCard(
                  title: 'My Assignments',
                  placeholder: 'View & submit assignments',
                  color: Colors.blue[800]!,
                  context: context,
                ),
                const SizedBox(width: 16),
                _buildEmptyCategoryCard(
                  title: 'My Attendance',
                  placeholder: 'View attendance records',
                  color: Colors.teal[700]!,
                  context: context,
                ),
              ],

              if (widget.userType == UserType.parent) ...[
                _buildEmptyCategoryCard(
                  title: "Child's Assignments",
                  placeholder: 'Track assignment progress',
                  color: Colors.blue[800]!,
                  context: context,
                ),
                const SizedBox(width: 16),
                _buildEmptyCategoryCard(
                  title: "Child's Attendance",
                  placeholder: 'Monitor attendance records',
                  color: Colors.teal[700]!,
                  context: context,
                ),
              ],

              if (widget.userType == UserType.guest) ...[
                _buildEmptyCategoryCard(
                  title: 'Explore Features',
                  placeholder: 'Discover EduBridge',
                  color: Colors.blue[800]!,
                  context: context,
                ),
                const SizedBox(width: 16),
                _buildEmptyCategoryCard(
                  title: 'Sign Up',
                  placeholder: 'Create account',
                  color: Colors.green[700]!,
                  context: context,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCategoryCard({
    required String title,
    required String placeholder,
    required Color color,
    required BuildContext context,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 160,
          height: 155,
          margin: const EdgeInsets.only(right: 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.85),
                color.withOpacity(0.65),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Icon(
                  _getCategoryIcon(title),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      placeholder,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 11,
                        height: 1.3,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String title) {
    if (title.contains('Assignment')) return Icons.assignment_outlined;
    if (title.contains('Attendance')) return Icons.how_to_reg_outlined;
    if (title.contains('Classes') || title.contains('Schedule')) return Icons.class_outlined;
    if (title.contains('Progress')) return Icons.trending_up_outlined;
    if (title.contains('Grade')) return Icons.grade_outlined;
    if (title.contains('Report')) return Icons.assessment_outlined;
    if (title.contains('Resources') || title.contains('Study')) return Icons.library_books_outlined;
    if (title.contains('Exam')) return Icons.quiz_outlined;
    if (title.contains('Messages') || title.contains('Chat')) return Icons.chat_bubble_outline;
    if (title.contains('Events')) return Icons.event_outlined;
    if (title.contains('Fee') || title.contains('Payment')) return Icons.payment_outlined;
    if (title.contains('Explore')) return Icons.explore_outlined;
    if (title.contains('Sign Up')) return Icons.person_add_outlined;
    if (title.contains('About')) return Icons.info_outline;
    return Icons.category_outlined;
  }

  Widget _buildMyTaskSection(BuildContext context) {
    // Get user-specific task section title
    String getSectionTitle() {
      switch (widget.userType) {
        case UserType.teacher:
          return 'Teaching Tasks';
        case UserType.student:
          return 'My Tasks';
        case UserType.parent:
          return "Child's Tasks";
        default:
          return 'Tasks';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getSectionTitle(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getPrimaryGradientColor(),
                          _getSecondaryGradientColor(),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getPrimaryGradientColor().withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.7),
                          Colors.white.withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text(
                        'Completed',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildEmptyPlaceholderCard(
          icon: Icons.assignment_outlined,
          message: 'No active tasks found.',
          buttonText: 'Add a new task',
          onButtonPressed: () {
            _showAddTaskModal(context);
          },
        ),
      ],
    );
  }

  Widget _buildRecentUpdatesSection(BuildContext context) {
    // Get user-specific updates section info
    String getSectionTitle() {
      switch (widget.userType) {
        case UserType.teacher:
          return 'Recent Activity';
        case UserType.student:
          return 'Recent Updates';
        case UserType.parent:
          return "Child's Updates";
        default:
          return 'Recent Updates';
      }
    }

    String getEmptyMessage() {
      switch (widget.userType) {
        case UserType.teacher:
          return 'No recent activity from your classes.';
        case UserType.student:
          return 'No new assignments or announcements.';
        case UserType.parent:
          return 'No recent updates about your child.';
        default:
          return 'No recent updates at the moment.';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getSectionTitle(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
      
        _buildEmptyPlaceholderCard(
          icon: Icons.info_outline,
          message: getEmptyMessage(),
          buttonText: 'Check for updates',
          onButtonPressed: () {
            print('Refresh updates for ${widget.userType}');
          },
        ),
      ],
    );
  }

  Widget _buildEmptyPlaceholderCard({
    required IconData icon,
    required String message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.8),
                Colors.white.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                spreadRadius: -2,
                blurRadius: 10,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getPrimaryGradientColor().withOpacity(0.2),
                        _getSecondaryGradientColor().withOpacity(0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: _getPrimaryGradientColor(),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                if (buttonText != null) const SizedBox(height: 24),
                if (buttonText != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getPrimaryGradientColor(),
                              _getSecondaryGradientColor(),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getPrimaryGradientColor().withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: onButtonPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            buttonText,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
