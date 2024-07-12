import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordResetProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _newPassword = '';
  String _email = '';

  String get email => _email;
  String get newPassword => _newPassword;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setNewPassword(String newPassword) {
    _newPassword = newPassword;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail() async {
    try {
      await _auth.sendPasswordResetEmail(email: _email);
      print('Password reset email sent');
    } catch (e) {
      print('Error sending password reset email: $e');
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    await sendPasswordResetEmail();
    // Show a dialog to enter the action code
    String? code = await showDialog<String>(
      context: context,
      builder: (context) {
        final codeController = TextEditingController();
        return AlertDialog(
          title: Text('Enter the code from the password reset email'),
          content: TextFormField(
            controller: codeController,
          ),
          actions: [
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () {
                Navigator.pop(context, codeController.text);
              },
            ),
          ],
        );
      },
    );
    // Validate the entered action code and new password
    if (code != null && code.isNotEmpty && _newPassword.isNotEmpty) {
      await _handlePasswordReset(code, context);
    } else {
      print('Invalid code or new password');
    }
  }

  Future<void> _handlePasswordReset(String code, BuildContext context) async {
    try {
      // Confirm the password reset
      await _auth.confirmPasswordReset(
        code: code,
        newPassword: _newPassword,
      );
      // Update the user's password
      await _auth.currentUser?.updatePassword(_newPassword);
      // Redirect the user back to the app
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      print('Error handling password reset: $e');
    }
  }
}
