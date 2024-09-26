import 'package:bluejobs/model/user_model.dart';
import 'package:bluejobs/screens_for_auth/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bluejobs/provider/auth_provider.dart' as auth_provider;
import 'package:provider/provider.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  String? _userName;
  String? _userEmail;
  String? _profileImage;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _loadUserProfile() async {
    final user = auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      final userData = await firestore.collection('users').doc(uid).get();
      final userModel = UserModel.fromMap(userData.data() ?? {});

      setState(() {
        _userName = userModel.firstName ?? '';
        _userEmail = userModel.email ?? '';
        _profileImage = userModel.profilePic;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final userLoggedIn =
        Provider.of<auth_provider.AuthProvider>(context, listen: false);
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              _userName ?? '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(_userEmail ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundImage: _profileImage != null
                  ? NetworkImage(_profileImage!)
                  : AssetImage(''),
              radius: 30,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: () async {
                    // await _authProvider.signOut();

                    userLoggedIn.userSignOut().then(
                          (value) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInPage(),
                            ),
                          ),
                        );
                  },
                ),
                // add menu items na mga gusto mo
              ],
            ),
          ),
        ],
      ),
    );
  }
}
