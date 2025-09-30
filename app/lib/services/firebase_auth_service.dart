import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<Map<String, dynamic>?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Get user data from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          return {
            'uid': result.user!.uid,
            'email': result.user!.email,
            'name': userData['name'],
            'role': userData['role'],
            'createdAt': userData['createdAt'],
            'isEmailVerified': result.user!.emailVerified,
          };
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  // Sign up with email and password
  Future<Map<String, dynamic>?> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Create user account
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(name);

        // Save user data to Firestore
        final userData = {
          'name': name,
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'lastLogin': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(userData);

        // Return user data
        return {
          'uid': result.user!.uid,
          'email': result.user!.email,
          'name': name,
          'role': role,
          'createdAt': DateTime.now().toIso8601String(),
          'isEmailVerified': result.user!.emailVerified,
        };
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('General Error: $e');
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('فشل في تسجيل الخروج: $e');
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      if (currentUser != null && !currentUser!.emailVerified) {
        await currentUser!.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('فشل في إرسال رابط التحقق: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('فشل في إرسال رابط إعادة تعيين كلمة المرور: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? email,
  }) async {
    try {
      if (currentUser != null) {
        if (name != null) {
          await currentUser!.updateDisplayName(name);
        }
        if (email != null) {
          await currentUser!.updateEmail(email);
        }

        // Update Firestore
        final updateData = <String, dynamic>{};
        if (name != null) updateData['name'] = name;
        if (email != null) updateData['email'] = email;

        if (updateData.isNotEmpty) {
          await _firestore
              .collection('users')
              .doc(currentUser!.uid)
              .update(updateData);
        }
      }
    } catch (e) {
      throw Exception('فشل في تحديث الملف الشخصي: $e');
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        return {
          'uid': uid,
          'name': data['name'],
          'email': data['email'],
          'role': data['role'],
          'createdAt': data['createdAt'],
          'isActive': data['isActive'] ?? true,
        };
      }
      return null;
    } catch (e) {
      throw Exception('فشل في جلب بيانات المستخدم: $e');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لا يوجد مستخدم بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات المسموح، حاول لاحقاً';
      case 'operation-not-allowed':
        return 'هذه العملية غير مسموحة';
      case 'invalid-credential':
        return 'بيانات الاعتماد غير صحيحة';
      default:
        return 'حدث خطأ في المصادقة: ${e.message}';
    }
  }
}
