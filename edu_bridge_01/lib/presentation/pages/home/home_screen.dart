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

class _HomeScreenContentState extends State<_HomeScreenContent> {
  int _selectedIndex = 0; // For bottom navigation bar

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
    return Icons.error;
  }

  // Helper method to get the correct label for the bottom navigation
  String _getBottomNavLabel(int index) {
    switch (widget.userType) {
      case UserType.student:
        if (index == 0) return 'Home';
        if (index == 1) return 'Chats';
        if (index == 2) return 'Classes';
        if (index == 3) return 'Settings';
        break;
      case UserType.teacher:
        if (index == 0) return 'Home';
        if (index == 1) return 'Chats';
        if (index == 2) return 'Assignments';
        if (index == 3) return 'Settings';
        break;
      case UserType.parent:
        if (index == 0) return 'Home';
        if (index == 1) return 'Chats';
        if (index == 2) return 'Children'; // or "Tracking"
        if (index == 3) return 'Settings';
        break;
      case UserType.guest:
        if (index == 0) return 'Home';
        if (index == 1) return 'About';
        if (index == 2) return 'Sign In';
        if (index == 3) return 'Settings';
        break;
    }
    return 'Error'; // Should not happen
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // You can navigate to different screens here
    
    print("Navigating to: ${_getBottomNavLabel(index)} for ${widget.userType}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 80, // Increased height to match the design
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20),
          child: Row(
            children: [
              // User Profile Picture
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                backgroundImage: const AssetImage('assets/profile_pic.png'),
              ),
              const SizedBox(width: 12),

              // Welcome Message and User Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.search, color: Colors.grey[700]),
                  onPressed: () {
                    // Handle search action
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.notifications_none, color: Colors.grey[700]),
                  onPressed: () {
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.logout, color: Colors.grey[700]),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context.read<AuthBloc>().add(AuthLogoutRequested());
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Section
              _buildCategorySection(context),
              const SizedBox(height: 24),

              // My Task Section (Only for student/teacher, not parent)
              if (widget.userType == UserType.student || widget.userType == UserType.teacher)
                _buildMyTaskSection(context),
              if (widget.userType == UserType.student || widget.userType == UserType.teacher)
                const SizedBox(height: 24),

              // Recent Updates (Could be dynamic based on user type)
              _buildRecentUpdatesSection(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey, 
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Handle view all categories
              },
              child: const Text(
                'View All',
                style: TextStyle(color: Colors.blueAccent, fontSize: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Assignment To Review Card (Teacher specific)
              if (widget.userType == UserType.teacher)
                _buildEmptyCategoryCard(
                  title: 'Assignment To Review',
                  placeholder: 'No assignments due',
                  color: Colors.blue[800]!,
                  context: context,
                ),
              if (widget.userType == UserType.teacher)
                const SizedBox(width: 16),

              // Attendance Track Now Card
              _buildEmptyCategoryCard(
                title: 'Attendance Track',
                placeholder: 'No data available',
                color: Colors.blue[800]!,
                context: context,
              ),
              const SizedBox(width: 16),

              // For a student, this might be "Upcoming Classes"
              if (widget.userType == UserType.student)
                _buildEmptyCategoryCard(
                  title: 'Upcoming Classes',
                  placeholder: 'No classes scheduled',
                  color: Colors.green[800]!,
                  context: context,
                ),
              if (widget.userType == UserType.student)
                const SizedBox(width: 16),

              // For a parent, this might be "Child Progress"
              if (widget.userType == UserType.parent)
                _buildEmptyCategoryCard(
                  title: 'Child Progress',
                  placeholder: 'No reports available',
                  color: Colors.purple[800]!,
                  context: context,
                ),
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
    return Container(
      width: MediaQuery.of(context).size.width * 0.45, // About half screen width
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            placeholder,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          
        ],
      ),
    );
  }

  Widget _buildMyTaskSection(BuildContext context) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Task',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Active'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Handle completed tasks filter
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Completed'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Placeholder for task list
        _buildEmptyPlaceholderCard(
          icon: Icons.assignment_outlined,
          message: 'No active tasks found.',
          buttonText: 'Add a new task',
          onButtonPressed: () {
            // Handle add task action
            print('Add new task for ${widget.userType}');
          },
        ),
        
      ],
    );
  }

  Widget _buildRecentUpdatesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Updates',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
      
        _buildEmptyPlaceholderCard(
          icon: Icons.info_outline,
          message: 'No recent updates at the moment.',
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (buttonText != null) const SizedBox(height: 16),
            if (buttonText != null)
              OutlinedButton(
                onPressed: onButtonPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                  side: const BorderSide(color: Colors.blueAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(buttonText),
              ),
          ],
        ),
      ),
    );
  }
}