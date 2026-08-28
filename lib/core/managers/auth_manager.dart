import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum AuthStatus {
  initial,
  loading,
  unauthenticated,
  authenticated,
}

final authManager = AuthManager();

class AuthManager extends ChangeNotifier {
  AuthManager() {
    _init();
  }

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  User? _user;
  User? get user => _user;

  String? _role;
  String? get role => _role;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot>? _roleSubscription;

  void _init() {
    _status = AuthStatus.loading;
    notifyListeners();

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      _roleSubscription?.cancel(); // Cancel previous role subscription

      if (user == null) {
        _role = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      } else {
        // User logged in, now fetch and listen to their role
        _status = AuthStatus.loading; // Wait for role
        notifyListeners();

        _roleSubscription = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data();
            _role = data?['role'] as String?;
          } else {
            _role = null;
          }
          _status = AuthStatus.authenticated;
          notifyListeners();
        }, onError: (e) {
          _role = null;
          _status = AuthStatus.unauthenticated;
          notifyListeners();
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _roleSubscription?.cancel();
    super.dispose();
  }
}
