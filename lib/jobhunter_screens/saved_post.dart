import 'package:bluejobs/default_screens/view_post.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavedPostsPage extends StatefulWidget {
  final String userId;

  const SavedPostsPage({required this.userId});

  @override
  _SavedPostsPageState createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> {
  List<Post> _savedPosts = [];

  @override
  void initState() {
    super.initState();
    _fetchSavedPosts();
  }

  Future<void> _fetchSavedPosts() async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(widget.userId);
    final savedPostsRef = userRef.collection('saved');
    final savedPostsSnapshot = await savedPostsRef.get();
    List savedPostIds =
        savedPostsSnapshot.docs.map((doc) => doc.get('postId')).toList();
    List<Post> savedPosts = [];
    for (String postId in savedPostIds) {
      final postRef =
          FirebaseFirestore.instance.collection('Posts').doc(postId);
      final postDoc = await postRef.get();
      final postData = postDoc.data();
      if (postData != null) {
        savedPosts.add(Post(
          id: postId,
          title: postData['title'] ?? '',
          location: postData['location'] ?? '',
          profilePicUrl: postData['profilePic'] ?? '',
        ));
      }
    }
    setState(() {
      _savedPosts = savedPosts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Posts'),
      ),
      body: _savedPosts.isEmpty
          ? Center(
              child: Text('No saved posts'),
            )
          : ListView.builder(
              itemCount: _savedPosts.length,
              itemBuilder: (context, index) {
                final post = _savedPosts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(post.profilePicUrl),
                  ),
                  title: Text(post.title),
                  subtitle: Text(post.location),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewPostPage(postId: post.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class Post {
  final String id;
  final String title;
  final String location;
  final String profilePicUrl;

  Post(
      {required this.id,
      required this.title,
      required this.location,
      required this.profilePicUrl});
}
