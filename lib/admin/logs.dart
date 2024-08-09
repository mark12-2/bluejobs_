import 'package:bluejobs/admin/user_logs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bluejobs/styles/custom_theme.dart';

class ActivityLogs extends StatefulWidget {
  const ActivityLogs({super.key});

  @override
  State<ActivityLogs> createState() => _AvtivityLogsState();
}

class _AvtivityLogsState extends State<ActivityLogs> {
  final TextEditingController _userSearchController = TextEditingController();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _userSearchController.dispose();

    super.dispose();
  }

  void _fetchUsers() async {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final usersSnapshot = await usersRef.get();
    List<Map<String, dynamic>> allUsers = usersSnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'firstName': doc.get('firstName') ?? '',
        'middleName': doc.get('middleName') ?? '',
        'lastName': doc.get('lastName') ?? '',
        'suffix': doc.get('suffix') ?? '',
        'profilePic': doc.get('profilePic') ?? '',
        'role': doc.get('role') ?? '',
        'uid': doc.get('uid') ?? '',
      };
    }).toList();
    setState(() {
      _allUsers = allUsers;
      _filteredUsers = allUsers;
    });
  }

  void _filterUsers(String query) {
    query = query.toLowerCase();
    List<Map<String, dynamic>> filteredUsers = _allUsers.where((user) {
      String fullName =
          '${user['firstName']} ${user['middleName']} ${user['lastName']}';
      return fullName.toLowerCase().contains(query) ||
          user['role'].toLowerCase().contains(query);
    }).toList();
    setState(() {
      _filteredUsers = filteredUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('User Management'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _userSearchController,
                decoration: customInputDecoration('Search users...').copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _filterUsers(_userSearchController.text);
                    },
                  ),
                ),
                onChanged: (value) {
                  _filterUsers(value);
                },
              ),
            ),
            Expanded(
              child: _filteredUsers.isEmpty
                  ? const Center(
                      child: Text(
                        'No users available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        var user = _filteredUsers[index];
                        String fullName =
                            '${user['firstName']} ${user['middleName']} ${user['lastName']} ${user['suffix']}';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user['profilePic']),
                          ),
                          title: Text(fullName),
                          subtitle: Text(user['role']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserLogs(),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ));
  }
}
