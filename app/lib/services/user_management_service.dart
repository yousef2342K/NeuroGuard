import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserManagementService {
  static final UserManagementService _instance = UserManagementService._internal();
  factory UserManagementService() => _instance;
  UserManagementService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User roles
  static const String rolePatient = 'patient';
  static const String roleCaregiver = 'caregiver';
  static const String roleClinician = 'clinician';
  static const String roleAdmin = 'admin';

  // Get all available roles
  static List<String> get availableRoles => [
        rolePatient,
        roleCaregiver,
        roleClinician,
        roleAdmin,
      ];

  // Get role display name in Arabic
  static String getRoleDisplayName(String role) {
    switch (role) {
      case rolePatient:
        return 'مريض';
      case roleCaregiver:
        return 'مقدم رعاية';
      case roleClinician:
        return 'طبيب';
      case roleAdmin:
        return 'مدير';
      default:
        return role;
    }
  }

  // Get role description in Arabic
  static String getRoleDescription(String role) {
    switch (role) {
      case rolePatient:
        return 'مراقبة الحالة الصحية وتلقي التنبيهات';
      case roleCaregiver:
        return 'مراقبة المرضى المكلفين بهم';
      case roleClinician:
        return 'مراجعة التقارير الطبية واتخاذ القرارات';
      case roleAdmin:
        return 'إدارة النظام والمستخدمين';
      default:
        return '';
    }
  }

  // Check if user has specific role
  Future<bool> hasRole(String userId, String role) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return userData['role'] == role;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String userId) async {
    return hasRole(userId, roleAdmin);
  }

  // Check if user is clinician
  Future<bool> isClinician(String userId) async {
    return hasRole(userId, roleClinician);
  }

  // Check if user is caregiver
  Future<bool> isCaregiver(String userId) async {
    return hasRole(userId, roleCaregiver);
  }

  // Check if user is patient
  Future<bool> isPatient(String userId) async {
    return hasRole(userId, rolePatient);
  }

  // Get user role
  Future<String?> getUserRole(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return userData['role'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user role (admin only)
  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Check if current user is admin
      if (!await isAdmin(currentUser.uid)) {
        throw Exception('غير مصرح لك بتغيير أدوار المستخدمين');
      }

      // Validate role
      if (!availableRoles.contains(newRole)) {
        throw Exception('دور غير صحيح');
      }

      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': currentUser.uid,
      });

      return true;
    } catch (e) {
      throw Exception('فشل في تحديث دور المستخدم: $e');
    }
  }

  // Get all users (admin only)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      // Check if current user is admin
      if (!await isAdmin(currentUser.uid)) {
        throw Exception('غير مصرح لك بعرض جميع المستخدمين');
      }

      final querySnapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب المستخدمين: $e');
    }
  }

  // Get users by role
  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .orderBy('name')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب المستخدمين حسب الدور: $e');
    }
  }

  // Get patients for caregiver
  Future<List<Map<String, dynamic>>> getPatientsForCaregiver(String caregiverId) async {
    try {
      final querySnapshot = await _firestore
          .collection('user_relationships')
          .where('caregiverId', isEqualTo: caregiverId)
          .where('relationshipType', isEqualTo: 'caregiver_patient')
          .get();

      final patientIds = querySnapshot.docs
          .map((doc) => doc.data()['patientId'] as String)
          .toList();

      if (patientIds.isEmpty) return [];

      final patientsSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: patientIds)
          .get();

      return patientsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب المرضى: $e');
    }
  }

  // Get patients for clinician
  Future<List<Map<String, dynamic>>> getPatientsForClinician(String clinicianId) async {
    try {
      final querySnapshot = await _firestore
          .collection('user_relationships')
          .where('clinicianId', isEqualTo: clinicianId)
          .where('relationshipType', isEqualTo: 'clinician_patient')
          .get();

      final patientIds = querySnapshot.docs
          .map((doc) => doc.data()['patientId'] as String)
          .toList();

      if (patientIds.isEmpty) return [];

      final patientsSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: patientIds)
          .get();

      return patientsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw Exception('فشل في جلب المرضى: $e');
    }
  }

  // Create relationship between caregiver and patient
  Future<bool> createCaregiverPatientRelationship({
    required String caregiverId,
    required String patientId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Check if current user is admin or clinician
      final currentUserRole = await getUserRole(currentUser.uid);
      if (currentUserRole != roleAdmin && currentUserRole != roleClinician) {
        throw Exception('غير مصرح لك بإنشاء علاقات المستخدمين');
      }

      // Check if caregiver exists and has correct role
      if (!await isCaregiver(caregiverId)) {
        throw Exception('المستخدم المحدد ليس مقدم رعاية');
      }

      // Check if patient exists and has correct role
      if (!await isPatient(patientId)) {
        throw Exception('المستخدم المحدد ليس مريض');
      }

      await _firestore.collection('user_relationships').add({
        'caregiverId': caregiverId,
        'patientId': patientId,
        'relationshipType': 'caregiver_patient',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser.uid,
        'isActive': true,
      });

      return true;
    } catch (e) {
      throw Exception('فشل في إنشاء العلاقة: $e');
    }
  }

  // Create relationship between clinician and patient
  Future<bool> createClinicianPatientRelationship({
    required String clinicianId,
    required String patientId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Check if current user is admin
      if (!await isAdmin(currentUser.uid)) {
        throw Exception('غير مصرح لك بإنشاء علاقات المستخدمين');
      }

      // Check if clinician exists and has correct role
      if (!await isClinician(clinicianId)) {
        throw Exception('المستخدم المحدد ليس طبيب');
      }

      // Check if patient exists and has correct role
      if (!await isPatient(patientId)) {
        throw Exception('المستخدم المحدد ليس مريض');
      }

      await _firestore.collection('user_relationships').add({
        'clinicianId': clinicianId,
        'patientId': patientId,
        'relationshipType': 'clinician_patient',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser.uid,
        'isActive': true,
      });

      return true;
    } catch (e) {
      throw Exception('فشل في إنشاء العلاقة: $e');
    }
  }

  // Deactivate user account
  Future<bool> deactivateUser(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Check if current user is admin
      if (!await isAdmin(currentUser.uid)) {
        throw Exception('غير مصرح لك بتعطيل المستخدمين');
      }

      await _firestore.collection('users').doc(userId).update({
        'isActive': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
        'deactivatedBy': currentUser.uid,
      });

      return true;
    } catch (e) {
      throw Exception('فشل في تعطيل المستخدم: $e');
    }
  }

  // Reactivate user account
  Future<bool> reactivateUser(String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Check if current user is admin
      if (!await isAdmin(currentUser.uid)) {
        throw Exception('غير مصرح لك بإعادة تفعيل المستخدمين');
      }

      await _firestore.collection('users').doc(userId).update({
        'isActive': true,
        'reactivatedAt': FieldValue.serverTimestamp(),
        'reactivatedBy': currentUser.uid,
      });

      return true;
    } catch (e) {
      throw Exception('فشل في إعادة تفعيل المستخدم: $e');
    }
  }
}
