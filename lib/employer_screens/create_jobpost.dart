import 'package:bluejobs/model/posts_model.dart';
import 'package:bluejobs/navigation/employer_navigation.dart';
import 'package:bluejobs/provider/mapping/location_service.dart';
import 'package:bluejobs/provider/posts_provider.dart';
import 'package:bluejobs/styles/custom_theme.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class CreateJobPostPage extends StatefulWidget {
  const CreateJobPostPage({super.key});

  @override
  State<CreateJobPostPage> createState() => _CreateJobPostPageState();
}

class _CreateJobPostPageState extends State<CreateJobPostPage> {
  // firestore storage access
  final PostsProvider jobpostdetails = PostsProvider();
  // text controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _typeController = TextEditingController();
  final _rateController = TextEditingController();

  List<LatLng> routePoints = [];

  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _typeFocusNode = FocusNode();
  final _locationFocusNode = FocusNode();
  final _rateFocusNode = FocusNode();

  bool _isTitleFocused = false;
  bool _isDescriptionFocused = false;
  bool _isLocationFocused = false;
  bool _isRateFocused = false;
  bool _isTypeFocused = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _rateController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _typeFocusNode.dispose();
    _locationFocusNode.dispose();
    _rateFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _titleFocusNode.addListener(_onFocusChange);
    _descriptionFocusNode.addListener(_onFocusChange);
    _typeFocusNode.addListener(_onFocusChange);
    _locationFocusNode.addListener(_onFocusChange);
    _rateFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isTitleFocused = _titleFocusNode.hasFocus;
      _isDescriptionFocused = _descriptionFocusNode.hasFocus;
      _isLocationFocused = _locationFocusNode.hasFocus;
      _isTypeFocused = _typeFocusNode.hasFocus;
      _isRateFocused = _rateFocusNode.hasFocus;
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
              'Create Job Post',
              style: CustomTextStyle.semiBoldText.copyWith(
                color: Colors.black,
                fontSize: responsiveSize(context, 0.07),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              decoration: customInputDecoration('Title'),
              maxLines: 10,
              minLines: 1,
              keyboardType: TextInputType.multiline,
            ),
            if (_isTitleFocused)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Enter the title of your post.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),
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
              controller: _rateController,
              focusNode: _rateFocusNode,
              decoration: customInputDecoration('Rate'),
              maxLines: 10,
              minLines: 1,
              keyboardType: TextInputType.multiline,
            ),
            if (_isRateFocused)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Enter the rate. Ex. 300 per hour/day',
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


            const SizedBox(height: 20),

            // add leaflet for job location (mapping feature)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _locationController,
                  focusNode: _locationFocusNode,
                  decoration: customInputDecoration('Location'),
                  maxLines: 5,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                ),
                if (_isLocationFocused)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Enter address Ex. Illawod Poblacion, Legazpi City',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ElevatedButton(
                  onPressed: () =>
                      showLocationPickerModal(context, _locationController),
                  child: const Text('Show Location'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                ElevatedButton(
                  onPressed: () => addJobPost(context),
                  child: const Text('Post'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _titleController.clear();
                    _descriptionController.clear();
                    _locationController.clear();
                    _rateController.clear();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EmployerNavigation()));
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

//post job post
  void addJobPost(BuildContext context) async {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _typeController.text.isNotEmpty &&
        _locationController.text.isNotEmpty &&
        _rateController.text.isNotEmpty) {
      String title = _titleController.text;
      String description = _descriptionController.text;
      String type = _typeController.text;
      String location = _locationController.text;
      String rate = _rateController.text;
      // add the details
      var jobPostDetails = Post(
        title: title,
        description: description,
        type: type,
        location: location,
        rate: rate,
      );

      try {
        await Provider.of<PostsProvider>(context, listen: false)
            .addPost(jobPostDetails);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const EmployerNavigation()),
        );
      } catch (e) {
        // Handle errors here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: $e')),
        );
      }
    }
  }
}
