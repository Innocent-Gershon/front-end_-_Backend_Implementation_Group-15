import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';

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
        
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3366FF)),
            ),
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
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF3366FF),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Color(0xFF3366FF),
          elevation: 0,
          title: Text(
            'EduBridge',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildProfileHeader(context)),
            SliverToBoxAdapter(child: _buildCategoriesSection(context)),
            SliverToBoxAdapter(child: _buildMyTaskSection(context)),
            SliverToBoxAdapter(child: _buildRecentUpdatesSection(context)),
            SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        bottomNavigationBar: _buildIOSBottomNav(),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      color: Color(0xFFF8FAFC),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/avatar.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Color(0xFF3366FF),
                        child: Center(
                          child: Text(
                            widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'S',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF000000),
                      ),
                    ),
                    Text(
                      widget.userName.isNotEmpty ? widget.userName : 'Sarah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF3366FF),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3366FF), Color(0xFF5A7FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF3366FF).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(Icons.search_rounded, color: Colors.white, size: 22),
              ),
              SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFF6B6B).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFC107),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(height: 1, color: Color(0xFFD0D0D0)),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFAAAAAA),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildCategoryCard('Assignment', 'To Review', 'Due Today: 3', 0.6, '60%')),
              SizedBox(width: 16),
              Expanded(child: _buildCategoryCard('Attendance', 'Track Now', '87% This Week', 0.75, '75%')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, String detail, double progress, String progressText) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3366FF), Color(0xFF2952CC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3366FF).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(subtitle, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white.withOpacity(0.9))),
                SizedBox(height: 4),
                Text(detail, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16, top: 8),
                    child: Text(progressText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                  ),
                  Spacer(),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.only(right: 16, top: 12),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Color(0xFFF5F5F5),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3366FF)),
                        minHeight: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTaskSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Task',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF000000)),
          ),
          SizedBox(height: 16),
          Container(
            height: 40,
            decoration: BoxDecoration(color: Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Center(
                      child: Text('Active', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text('Completed', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF333333))),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          _buildTaskCard('Design task management dashboard', 'Create wireframes and mockups for the main dashboard.', 'High', Color(0xFFFFC107), '10 October'),
          SizedBox(height: 16),
          _buildTaskCard('Design task management dashboard', 'Create wireframes and mockups for the main dashboard.', 'Medium', Color(0xFF3366FF), '20 October'),
        ],
      ),
    );
  }

  Widget _buildTaskCard(String title, String description, String priority, Color priorityColor, String dueDate) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF000000))),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: priorityColor, borderRadius: BorderRadius.circular(12)),
                child: Text(priority, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(description, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFAAAAAA))),
          SizedBox(height: 12),
          Row(
            children: [
              _buildTag('UI'),
              SizedBox(width: 8),
              _buildTag('Design'),
            ],
          ),
          SizedBox(height: 12),
          Container(height: 1, color: Color(0xFFF5F5F5)),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Color(0xFFAAAAAA)),
                  SizedBox(width: 4),
                  Text('In Progress', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFFAAAAAA))),
                ],
              ),
              Text('Due date: $dueDate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFFAAAAAA))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF333333))),
    );
  }

  Widget _buildRecentUpdatesSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Text(
        'Recent Updates',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF000000)),
      ),
    );
  }

  Widget _buildIOSBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.chat_bubble_outline, 'Chats', 1),
              _buildNavItem(Icons.school_outlined, 'Classes', 2),
              _buildNavItem(Icons.settings_outlined, 'Settings', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Color(0xFF3366FF) : Color(0xFF333333), size: 24),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isActive ? Color(0xFF3366FF) : Color(0xFF333333))),
        ],
      ),
    );
  }
}
