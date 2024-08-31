import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SideBar extends StatefulWidget {
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  String? _userName;
  String? _userEmail;
  String? _profileImage;

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? 'Unknown User';
        _userEmail = user.email ?? 'unknown@example.com';
        _profileImage = user.photoURL;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder(
        future: _loadUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading user profile'));
          } else {
            return Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: GestureDetector(
                    // onTap: () {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => ProfileScreen()),
                    //   );
                    // },
                    child: Text(
                      _userName ?? 'Unknown User',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  accountEmail: Text(_userEmail ?? 'unknown@example.com'),
                  currentAccountPicture: GestureDetector(
                    // onTap: () {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => ProfileScreen()),
                    //   );
                    // },
                    child: CircleAvatar(
                      backgroundImage: _profileImage != null
                          ? NetworkImage(_profileImage!)
                          : AssetImage('assets/profile.jpg'),
                      radius: 30,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                      ),
                      // Add more menu items here
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
