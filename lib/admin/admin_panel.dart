import 'package:bluejobs/default_screens/view_post.dart';
import 'package:bluejobs/default_screens/view_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bluejobs/styles/custom_theme.dart';
import 'package:bluejobs/provider/posts_provider.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _postSearchController = TextEditingController();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  List<Map<String, dynamic>> _allPosts = [];
  List<Map<String, dynamic>> _filteredPosts = [];
  int _currentTab = 0;
  final PostsProvider postsProvider = PostsProvider();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchPosts();
  }

  @override
  void dispose() {
    _userSearchController.dispose();
    _postSearchController.dispose();
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

  void _fetchPosts() async {
    final postsRef = FirebaseFirestore.instance.collection('Posts');
    final postsSnapshot = await postsRef.get();
    List<Map<String, dynamic>> allPosts = postsSnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'title': doc.get('title') ?? '',
        'description': doc.get('description') ?? '',
        'type': doc.get('type') ?? '',
        'ownerId': doc.get('ownerId') ?? '',
        'location': doc.get('location') ?? '',
        'name': doc.get('name') ?? '',
        'profilePic': doc.get('profilePic') ?? '',
      };
    }).toList();
    setState(() {
      _allPosts = allPosts;
      _filteredPosts = allPosts;
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

  void _filterPosts(String query) {
    query = query.toLowerCase();
    List<Map<String, dynamic>> filteredPosts = _allPosts.where((post) {
      return post['title'].toLowerCase().contains(query) ||
          post['location'].toLowerCase().contains(query) ||
          post['description'].toLowerCase().contains(query) ||
          post['type'].toLowerCase().contains(query);
    }).toList();
    setState(() {
      _filteredPosts = filteredPosts;
    });
  }

  void _disableUser(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    await userRef.update({'isEnabled': false});
  }

  void _deletePost(String postId) async {
    final postRef = _firestore.collection('Posts').doc(postId);
    await postRef.delete();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Users'),
              Tab(text: 'Posts'),
            ],
            onTap: (index) {
              setState(() {
                _currentTab = index;
              });
            },
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _userSearchController,
                    decoration:
                        customInputDecoration('Search users...').copyWith(
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
                                backgroundImage:
                                    NetworkImage(user['profilePic']),
                              ),
                              title: Text(fullName),
                              subtitle: Text(user['role']),
                              //                 trailing: user['isEnabled']
                              // ? ElevatedButton(
                              //     onPressed: () async {
                              //       _disableUser(user['id']);
                              //       setState(() {
                              //         _filteredUsers[index]['isEnabled'] = false;
                              //       });
                              //     },
                              //     child: Text('Disable Account'),
                              //   )
                              // : Text('Account Disabled'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProfilePage(userId: user['uid']),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _postSearchController,
                    decoration:
                        customInputDecoration('Search posts...').copyWith(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          _filterPosts(_postSearchController.text);
                        },
                      ),
                    ),
                    onChanged: (value) {
                      _filterPosts(value);
                    },
                  ),
                ),
                Expanded(
                  child: _filteredPosts.isEmpty
                      ? const Center(
                          child: Text(
                            'No posts available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredPosts.length,
                          itemBuilder: (context, index) {
                            var post = _filteredPosts[index];

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(post['profilePic']),
                              ),
                              title: Text(post['title'].isEmpty
                                  ? post['type']
                                  : post['title']),
                              subtitle: Text(post['location'].isEmpty
                                  ? post['description']
                                  : post['location']),
                              trailing: ElevatedButton(
                                onPressed: () async {
                                  _deletePost(post['id']);
                                  setState(() {
                                    _filteredPosts.removeAt(index);
                                  });
                                },
                                child: Text('Delete Post'),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ViewPostPage(postId: post['id']),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
