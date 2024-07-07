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
  // final _rateController = TextEditingController();

  final _descriptionFocusNode = FocusNode();
  final _typeFocusNode = FocusNode();
  // final _rateFocusNode = FocusNode();

  bool _isDescriptionFocused = false;
  // bool _isRateFocused = false;
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

            // TextField(
            //   controller: _rateController,
            //   focusNode: _rateFocusNode,
            //   decoration: customInputDecoration('Rate'),
            //   maxLines: 20,
            //   minLines: 1,
            //   keyboardType: TextInputType.multiline,
            // ),
            // if (_isRateFocused)
            //   const Padding(
            //     padding: EdgeInsets.only(top: 8.0),
            //     child: Text(
            //       'Enter the rate. Ex. 300 per hour/day',
            //       style: TextStyle(color: Colors.grey, fontSize: 12),
            //     ),
            //   ),

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
                  onPressed: () => createPost(context),
                  child: const Text('Post'),
                ),
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
                  child: const Text('Cancel'),
                )
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
      // String rate = _rateController.text;
      var postDetails = Post(
        description: description,
        type: type,
        // rate: rate,
      );

      try {
        await Provider.of<PostsProvider>(context, listen: false)
            .addPost(postDetails);
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
