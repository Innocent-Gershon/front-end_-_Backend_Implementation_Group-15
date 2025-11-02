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

  List<Map<String, dynamic>> _getCategoryData() {
    if (widget.userType == UserType.student) {
      return [
        {
          'title': 'Assignment',
          'subtitle': 'To Review',
          'detail': 'Due Today: 3',
          'progress': 0.6,
          'progressText': '60%',
          'color': const Color(0xFF5B7FFF),
        },
        {
          'title': 'Attendance',
          'subtitle': 'Track Now',
          'detail': '87% This Week',
          'progress': 0.75,
          'progressText': '75%',
          'color': const Color(0xFF5B7FFF),
        },
      ];
    } else if (widget.userType == UserType.teacher) {
      return [
        {
          'title': 'Classes',
          'subtitle': 'Today',
          'detail': '5 Classes',
          'progress': 0.8,
          'progressText': '80%',
          'color': const Color(0xFF2D9CDB),
        },
        {
          'title': 'Grading',
          'subtitle': 'Pending',
          'detail': '12 Assignments',
          'progress': 0.45,
          'progressText': '45%',
          'color': const Color(0xFFFF6B6B),
        },
      ];
    } else if (widget.userType == UserType.parent) {
      return [
        {
          'title': 'Assignments',
          'subtitle': 'Track Progress',
          'detail': '3 Pending',
          'progress': 0.65,
          'progressText': '65%',
          'color': const Color(0xFFEB5757),
        },
        {
          'title': 'Attendance',
          'subtitle': 'This Week',
          'detail': '95% Present',
          'progress': 0.95,
          'progressText': '95%',
          'color': const Color(0xFF27AE60),
        },
      ];
    } else {
      return [
        {
          'title': 'Explore',
          'subtitle': 'Features',
          'detail': 'Get Started',
          'progress': 0.0,
          'progressText': '0%',
          'color': const Color(0xFF5B7FFF),
        },
        {
          'title': 'Sign Up',
          'subtitle': 'Join Now',
          'detail': 'Create Account',
          'progress': 0.0,
          'progressText': '0%',
          'color': const Color(0xFF27AE60),
        },
      ];
    }
  }

  List<Map<String, dynamic>> _getTaskData() {
    return [
      {
        'title': 'Design task management dashboard',
        'description': 'Create wireframes and mockups for the main dashboard.',
        'priority': 'High',
        'priorityColor': const Color(0xFFF59E0B),
        'tags': ['UI', 'Design'],
        'status': 'In Progress',
        'dueDate': '10 October',
      },
      {
        'title': 'Design task management dashboard',
        'description': 'Create wireframes and mockups for the main dashboard.',
        'priority': 'Medium',
        'priorityColor': const Color(0xFF3B82F6),
        'tags': ['UI', 'Design'],
        'status': 'In Progress',
        'dueDate': '20 October',
      },
    ];
  }

  IconData _getBottomNavIcon(int index, bool isSelected) {
    const navConfig = {
      UserType.student: [
        [Icons.home_rounded, Icons.home_outlined],
        [Icons.chat_bubble_rounded, Icons.chat_bubble_outline],
        [Icons.school_rounded, Icons.school_outlined],
        [Icons.settings_rounded, Icons.settings_outlined]
      ],
      UserType.teacher: [
        [Icons.home_rounded, Icons.home_outlined],
        [Icons.chat_bubble_rounded, Icons.chat_bubble_outline],
        [Icons.school_rounded, Icons.school_outlined],
        [Icons.settings_rounded, Icons.settings_outlined]
      ],
      UserType.parent: [
        [Icons.home_rounded, Icons.home_outlined],
        [Icons.chat_bubble_rounded, Icons.chat_bubble_outline],
        [Icons.school_rounded, Icons.school_outlined],
        [Icons.settings_rounded, Icons.settings_outlined]
      ],
      UserType.guest: [
        [Icons.home_rounded, Icons.home_outlined],
        [Icons.chat_bubble_rounded, Icons.chat_bubble_outline],
        [Icons.school_rounded, Icons.school_outlined],
        [Icons.settings_rounded, Icons.settings_outlined]
      ],
    };
    return navConfig[widget.userType]?[index]?[isSelected ? 0 : 1] ?? Icons.error;
  }

  String _getBottomNavLabel(int index) {
    const navLabels = {
      UserType.student: ['Home', 'Chats', 'Classes', 'Settings'],
      UserType.teacher: ['Home', 'Chats', 'Classes', 'Settings'],
      UserType.parent: ['Home', 'Chats', 'Classes', 'Settings'],
      UserType.guest: ['Home', 'Chats', 'Classes', 'Settings'],
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                color: Colors.white,
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FF),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/avatar.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: _getPrimaryColor(),
                                ),
                              ),
                            );
                          },
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
                              fontSize: 14,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.userName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: _getPrimaryColor(),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FF),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.search, color: Colors.grey[700], size: 24),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FF),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: IconButton(
                              icon: Icon(Icons.notifications_outlined, color: Colors.grey[700], size: 24),
                              onPressed: () {},
                            ),
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF4757),
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
            
            SliverToBoxAdapter(
              child: Container(
                height: 1,
                color: Colors.grey[200],
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
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            _getBottomNavIcon(index, isSelected),
                            color: isSelected ? _getPrimaryColor() : Colors.grey[700],
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getBottomNavLabel(index),
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected ? Colors.black87 : Colors.grey[700],
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
    final categories = _getCategoryData();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Colors.black,
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
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
                  subtitle: category['subtitle']!,
                  detail: category['detail']!,
                  progress: category['progress']!,
                  progressText: category['progressText']!,
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
    required String subtitle,
    required String detail,
    required double progress,
    required String progressText,
    required Color color,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            progressText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTaskSection(BuildContext context) {
    final tasks = _getTaskData();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 28, 20, 16),
          child: Text(
            'My Task',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
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
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...tasks.map((task) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: _buildTaskCard(
            title: task['title']!,
            description: task['description']!,
            priority: task['priority']!,
            priorityColor: task['priorityColor'] as Color,
            tags: List<String>.from(task['tags']),
            status: task['status']!,
            dueDate: task['dueDate']!,
          ),
        )),
      ],
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String description,
    required String priority,
    required Color priorityColor,
    required List<String> tags,
    required String status,
    required String dueDate,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.grey[200],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                'Due date: $dueDate',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
          padding: EdgeInsets.fromLTRB(20, 28, 20, 16),
          child: Text(
            'Recent Updates',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}