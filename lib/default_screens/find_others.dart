import 'package:bluejobs/default_screens/view_profile.dart';
import 'package:bluejobs/jobhunter_screens/details_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FindOthersPage extends StatefulWidget {
  const FindOthersPage({super.key});

  @override
  State<FindOthersPage> createState() => _FindOthersPageState();
}

class _FindOthersPageState extends State<FindOthersPage> {
  final List<String> skills = [
    "Carpentry",
    "Plumbing",
    "Sewing",
    "Doing Laundry",
    "Electrician",
    "Mechanic",
    "Construction Worker",
    "Factory Worker",
    "Welder",
    "Painter",
    "Landscaper",
    "Janitor",
    "HVAC Technician",
    "Heavy Equipment Operator",
    "Truck Driver",
    "Roofer",
    "Mason",
    "Steelworker",
    "Pipefitter",
    "Boilermaker",
    "Chef",
    "Butcher",
    "Baker",
    "Fisherman",
    "Miner",
    "Housekeeper",
    "Security Guard",
    "Firefighter",
    "Paramedic",
    "Nursing Assistant",
    "Retail Worker",
    "Warehouse Worker"
  ];

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final usersSnapshot = await usersRef.get();
    List<Map<String, dynamic>> allUsers = usersSnapshot.docs
        .where((doc) => doc.get('role') == 'Job Hunter')
        .map((doc) {
      return {
        'id': doc.id,
        'firstName': doc.get('firstName') ?? '',
        'middleName': doc.get('middleName') ?? '',
        'lastName': doc.get('lastName') ?? '',
        'suffix': doc.get('suffix') ?? '',
        'profilePic': doc.get('profilePic') ?? '',
        'role': doc.get('role') ?? '',
        'uid': doc.get('uid') ?? '',
        'skills': (doc.get('skills') as List<dynamic>).join(', ') ?? '',
      };
    }).toList();
    setState(() {
      _allUsers = allUsers;
      _filteredUsers = allUsers;
    });
  }

  void _filterUsersBySkill(String query) {
    List<Map<String, dynamic>> filteredUsers = _allUsers.where((user) {
      return user['skills'].toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      _filteredUsers = filteredUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Others'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return skills.where((skill) => skill
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) {
                _searchController.text = selection;
                _filterUsersBySkill(selection);
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onEditingComplete) {
                return TextField(
                  controller: _searchController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Search for a skill',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _filterUsersBySkill(value);
                  },
                );
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
                        subtitle: Text(user['skills']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  JobHunterResumeView(userId: user['uid']),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
