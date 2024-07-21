import 'package:bluejobs/model/posts_model.dart';
import 'package:bluejobs/provider/auth_provider.dart';
import 'package:bluejobs/provider/posts_provider.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../styles/custom_theme.dart';

class EditPost extends StatefulWidget {
  final String postId;

  const EditPost({super.key, required this.postId});

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    fetchPostById(widget.postId);
  }

  final _formKey = GlobalKey<FormState>();
  String? _description;
  String? _type;
  String? _rate;
  bool _isLoading = true;
  Post? _post;

  // fetch specific post
  Future<void> fetchPostById(String postId) async {
    try {
      final postRef =
          FirebaseFirestore.instance.collection('Posts').doc(postId);
      final docRef = await postRef.get();

      if (docRef.exists) {
        final post = Post.fromMap(docRef.data() ?? {});
        if (post.ownerId == _authProvider.uid) {
          setState(() {
            _post = post;
            _description = _post?.description;
            _type = _post?.type;
            // _rate = _post?.rate;
            _isLoading = false;
          });
        } else {
          debugPrint("You don't have permission to edit this post!");
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        debugPrint("No post found!");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching post: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        'Edit Post',
                        style: CustomTextStyle.semiBoldText.copyWith(
                          color: Colors.black,
                          fontSize: responsiveSize(context, 0.07),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        initialValue: _description,
                        decoration: customInputDecoration('Description'),
                        maxLines: 20,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        onSaved: (value) => _description = value,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: _type,
                        decoration: customInputDecoration('Type of Job'),
                        maxLines: 10,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        onSaved: (value) => _type = value,
                      ),
                      const SizedBox(height: 20),
                      // TextFormField(
                      //   initialValue: _rate,
                      //   decoration: customInputDecoration('Rate'),
                      //   maxLines: 5,
                      //   minLines: 1,
                      //   keyboardType: TextInputType.multiline,
                      //   onSaved: (value) => _rate = value,
                      // ),
                      // const SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          ElevatedButton(
                            onPressed: () => _savePost(),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // update post method
  Future<void> _savePost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final post = Post(
          id: widget.postId,
          description: _description ?? _post?.description,
          type: _type ?? _post?.type,
        );

        final postsProvider =
            Provider.of<PostsProvider>(context, listen: false);
        await postsProvider.updatePost(widget.postId as Post, post);

        Navigator.pop(context);
      } catch (e) {
        debugPrint("Error saving post: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving post: $e")),
        );
      }
    }
  }
}
