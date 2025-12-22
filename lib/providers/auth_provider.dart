import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

enum UserRole { admin, teacher, student }

class AuthProvider with ChangeNotifier {
  UserRole? _userRole;
  String? _userId;
  String? _username;
  bool _isLoading = false;

  UserRole? get userRole => _userRole;
  String? get userId => _userId;
  String? get username => _username;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _userId != null;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> loginAdmin(String username, String password) async {
    print('🔍 AUTH PROVIDER: Starting admin login...');
    print('🔍 AUTH PROVIDER: Username to search: "$username"');
    print('🔍 AUTH PROVIDER: Password to match: "$password"');

    _isLoading = true;
    notifyListeners();

    try {
      print('🔍 AUTH PROVIDER: Querying Firestore...');

      final querySnapshot = await _firestore
          .collection('administrators')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      print('🔍 AUTH PROVIDER: Query completed');
      print('🔍 AUTH PROVIDER: Documents found: ${querySnapshot.docs.length}');

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        print('✅ AUTH PROVIDER: Match found!');
        print('✅ AUTH PROVIDER: Document ID: ${doc.id}');
        print('✅ AUTH PROVIDER: Document data: ${doc.data()}');

        _userId = doc.id;
        _username = username;
        _userRole = UserRole.admin;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        print('❌ AUTH PROVIDER: No matching document found');

        // Let's check what documents exist
        print('🔍 AUTH PROVIDER: Checking all administrators...');
        final allDocs = await _firestore.collection('administrators').get();
        print('🔍 AUTH PROVIDER: Total administrators in DB: ${allDocs.docs.length}');

        for (var doc in allDocs.docs) {
          print('   📄 Document ${doc.id}:');
          print('      - username: "${doc.data()['username']}"');
          print('      - password: "${doc.data()['password']}"');
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('💥 AUTH PROVIDER ERROR: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginTeacher(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('teachers')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _userId = querySnapshot.docs.first.id;
        _username = username;
        _userRole = UserRole.teacher;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Teacher login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Student?> getStudentByIndexNumber(String indexNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('students')
          .where('uniqueId', isEqualTo: indexNumber)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Student.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Get student error: $e');
      return null;
    }
  }

  void logout() {
    _userId = null;
    _username = null;
    _userRole = null;
    notifyListeners();
  }
}