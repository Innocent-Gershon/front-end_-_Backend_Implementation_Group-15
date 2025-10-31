import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  
  AuthBloc({required AuthRepository authRepository}) 
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
  }

  void _onLoginWithEmail(LoginWithEmailEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final userCredential = await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        final userData = await _authRepository.getUserData(user.uid);
        
        emit(AuthAuthenticated(
          userId: user.uid,
          email: user.email ?? event.email,
          name: userData?['name'] ?? user.displayName ?? 'User', userType: '',
        ));
      } else {
        emit(const AuthError('Login failed'));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      bool showRegisterDialog = false;
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = '❌ No account found with this email. You need to register first!';
          showRegisterDialog = true;
          break;
        case 'wrong-password':
          errorMessage = '🔐 Oops! Wrong password. Double-check and try again.';
          break;
        case 'invalid-email':
          errorMessage = '📧 Invalid email format. Please enter a valid email address.';
          break;
        case 'user-disabled':
          errorMessage = '⛔ Account suspended. Contact support for assistance.';
          break;
        case 'too-many-requests':
          errorMessage = '⏰ Too many attempts! Please wait a moment and try again.';
          break;
        case 'invalid-credential':
          errorMessage = '❌ No account found with this email. You need to register first!';
          showRegisterDialog = true;
          break;
        case 'network-request-failed':
          errorMessage = '🌐 Network error. Check your internet connection.';
          break;
        default:
          errorMessage = '⚠️ Login failed: ${e.message}';
      }
      
      if (showRegisterDialog) {
        emit(AuthError('SHOW_REGISTER_DIALOG:$errorMessage'));
      } else {
        emit(AuthError(errorMessage));
      }
    } catch (e) {
      emit(AuthError('An unexpected error occurred'));
    }
  }

  void _onLoginWithGoogle(LoginWithGoogleEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final userCredential = await _authRepository.signInWithGoogle();
      final user = userCredential.user;
      
      if (user != null) {
        // Save user data if it's a new user
        final userData = await _authRepository.getUserData(user.uid);
        if (userData == null) {
          await _authRepository.saveUserData(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? 'Google User',
            userType: 'Student', // Default user type
          );
        }
        
        emit(AuthAuthenticated(
          userId: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'Google User', userType: '',
        ));
      } else {
        emit(const AuthError('Google sign in failed'));
      }
    } catch (e) {
      if (e.toString().contains('cancelled')) {
        emit(const AuthError('Google sign in was cancelled'));
      } else {
        emit(AuthError('Google sign in failed: ${e.toString()}'));
      }
    }
  }

  void _onSignUpRequested(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      // TODO: Implement Firebase sign up
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      emit(const AuthAuthenticated(
        userId: 'newuser123',
        email: 'newuser@example.com',
        name: 'New User', userType: '',
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Logout failed'));
    }
  }

  void _onSignUpWithEmail(SignUpWithEmailEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final userCredential = await _authRepository.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        await _authRepository.saveUserData(
          uid: user.uid,
          email: event.email,
          name: event.fullName,
          userType: event.userType,
          additionalData: event.additionalData,
        );
        
        emit(AuthAuthenticated(
          userId: user.uid,
          email: event.email,
          name: event.fullName, userType: '',
        ));
      } else {
        emit(const AuthError('Sign up failed'));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      bool showLoginDialog = false;
      
      switch (e.code) {
        case 'weak-password':
          errorMessage = '🔒 Password too weak! Use 6+ characters with letters & numbers.';
          break;
        case 'email-already-in-use':
          errorMessage = '📝 Email already registered! Looks like you already have an account.';
          showLoginDialog = true;
          break;
        case 'invalid-email':
          errorMessage = '📧 Invalid email format. Please enter a valid email address.';
          break;
        case 'operation-not-allowed':
          errorMessage = '⛔ Registration disabled. Contact support for assistance.';
          break;
        case 'network-request-failed':
          errorMessage = '🌐 Network error. Check your internet connection.';
          break;
        default:
          errorMessage = '⚠️ Registration failed: ${e.message}';
      }
      
      if (showLoginDialog) {
        emit(AuthError('SHOW_LOGIN_DIALOG:$errorMessage'));
      } else {
        emit(AuthError(errorMessage));
      }
    } catch (e) {
      emit(AuthError('An unexpected error occurred'));
    }
  }

  void _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        final userData = await _authRepository.getUserData(user.uid);
        emit(AuthAuthenticated(
          userId: user.uid,
          email: user.email ?? '',
          name: userData?['name'] ?? user.displayName ?? 'User', userType: '',
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  void _onPasswordResetRequested(AuthPasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(AuthPasswordResetSent(event.email));
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        default:
          errorMessage = 'Failed to send reset email: ${e.message}';
      }
      emit(AuthError(errorMessage));
    } catch (e) {
      emit(const AuthError('An unexpected error occurred'));
    }
  }
}