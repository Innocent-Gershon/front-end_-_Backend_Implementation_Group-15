import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleSignInTest extends StatefulWidget {
  const GoogleSignInTest({super.key});

  @override
  State<GoogleSignInTest> createState() => _GoogleSignInTestState();
}

class _GoogleSignInTestState extends State<GoogleSignInTest> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _status = 'Ready to test';
  User? _user;
  Map<String, dynamic>? _userData;

  Future<void> _testGoogleSignIn() async {
    try {
      setState(() => _status = 'Starting Google Sign-In...');
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        setState(() => _status = 'Sign in cancelled by user');
        return;
      }

      setState(() => _status = 'Getting authentication credentials...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      setState(() => _status = 'Signing in to Firebase...');
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      setState(() => _status = 'Checking user data...');
      final user = userCredential.user;
      if (user != null) {
        // Check if user data exists in Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();
        
        if (!doc.exists) {
          setState(() => _status = 'Creating user profile...');
          // Create user profile
          final userData = {
            'uid': user.uid,
            'email': user.email,
            'name': user.displayName,
            'userType': 'Student',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };
          
          await _firestore.collection('users').doc(user.uid).set(userData);
          _userData = userData;
        } else {
          _userData = doc.data();
        }
        
        setState(() {
          _user = user;
          _status = '✅ Google Sign-In successful!';
        });
      }
      
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      setState(() => _status = 'Signing out...');
      await _googleSignIn.signOut();
      await _auth.signOut();
      setState(() {
        _user = null;
        _userData = null;
        _status = '✅ Signed out successfully';
      });
    } catch (e) {
      setState(() => _status = '❌ Sign out error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign-In Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_user != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'User Information:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Name', _user!.displayName ?? 'N/A'),
                      _buildInfoRow('Email', _user!.email ?? 'N/A'),
                      _buildInfoRow('UID', _user!.uid),
                      _buildInfoRow('Email Verified', _user!.emailVerified.toString()),
                      if (_userData != null) ...[
                        const Divider(),
                        const Text(
                          'Firestore Data:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('User Type', _userData!['userType'] ?? 'N/A'),
                        _buildInfoRow('Created At', _userData!['createdAt']?.toString() ?? 'N/A'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Sign Out'),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _testGoogleSignIn,
                  icon: const Icon(Icons.login),
                  label: const Text('Test Google Sign In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Instructions:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('1. Tap "Test Google Sign In"'),
                    Text('2. Select a Google account'),
                    Text('3. Check if user data is created in Firestore'),
                    Text('4. Verify sign out functionality'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
