import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, error }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  AuthStatus _status = AuthStatus.unauthenticated;
  String? _errorMessage;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  // Getters
  User? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;

  // --- NOVA FUNÇÃO: RECUPERAR PALAVRA-PASSE ---
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _parseAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = "Erro inesperado ao enviar e-mail.";
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> signInWithEmail(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithEmail(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _parseAuthError(e.code);
      notifyListeners();
      return false;
    }
  }

  // Registo
  Future<bool> signUpWithEmail(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUpWithEmail(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _parseAuthError(e.code);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  // Tradutor de erros do Firebase para Português
  String _parseAuthError(String code) {
    switch (code) {
      case 'user-not-found': return 'Utilizador não encontrado.';
      case 'wrong-password': return 'Senha incorreta.';
      case 'email-already-in-use': return 'Este email já está em uso.';
      case 'weak-password': return 'A senha é demasiado fraca.';
      case 'invalid-email': return 'O formato do email é inválido.';
      case 'too-many-requests': return 'Muitas tentativas. Tente mais tarde.';
      default: return 'Ocorreu um erro. Verifique os dados.';
    }
  }
}