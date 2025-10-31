import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/auth/auth_event.dart';

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
  late TabController _taskTabController;

  @override
  void initState() {
    super.initState();
    _taskTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _taskTabController.dispose();
    super.dispose();
  }

  // User-specific theme colors
  Color _getPrimaryColor() {
    switch (widget.userType) {
      case UserType.student:
        return const Color(0xFF5B7FFF);
      case UserType.teacher:
        return const Color(0xFF2D9CDB);
      case UserType.parent:
        return const Color(0xFFEB5757);
      case UserType.guest:
        return const Color(0xFF27AE60);
    }
  }

  List<Map<String, dynamic>> _getAllCategories() {
    if (widget.userType == UserType.teacher) {
      return [
        {'title': 'Create Assignments', 'placeholder': 'Create new assignments', 'color': const Color(0xFF5B7FFF)},
        {'title': 'Mark Attendance', 'placeholder': 'Track student attendance', 'color': const Color(0xFF00C48C)},
        {'title': 'Grade Students', 'placeholder': 'Enter student grades', 'color': const Color(0xFFFF6B9D)},
        {'title': 'Manage Classes', 'placeholder': 'Schedule & organize classes', 'color': const Color(0xFFFFA26B)},
        {'title': 'Student Reports', 'placeholder': 'Generate progress reports', 'color': const Color(0xFF9C6CFF)},
        {'title': 'Announcements', 'placeholder': 'Post updates & notices', 'color': const Color(0xFF6BCF97)},
      ];
    } else if (widget.userType == UserType.student) {
      return [
        {'title': 'My Assignments', 'placeholder': 'View & submit assignments', 'color': const Color(0xFF5B7FFF)},
        {'title': 'My Attendance', 'placeholder': 'View attendance records', 'color': const Color(0xFF00C48C)},
        {'title': 'My Grades', 'placeholder': 'Check your grades', 'color': const Color(0xFFFF6B9D)},
        {'title': 'My Classes', 'placeholder': 'View class schedule', 'color': const Color(0xFFFFA26B)},
        {'title': 'Study Resources', 'placeholder': 'Access learning materials', 'color': const Color(0xFF9C6CFF)},
        {'title': 'Announcements', 'placeholder': 'Read school updates', 'color': const Color(0xFF6BCF97)},
      ];
    } else if (widget.userType == UserType.parent) {
      return [
        {'title': "Child's Assignments", 'placeholder': 'Track assignment progress', 'color': const Color(0xFF5B7FFF)},
        {'title': "Child's Attendance", 'placeholder': 'Monitor attendance records', 'color': const Color(0xFF00C48C)},
        {'title': "Child's Grades", 'placeholder': 'View academic performance', 'color': const Color(0xFFFF6B9D)},
        {'title': 'Class Schedule', 'placeholder': "View child's timetable", 'color': const Color(0xFFFFA26B)},
        {'title': 'Teacher Communication', 'placeholder': 'Messages from teachers', 'color': const Color(0xFF9C6CFF)},
        {'title': 'School Announcements', 'placeholder': 'Important updates', 'color': const Color(0xFF6BCF97)},
      ];
    } else {
      return [
        {'title': 'Explore Features', 'placeholder': 'Discover EduBridge', 'color': const Color(0xFF5B7FFF)},
        {'title': 'Sign Up', 'placeholder': 'Create account', 'color': const Color(0xFF00C48C)},
        {'title': 'About Us', 'placeholder': 'Learn more', 'color': const Color(0xFF9C6CFF)},
      ];
    }
  }

  void _showAddTaskModal(BuildContext context) {
    final taskNameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedPriority = 'Medium';
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create Task',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Task Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: taskNameController,
                          decoration: InputDecoration(
                            hintText: 'Enter task name',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Add details (optional)',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        const Text(
                          'Priority',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
                        const SizedBox(height: 20),
                        
                        const Text(
                          'Due Date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
                              border: Border.all(color: Colors.grey[200]!),
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
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (taskNameController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter a task name')),
                                );
                                return;
                              }
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Task created successfully')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getPrimaryColor(),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Create Task',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
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
          color: isSelected ? color : Colors.grey[100],
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
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Row(
                  children: [
                    // Profile Avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_getPrimaryColor(), _getPrimaryColor().withOpacity(0.7)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Welcome Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            widget.userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Action Icons
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.search, color: Colors.grey[700], size: 22),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: IconButton(
                              icon: Icon(Icons.notifications_outlined, color: Colors.grey[700], size: 22),
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Categories Section
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: _getAllCategories().take(3).length,
                      itemBuilder: (context, index) {
                        final category = _getAllCategories()[index];
                        return _buildCategoryCard(
                          title: category['title']!,
                          subtitle: category['placeholder']!,
                          color: category['color'] as Color,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // My Task Section
            if (widget.userType == UserType.student || widget.userType == UserType.teacher)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Task',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Tab Buttons
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _taskTabController,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelColor: Colors.black87,
                          unselectedLabelColor: Colors.grey[600],
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          tabs: const [
                            Tab(text: 'Active'),
                            Tab(text: 'Completed'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Empty State
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.assignment_outlined,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No active tasks found.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () => _showAddTaskModal(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _getPrimaryColor(),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Add a new task',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Recent Updates Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Updates',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_outlined,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No recent updates',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check back later for new notifications',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, 'Home', 0),
                _buildNavItem(Icons.chat_bubble_rounded, 'Chats', 1),
                _buildNavItem(Icons.library_books_rounded, 'Classes', 2),
                _buildNavItem(Icons.settings_rounded, 'Settings', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              const Text(
                '60%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? _getPrimaryColor() : Colors.grey[400],
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.black87 : Colors.grey[500],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}