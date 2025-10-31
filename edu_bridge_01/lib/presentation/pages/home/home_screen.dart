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

class _HomeScreenContentState extends State<_HomeScreenContent> 
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        {'title': 'Mark Attendance', 'placeholder': 'Track student attendance', 'color': const Color(0xFF5B7FFF)},
        {'title': 'Grade Students', 'placeholder': 'Enter student grades', 'color': const Color(0xFFFF6B6B)},
        {'title': 'Manage Classes', 'placeholder': 'Schedule & organize classes', 'color': const Color(0xFF9C7FFF)},
        {'title': 'Student Reports', 'placeholder': 'Generate progress reports', 'color': const Color(0xFF4ECDC4)},
        {'title': 'Announcements', 'placeholder': 'Post updates & notices', 'color': const Color(0xFF00C48C)},
      ];
    } else if (widget.userType == UserType.student) {
      return [
        {'title': 'My Assignments', 'placeholder': 'View & submit assignments', 'color': const Color(0xFF5B7FFF)},
        {'title': 'My Attendance', 'placeholder': 'View attendance records', 'color': const Color(0xFF5B7FFF)},
        {'title': 'My Grades', 'placeholder': 'Check your grades', 'color': const Color(0xFFFF6B6B)},
        {'title': 'My Classes', 'placeholder': 'View class schedule', 'color': const Color(0xFF9C7FFF)},
        {'title': 'Study Resources', 'placeholder': 'Access learning materials', 'color': const Color(0xFF4ECDC4)},
        {'title': 'Announcements', 'placeholder': 'Read school updates', 'color': const Color(0xFF00C48C)},
      ];
    } else if (widget.userType == UserType.parent) {
      return [
        {'title': "Child's Assignments", 'placeholder': 'Track assignment progress', 'color': const Color(0xFF5B7FFF)},
        {'title': "Child's Attendance", 'placeholder': 'Monitor attendance records', 'color': const Color(0xFF5B7FFF)},
        {'title': "Child's Grades", 'placeholder': 'View academic performance', 'color': const Color(0xFFFF6B6B)},
        {'title': 'Class Schedule', 'placeholder': "View child's timetable", 'color': const Color(0xFF9C7FFF)},
        {'title': 'Teacher Communication', 'placeholder': 'Messages from teachers', 'color': const Color(0xFF4ECDC4)},
        {'title': 'School Announcements', 'placeholder': 'Important updates', 'color': const Color(0xFF00C48C)},
      ];
    } else {
      return [
        {'title': 'Explore Features', 'placeholder': 'Discover EduBridge', 'color': const Color(0xFF5B7FFF)},
        {'title': 'Sign Up', 'placeholder': 'Create account', 'color': const Color(0xFF00C48C)},
        {'title': 'About Us', 'placeholder': 'Learn more', 'color': const Color(0xFF9C7FFF)},
      ];
    }
  }

  void _showAllCategoriesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
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
                    return _buildCategoryCard(
                      title: category['title']!,
                      placeholder: category['placeholder']!,
                      color: category['color'] as Color,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
            builder: (_, controller) => Container(
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
                          _buildInputLabel('Task Name'),
                          const SizedBox(height: 8),
                          _buildTextField(taskNameController, 'Enter task name'),
                          const SizedBox(height: 24),
                          
                          _buildInputLabel('Description'),
                          const SizedBox(height: 8),
                          _buildTextField(descriptionController, 'Add details (optional)', maxLines: 3),
                          const SizedBox(height: 24),
                          
                          _buildInputLabel('Priority'),
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
                          
                          _buildInputLabel('Due Date'),
                          const SizedBox(height: 8),
                          _buildDateTimeSelector(
                            icon: Icons.calendar_today,
                            text: selectedDate != null
                                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                : 'Select date',
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
                          ),
                          const SizedBox(height: 24),
                          
                          _buildInputLabel('Time'),
                          const SizedBox(height: 8),
                          _buildDateTimeSelector(
                            icon: Icons.access_time,
                            text: selectedTime != null
                                ? '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                : 'Select time',
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() => selectedTime = time);
                              }
                            },
                          ),
                          const SizedBox(height: 32),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                if (taskNameController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Please enter a task name'),
                                      backgroundColor: Colors.red[400],
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Task created successfully'),
                                    backgroundColor: Color(0xFF27AE60),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getPrimaryColor(),
                                foregroundColor: Colors.white,
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String title) {
    if (title.contains('Assignment')) return Icons.assignment_outlined;
    if (title.contains('Attendance')) return Icons.how_to_reg_outlined;
    if (title.contains('Classes') || title.contains('Schedule')) return Icons.class_outlined;
    if (title.contains('Grade')) return Icons.grade_outlined;
    if (title.contains('Report')) return Icons.assessment_outlined;
    if (title.contains('Resources') || title.contains('Study')) return Icons.library_books_outlined;
    if (title.contains('Explore')) return Icons.explore_outlined;
    if (title.contains('Sign Up')) return Icons.person_add_outlined;
    if (title.contains('About')) return Icons.info_outline;
    if (title.contains('Communication')) return Icons.chat_bubble_outline;
    if (title.contains('Announcements')) return Icons.campaign_outlined;
    return Icons.category_outlined;
  }

  IconData _getBottomNavIcon(int index) {
    const navConfig = {
      UserType.student: [Icons.home_rounded, Icons.chat_bubble_rounded, Icons.school_rounded, Icons.settings_rounded],
      UserType.teacher: [Icons.home_rounded, Icons.chat_bubble_rounded, Icons.assignment_rounded, Icons.settings_rounded],
      UserType.parent: [Icons.home_rounded, Icons.chat_bubble_rounded, Icons.child_care_rounded, Icons.settings_rounded],
      UserType.guest: [Icons.home_rounded, Icons.info_rounded, Icons.login_rounded, Icons.settings_rounded],
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
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                color: Colors.white,
                child: Row(
                  children: [
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
                          const SizedBox(height: 2),
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
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.search, color: Colors.grey[700], size: 22),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: IconButton(
                              icon: Icon(Icons.notifications_outlined, color: Colors.grey[700], size: 22),
                              onPressed: () {},
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
              child: _buildCategoriesSection(context),
            ),
            
            // My Task Section
            SliverToBoxAdapter(
              child: _buildMyTaskSection(context),
            ),
            
            // Recent Updates
            SliverToBoxAdapter(
              child: _buildRecentUpdatesSection(context),
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
              children: List.generate(4, (index) {
                final isSelected = _selectedIndex == index;
                return Expanded(
                  child: InkWell(
                    onTap: () => _onItemTapped(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getBottomNavIcon(index),
                            color: isSelected ? _getPrimaryColor() : Colors.grey[400],
                            size: 26,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getBottomNavLabel(index),
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
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    final categories = _getAllCategories().take(2).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Row(
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
                onPressed: () => _showAllCategoriesModal(context),
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
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: EdgeInsets.only(right: index < categories.length - 1 ? 16 : 0),
                child: _buildCategoryCard(
                  title: category['title']!,
                  placeholder: category['placeholder']!,
                  color: category['color'] as Color,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String placeholder,
    required Color color,
  }) {
    return Container(
      width: 180,
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
            placeholder,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          const Text(
            '60%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
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

  Widget _buildMyTaskSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text(
            'My Task',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildEmptyTaskCard(context),
        ),
      ],
    );
  }

  Widget _buildEmptyTaskCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                foregroundColor: Colors.white,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUpdatesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text(
            'Recent Updates',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
        ),
      ],
    );
  }
}