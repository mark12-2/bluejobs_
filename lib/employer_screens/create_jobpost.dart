import 'package:bluejobs/model/posts_model.dart';
import 'package:bluejobs/navigation/employer_navigation.dart';
import 'package:bluejobs/provider/mapping/location_service.dart';
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
  // firestore storage access
  final PostsProvider jobpostdetails = PostsProvider();
  // text controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _typeController = TextEditingController();
  final _rateController = TextEditingController();
  final _numberOfWorkersController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _workingHoursController = TextEditingController();

  List<LatLng> routePoints = [];

  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _typeFocusNode = FocusNode();
  final _locationFocusNode = FocusNode();
  final _rateFocusNode = FocusNode();
  final _numberOfWorkersFocusNode = FocusNode();
  final _startDateFocusNode = FocusNode();
  final _endDateFocusNode = FocusNode();
  DateTime? _selectedDate;
  final _workingHoursFocusNode = FocusNode();

  bool _isTitleFocused = false;
  bool _isDescriptionFocused = false;
  bool _isLocationFocused = false;
  bool _isRateFocused = false;
  bool _isTypeFocused = false;
  bool _isNumberOfWorkersFocused = false;
  bool _isStartDateFormatFocused = false;
  bool _isEndDateFormatFocused = false;
  bool _isWorkingHoursFocused = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _rateController.dispose();
    _numberOfWorkersController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _workingHoursController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _typeFocusNode.dispose();
    _locationFocusNode.dispose();
    _rateFocusNode.dispose();
    _numberOfWorkersFocusNode.dispose();
    _startDateFocusNode.dispose();
    _endDateFocusNode.dispose();
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
    _rateFocusNode.addListener(_onFocusChange);
    _numberOfWorkersFocusNode.addListener(_onFocusChange);
    _startDateFocusNode.addListener(_onFocusChange);
    _endDateFocusNode.addListener(_onFocusChange);
    _workingHoursFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isTitleFocused = _titleFocusNode.hasFocus;
      _isDescriptionFocused = _descriptionFocusNode.hasFocus;
      _isLocationFocused = _locationFocusNode.hasFocus;
      _isRateFocused = _rateFocusNode.hasFocus;
      _isTypeFocused = _typeFocusNode.hasFocus;
      _isNumberOfWorkersFocused = _numberOfWorkersFocusNode.hasFocus;
      _isStartDateFormatFocused = _startDateFocusNode.hasFocus;
      _isEndDateFormatFocused = _endDateFocusNode.hasFocus;
      _isWorkingHoursFocused = _workingHoursFocusNode.hasFocus;
    });
  }

  // toggle calendar for start and end dates
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

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _endDateController.text = DateFormat('MM-dd-yyyy').format(picked);
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
                      'Enter address Ex. Illawod Poblacion, Legazpi City, Albay',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: () =>
                        showLocationPickerModal(context, _locationController),
                    child: const Text('Show Location',
                        style: CustomTextStyle.regularText),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _numberOfWorkersController,
              focusNode: _numberOfWorkersFocusNode,
              decoration: customInputDecoration('Number of Workers'),
              maxLines: 5,
              minLines: 1,
              keyboardType: TextInputType.multiline,
            ),
            if (_isNumberOfWorkersFocused)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Enter the number of workers required for the job.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
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
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 7.0),
                    child: GestureDetector(
                      onTap: () => _selectEndDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _endDateController,
                          focusNode: _endDateFocusNode,
                          decoration: const InputDecoration(
                              labelText: 'End Date',
                              labelStyle: CustomTextStyle.regularText,
                              suffixIcon: Icon(Icons.calendar_today),
                              hintText: 'Date when the job will end',
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
            if (_isStartDateFormatFocused || _isEndDateFormatFocused)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Enter the start and end dates of the job.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),

            const SizedBox(height: 20),

            TextField(
              controller: _workingHoursController,
              focusNode: _workingHoursFocusNode,
              decoration: customInputDecoration('Working Hours'),
              maxLines: 10,
              minLines: 1,
              keyboardType: TextInputType.multiline,
            ),
            if (_isWorkingHoursFocused)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Enter the working hours of the job. Example: 8am - 5pm',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),

            const SizedBox(height: 20),

            Row(
              children: [
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
        _rateController.text.isNotEmpty &&
        _numberOfWorkersController.text.isNotEmpty &&
        _startDateController.text.isNotEmpty &&
        _endDateController.text.isNotEmpty &&
        _workingHoursController.text.isNotEmpty) {
      String title = _titleController.text;
      String description = _descriptionController.text;
      String type = _typeController.text;
      String location = _locationController.text;
      String rate = _rateController.text;
      String numberOfWorkers = _numberOfWorkersController.text;
      String startDate = _startDateController.text;
      String endDate = _endDateController.text;
      String workingHours = _workingHoursController.text;

      // add the details
      var jobPostDetails = Post(
        title: title,
        description: description,
        type: type,
        location: location,
        rate: rate,
        numberOfWorkers: numberOfWorkers,
        startDate: startDate,
        endDate: endDate,
        workingHours: workingHours,
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
