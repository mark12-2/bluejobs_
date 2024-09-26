import 'package:bluejobs/employer_screens/job_posts_page.dart';
import 'package:bluejobs/model/posts_model.dart';
import 'package:bluejobs/navigation/jobhunter_navigation.dart';
import 'package:bluejobs/provider/posts_provider.dart';
import 'package:bluejobs/styles/custom_theme.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  // firestore storage access
  final PostsProvider createdPost = PostsProvider();
  // text controllers
  final _descriptionController = TextEditingController();
  final _typeController = TextEditingController();

  final _descriptionFocusNode = FocusNode();
  final _typeFocusNode = FocusNode();

  bool _isDescriptionFocused = false;
  bool _isTypeFocused = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _typeController.dispose();
    // _rateController.dispose();
    _descriptionFocusNode.dispose();
    _typeFocusNode.dispose();
    // _rateFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _descriptionFocusNode.addListener(_onFocusChange);
    // _rateFocusNode.addListener(_onFocusChange);
    _typeFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isDescriptionFocused = _descriptionFocusNode.hasFocus;
      // _isRateFocused = _rateFocusNode.hasFocus;
      _isTypeFocused = _typeFocusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100, left: 10.0, right: 10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Create a Post',
              style: CustomTextStyle.semiBoldText.copyWith(
                color: Colors.black,
                fontSize: responsiveSize(context, 0.07),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              decoration: customInputDecoration('Description'),
              maxLines: 20,
              minLines: 1,
              keyboardType: TextInputType.multiline,
            ),
            if (_isDescriptionFocused)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Provide a detailed description.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),
            TextField(
              controller: _typeController,
              focusNode: _typeFocusNode,
              decoration: customInputDecoration('Type of Job'),
              maxLines: 10,
              minLines: 1,
              keyboardType: TextInputType.multiline,
            ),
            if (_isTypeFocused)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Example: Construction, Paint Job, Sales lady/boy, Laundry, Cook',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            const SizedBox(height: 40),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _descriptionController.clear();
                    _typeController.clear();
                    // _rateController.clear();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const JobhunterNavigation()));
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => createPost(context),
                  child: const Text('Post'),
                ),
                const SizedBox(height: 50),
                TextButton(
                    child: const Text('Go to Job Posts History'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const JobPostsPage()),
                      );
                    }),
              ],
            )
          ],
        ),
      ),
    );
  }

  //posting
  void createPost(BuildContext context) async {
  if (_descriptionController.text.isNotEmpty &&
      _typeController.text.isNotEmpty) {
    String description = _descriptionController.text;
    String type = _typeController.text;
    var postDetails = Post(
      description: description,
      type: type,
    );

    try {
      await Provider.of<PostsProvider>(context, listen: false)
          .addPost(postDetails);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post added successfully!')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const JobhunterNavigation()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: $e')),
      );
    }
  }
}
}
