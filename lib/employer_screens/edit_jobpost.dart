import 'package:bluejobs/model/posts_model.dart';
import 'package:bluejobs/navigation/employer_navigation.dart';
import 'package:bluejobs/provider/mapping/location_service.dart';
import 'package:bluejobs/provider/posts_provider.dart';
import 'package:bluejobs/styles/custom_theme.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:bluejobs/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class JobEditPost extends StatefulWidget {
  final String postId;

  const JobEditPost({super.key, required this.postId});

  @override
  State<JobEditPost> createState() => _JobEditPostState();
}

class _JobEditPostState extends State<JobEditPost> {
  late final PostsProvider _postsProvider;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _typeController = TextEditingController();
  final _rateController = TextEditingController();
  final _numberOfWorkersController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _workingHoursController = TextEditingController();

  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _typeFocusNode = FocusNode();
  final _locationFocusNode = FocusNode();
  final _rateFocusNode = FocusNode();
  final _numberOfWorkersFocusNode = FocusNode();
  final _startDateFocusNode = FocusNode();
  final _endDateFocusNode = FocusNode();
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

  bool _isLoading = true;
  Post? _post;

  final _formKey = GlobalKey<FormState>();

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
    _postsProvider = Provider.of<PostsProvider>(context, listen: false);
    _titleFocusNode.addListener(_onFocusChange);
    _descriptionFocusNode.addListener(_onFocusChange);
    _typeFocusNode.addListener(_onFocusChange);
    _locationFocusNode.addListener(_onFocusChange);
    _rateFocusNode.addListener(_onFocusChange);
    _numberOfWorkersFocusNode.addListener(_onFocusChange);
    _startDateFocusNode.addListener(_onFocusChange);
    _endDateFocusNode.addListener(_onFocusChange);
    _workingHoursFocusNode.addListener(_onFocusChange);

    fetchPostById(widget.postId);
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

  // fetch specific post
  Future<void> fetchPostById(String postId) async {
    try {
      final postRef =
          FirebaseFirestore.instance.collection('Posts').doc(postId);
      final docRef = await postRef.get();

      if (docRef.exists) {
        final post = Post.fromMap(docRef.data() ?? {});
        setState(() {
          _post = post;
          _titleController.text = post.title ?? '';
          _descriptionController.text = post.description ?? '';
          _typeController.text = post.type ?? '';
          _locationController.text = post.location ?? '';
          _rateController.text = post.rate ?? '';
          _numberOfWorkersController.text = post.numberOfWorkers ?? '';
          _startDateController.text = post.startDate ?? '';
          _endDateController.text = post.endDate ?? '';
          _workingHoursController.text = post.workingHours ?? '';
          _isLoading = false;
        });
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

  // toggle calendar for start and end dates
  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
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
    if (picked != null) {
      setState(() {
        _endDateController.text = DateFormat('MM-dd-yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Edit Job Post',
                        style: CustomTextStyle.semiBoldText.copyWith(
                          color: Colors.black,
                          fontSize: responsiveSize(context, 0.07),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        decoration: customInputDecoration('Title'),
                        maxLines: 10,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the title';
                          }
                          return null;
                        },
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
                      TextFormField(
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        decoration: customInputDecoration('Description'),
                        maxLines: 20,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the description';
                          }
                          return null;
                        },
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
                      TextFormField(
                        controller: _rateController,
                        focusNode: _rateFocusNode,
                        decoration: customInputDecoration('Rate'),
                        maxLines: 10,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the rate';
                          }
                          return null;
                        },
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
                      TextFormField(
                        controller: _typeController,
                        focusNode: _typeFocusNode,
                        decoration: customInputDecoration('Type'),
                        maxLines: 5,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the job type';
                          }
                          return null;
                        },
                      ),
                      if (_isTypeFocused)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Enter the type of job. Ex. Plumber, Electrician, etc.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _locationController,
                            focusNode: _locationFocusNode,
                            decoration: customInputDecoration('Location'),
                            maxLines: 5,
                            minLines: 1,
                            keyboardType: TextInputType.multiline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the location';
                              }
                              return null;
                            },
                          ),
                          if (_isLocationFocused)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Enter address Ex. Illawod Poblacion, Legazpi City, Albay',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ),
                          const SizedBox(height: 10),
                          Center(
                            child: ElevatedButton(
                              onPressed: () => showLocationPickerModal(
                                  context, _locationController),
                              child: const Text('Show Location',
                                  style: CustomTextStyle.regularText),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _numberOfWorkersController,
                        focusNode: _numberOfWorkersFocusNode,
                        decoration: customInputDecoration('Number of Workers'),
                        maxLines: 5,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the number of workers';
                          }
                          return null;
                        },
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
                                  child: TextFormField(
                                    controller: _startDateController,
                                    focusNode: _startDateFocusNode,
                                    decoration: const InputDecoration(
                                        labelText: 'Start Date',
                                        labelStyle: CustomTextStyle.regularText,
                                        suffixIcon: Icon(Icons.calendar_today),
                                        hintText:
                                            'Date when the job will start',
                                        hintStyle: CustomTextStyle.regularText,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        )),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter the start date';
                                      }
                                      return null;
                                    },
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
                                  child: TextFormField(
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter the end date';
                                      }
                                      return null;
                                    },
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
                      TextFormField(
                        controller: _workingHoursController,
                        focusNode: _workingHoursFocusNode,
                        decoration: customInputDecoration('Working Hours'),
                        maxLines: 10,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the working hours';
                          }
                          return null;
                        },
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
                            onPressed: _savePost,
                            child: const Text('Save'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              _titleController.clear();
                              _descriptionController.clear();
                              _locationController.clear();
                              _rateController.clear();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const EmployerNavigation()));
                            },
                            child: const Text('Cancel'),
                          )
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
      if (_locationController.text.isEmpty) {
        showSnackBar(context, "Job Post has no location / address....");
        return;
      }
      _formKey.currentState!.save();
      try {
        final post = Post(
          id: widget.postId,
          title: _titleController.text,
          description: _descriptionController.text,
          type: _typeController.text,
          location: _locationController.text,
          rate: _rateController.text,
          numberOfWorkers: _numberOfWorkersController.text,
          startDate: _startDateController.text,
          endDate: _endDateController.text,
          workingHours: _workingHoursController.text,
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
