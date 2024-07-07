import 'package:bluejobs/provider/auth_provider.dart';
import 'package:bluejobs/styles/custom_button.dart';
import 'package:bluejobs/styles/custom_theme.dart';
import 'package:bluejobs/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordChange extends StatefulWidget {
  const PasswordChange({super.key});

  @override
  State<PasswordChange> createState() => _PasswordChangeState();
}

class _PasswordChangeState extends State<PasswordChange> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _isCurrentPasswordFocused = false;
  bool _isNewPasswordFocused = false;
  bool _isConfirmNewPasswordFocused = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: _currentPasswordController,
                focusNode: FocusNode(),
                decoration: customInputDecoration('Current Password'),
                obscureText: true,
              ),
              if (_isCurrentPasswordFocused)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Enter your current password',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              SizedBox(height: 20),
              TextField(
                controller: _newPasswordController,
                focusNode: FocusNode(),
                decoration: customInputDecoration('New Password'),
                obscureText: true,
              ),
              if (_isNewPasswordFocused)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Enter a new password',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              SizedBox(height: 20),
              TextField(
                controller: _confirmNewPasswordController,
                focusNode: FocusNode(),
                decoration: customInputDecoration('Confirm New Password'),
                obscureText: true,
              ),
              if (_isConfirmNewPasswordFocused)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Confirm your new password',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              SizedBox(height: 40),
              CustomButton(
                buttonText: 'Change Password',
                onPressed: () {
                  // Add logic to change password here
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changePassword() async {
  if (_currentPasswordController.text.isEmpty ||
      _newPasswordController.text.isEmpty ||
      _confirmNewPasswordController.text.isEmpty) {
    showSnackBar(context, 'Please fill in all fields');
    return;
  }

  if (_newPasswordController.text != _confirmNewPasswordController.text) {
    showSnackBar(context, 'New passwords do not match');
    return;
  }

  final ap = Provider.of<AuthProvider>(context, listen: false);
  final user = ap.userModel;

  try {
    await ap.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    showSnackBar(context, 'Password changed successfully');
    Navigator.pop(context);
  } catch (e) {
    showSnackBar(context, 'Error changing password: $e');
  }
}
}