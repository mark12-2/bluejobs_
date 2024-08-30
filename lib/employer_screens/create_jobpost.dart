import 'package:bluejobs/employer_screens/job_posts_page.dart';
import 'package:bluejobs/model/posts_model.dart';
import 'package:bluejobs/navigation/employer_navigation.dart';
import 'package:bluejobs/provider/posts_provider.dart';
import 'package:bluejobs/styles/custom_theme.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class CreateJobPostPage extends StatefulWidget {
  const CreateJobPostPage({super.key});

  @override
  State<CreateJobPostPage> createState() => _CreateJobPostPageState();
}

class _CreateJobPostPageState extends State<CreateJobPostPage> {
  final PostsProvider jobpostdetails = PostsProvider();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _typeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _workingHoursController = TextEditingController();
  DateTime? _selectedDate;

  List<LatLng> routePoints = [];

  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _typeFocusNode = FocusNode();
  final _locationFocusNode = FocusNode();
  final _startDateFocusNode = FocusNode();
  final _workingHoursFocusNode = FocusNode();

  bool _isTitleFocused = false;
  bool _isDescriptionFocused = false;
  bool _isLocationFocused = false;
  bool _isTypeFocused = false;
  bool _isStartDateFormatFocused = false;
  bool _isWorkingHoursFocused = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _typeController.dispose();
    _startDateController.dispose();
    _workingHoursController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _typeFocusNode.dispose();
    _locationFocusNode.dispose();
    _startDateFocusNode.dispose();
    _workingHoursFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _titleFocusNode.addListener(_onFocusChange);
    _descriptionFocusNode.addListener(_onFocusChange);
    _typeFocusNode.addListener(_onFocusChange);
    _locationFocusNode.addListener(_onFocusChange);
    _startDateFocusNode.addListener(_onFocusChange);
    _workingHoursFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isTitleFocused = _titleFocusNode.hasFocus;
      _isDescriptionFocused = _descriptionFocusNode.hasFocus;
      _isLocationFocused = _locationFocusNode.hasFocus;
      _isTypeFocused = _typeFocusNode.hasFocus;
      _isStartDateFormatFocused = _startDateFocusNode.hasFocus;
      _isWorkingHoursFocused = _workingHoursFocusNode.hasFocus;
    });
  }

  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _startDateController.text = DateFormat('MM-dd-yyyy').format(picked);
      });
    }
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField(
                  decoration: customInputDecoration('Type of Job'),
                  focusNode: _typeFocusNode,
                  value: _typeController.text.isEmpty
                      ? null
                      : _typeController.text,
                  onChanged: (newValue) {
                    setState(() {
                      _typeController.text = newValue as String;
                    });
                  },
                  items: [
                    'Contractual Job',
                    'Stay In Job',
                    'Project Based',
                  ].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                ),
                if (_isTypeFocused)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Example: Contractual, Stay In Job, Project Based',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
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
                      'Enter address Ex. Illawod Poblacion, Legazpi City, Albay',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 7.0),
                    child: GestureDetector(
                      onTap: () => _selectStartDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _startDateController,
                          focusNode: _startDateFocusNode,
                          decoration: const InputDecoration(
                              labelText: 'Start Date',
                              labelStyle: CustomTextStyle.regularText,
                              suffixIcon: Icon(Icons.calendar_today),
                              hintText: 'Date when the job will start',
                              hintStyle: CustomTextStyle.regularText,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              )),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isStartDateFormatFocused)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Enter the start date of the job.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField(
                  decoration: customInputDecoration('Working Hours'),
                  focusNode: _workingHoursFocusNode,
                  value: _workingHoursController.text.isEmpty
                      ? null
                      : _workingHoursController.text, // initial value
                  onChanged: (newValue) {
                    setState(() {
                      _workingHoursController.text = newValue as String;
                    });
                  },
                  items: [
                    '8am - 5pm',
                    '9am - 6pm',
                    '10am - 7pm',
                    '7am - 3pm',
                    '6am - 2pm',
                    'Flexible',
                    'Rotating Shifts',
                    'Night Shift',
                    'Morning Shift',
                    'Afternoon Shift',
                  ].map((hours) {
                    return DropdownMenuItem(
                      value: hours,
                      child: Text(hours),
                    );
                  }).toList(),
                ),
                if (_isWorkingHoursFocused)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Enter the working hours of the job.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _titleController.clear();
                    _descriptionController.clear();
                    _locationController.clear();
                    _typeController.clear();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EmployerNavigation()));
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => addJobPost(context),
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

  void addJobPost(BuildContext context) async {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _typeController.text.isNotEmpty &&
        _locationController.text.isNotEmpty &&
        _startDateController.text.isNotEmpty &&
        _workingHoursController.text.isNotEmpty) {
      String title = _titleController.text;
      String description = _descriptionController.text;
      String type = _typeController.text;
      String location = _locationController.text;
      String startDate = _startDateController.text;
      String workingHours = _workingHoursController.text;

      var jobPostDetails = Post(
        title: title,
        description: description,
        type: type,
        location: location,
        startDate: startDate,
        workingHours: workingHours,
      );

      try {
        await Provider.of<PostsProvider>(context, listen: false)
            .addPost(jobPostDetails);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const EmployerNavigation()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: $e')),
        );
      }
    }
  }
}
