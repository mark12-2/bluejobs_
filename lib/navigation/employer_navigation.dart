import 'package:bluejobs/chats/messaging_page.dart';
import 'package:bluejobs/default_screens/search.dart';
import 'package:bluejobs/employer_screens/create_jobpost.dart';
import 'package:bluejobs/employer_screens/employer_home.dart';
import 'package:bluejobs/employer_screens/employer_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmployerNavigation extends StatefulWidget {
  const EmployerNavigation({super.key});

  @override
  State<EmployerNavigation> createState() => _EmployerNavigationState();
}

class _EmployerNavigationState extends State<EmployerNavigation> {
  int _selectedIndex = 0;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _fetchVerificationData();
  }

  Future<void> _fetchVerificationData() async {
    final userId = 'uid';
    final verificationRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("verification")
        .doc(userId);

    final verificationSnap = await verificationRef.get();
    if (verificationSnap.exists) {
      setState(() {
        _isVerified = verificationSnap.data()?["isVerified"] ?? false;
      });
    }
  }

  List<Widget> get defaultScreens {
    return <Widget>[
      const EmployerHomePage(),
      const SearchPage(),
      _isVerified
          ? const CreateJobPostPage()
          : const Center(
              child: Text('Please verify your account to access this feature')),
      const MessagingPage(),
      const EmployerProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: defaultScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Create ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        unselectedItemColor: Color.fromARGB(255, 19, 8, 8),
        selectedItemColor: Color.fromARGB(255, 7, 16, 69),
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}
