import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bluejobs/styles/custom_button.dart';
import 'package:bluejobs/styles/custom_theme.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bluejobs/provider/auth_provider.dart' as auth_provider;

class ResumeForm extends StatefulWidget {
  final Map<String, dynamic>? resumeData;
  final bool isEditMode;

  const ResumeForm({super.key, this.resumeData, this.isEditMode = false});

  @override
  State<ResumeForm> createState() => _ResumeFormState();
}

class _ResumeFormState extends State<ResumeForm> {
  final _formKey = GlobalKey<FormState>();

// Form Variables
  String? _selectedEducationLevel;
  String? _selectedYearCompleted;
  final TextEditingController _schoolNameController = TextEditingController();
  DateTime? fromDate;
  DateTime? toDate;
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController positionTitleController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  String? _selectedYearAttended;
  String _seminarName = '';
  String _selectedSkillLevel = 'Beginner';
  String _skill = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();

  // Resume Model variables
  String? level;
  String? schoolName;
  String? yearCompleted;
  String? companyName;
  String? positionTitle;
  String? duration;
  String? seminarName;
  String? yearAttended;
  String? skills;
  String? skillset;
  String? referenceName;
  String? referenceCompany;
  String? referenceRelationship;
  String? referencePhoneNum;

  // File upload URLs
  String? _policeClearanceUrl;
  String? _certificateUrl;
  String? _validIdUrl;
  String? _userId;

  final List<String> _educationLevels = [
    'Elementary',
    'Junior High School',
    'Senior High School',
    'High School',
    'Alternative Learning System',
    'Undergraduate',
    '2-Year Courses',
    'TESDA',
  ];

// Generate a list of years from 1950 to the current year
  List<String> _generateYears() {
    int currentYear = DateTime.now().year;
    return List<String>.generate(
        currentYear - 1949, (index) => (1950 + index).toString());
  }

  final List<String> _skillLevels = [
    "Beginner",
    "Intermediate",
    "Advanced",
    "Expert"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider =
          Provider.of<auth_provider.AuthProvider>(context, listen: false);
      _userId = authProvider.uid;
    });

    if (widget.resumeData != null) {
      level = widget.resumeData!['educationLevel'];
      schoolName = widget.resumeData!['schoolName'];
      yearCompleted = widget.resumeData!['yearCompleted'];
      companyName = widget.resumeData!['companyName'];
      positionTitle = widget.resumeData!['positionTitle'];
      duration = widget.resumeData!['duration'];
      seminarName = widget.resumeData!['seminarName'];
      yearAttended = widget.resumeData!['yearAttended'];
      skills = widget.resumeData!['skills'];
      skillset = widget.resumeData!['skillset'];
      referenceName = widget.resumeData!['referenceName'];
      referenceCompany = widget.resumeData!['referenceCompany'];
      referenceRelationship = widget.resumeData!['referenceRelationship'];
      referencePhoneNum = widget.resumeData!['referencePhoneNum'];
      _policeClearanceUrl = widget.resumeData!['policeClearanceUrl'];
      _certificateUrl = widget.resumeData!['certificateUrl'];
      _validIdUrl = widget.resumeData!['validIdUrl'];

      // Set the controllers and dropdowns
      _schoolNameController.text = schoolName ?? '';
      _selectedEducationLevel = level;
      _selectedYearCompleted = yearCompleted;
      companyNameController.text = companyName ?? '';
      positionTitleController.text = positionTitle ?? '';
      durationController.text = duration ?? '';
      _seminarName = seminarName ?? '';
      _selectedYearAttended = yearAttended;
      _skill = skills ?? '';
      _selectedSkillLevel = skillset ?? 'Beginner';
      _nameController.text = referenceName ?? '';
      _companyController.text = referenceCompany ?? '';
      _relationshipController.text = referenceRelationship ?? '';
      _contactInfoController.text = referencePhoneNum ?? '';
    }
  }

  Future<void> _pickFile({required String type}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      await _uploadFile(file: file, type: type);
    }
  }

  Future<void> _uploadFile(
      {required PlatformFile file, required String type}) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('resumes/${_userId!}/${type}_${file.name}');
      final uploadTask = storageRef.putFile(File(file.path!));

      final snapshot = await uploadTask;
      final fileUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        if (type == 'police_clearance') {
          _policeClearanceUrl = fileUrl;
        } else if (type == 'certificate') {
          _certificateUrl = fileUrl;
        } else if (type == 'valid_id') {
          _validIdUrl = fileUrl;
        }
      });
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> _submitResume() async {
    if (_formKey.currentState!.validate()) {
      // Ensure that 'fromDate' and 'toDate' are not null
      if (fromDate != null && toDate != null) {
        duration = "${fromDateController.text} to ${toDateController.text}";
      } else {
        duration = null; // Clear duration if dates are invalid
      }

      // Update model variables with form values
      level = _selectedEducationLevel;
      schoolName = _schoolNameController.text;
      yearCompleted = _selectedYearCompleted;
      companyName = companyNameController.text;
      positionTitle = positionTitleController.text;
      seminarName = _seminarName; // From the seminar TextFormField
      yearAttended = _selectedYearAttended;
      skills = _skill; // From the skills TextFormField
      skillset = _selectedSkillLevel; // From the skill level dropdown
      referenceName = _nameController.text;
      referenceCompany = _companyController.text;
      referenceRelationship = _relationshipController.text;
      referencePhoneNum = _contactInfoController.text;

      if (_policeClearanceUrl == null && _validIdUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please upload either Police Clearance or a Valid ID.',
              style: CustomTextStyle.regularText
                  .copyWith(fontSize: responsiveSize(context, 0.04)),
            ),
          ),
        );
        return;
      }

      if (_userId != null) {
        final resumeRef = FirebaseFirestore.instance
            .collection("users")
            .doc(_userId)
            .collection("resume")
            .doc(_userId);

        final resumeData = {
          "educationLevel": level,
          "schoolName": schoolName,
          "yearCompleted": yearCompleted,
          "companyName": companyName,
          "positionTitle": positionTitle,
          "duration": duration,
          "seminarName": seminarName,
          "yearAttended": yearAttended,
          "skills": skills,
          "skillset": skillset,
          "referenceName": referenceName,
          "referenceCompany": referenceCompany,
          "referenceRelationship": referenceRelationship,
          "referencePhoneNum": referencePhoneNum,
          "policeClearanceUrl": _policeClearanceUrl,
          "certificateUrl": _certificateUrl,
          "validIdUrl": _validIdUrl,
        };

        if (widget.isEditMode) {
          await resumeRef.update(resumeData);
        } else {
          await resumeRef.set(resumeData);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resume updated successfully',
                style: CustomTextStyle.regularText
                    .copyWith(fontSize: responsiveSize(context, 0.04))),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User  ID is empty',
                style: CustomTextStyle.regularText
                    .copyWith(fontSize: responsiveSize(context, 0.04))),
          ),
        );
      }
    }
  }

  Widget _buildFilePreview(String? fileUrl, String type) {
    if (fileUrl == null) {
      return TextButton(
        onPressed: () => _pickFile(type: type),
        child: Text(
          'Upload ${type.replaceAll('_', ' ').toUpperCase()} (PDF, JPG, PNG)',
          style: CustomTextStyle.semiBoldText
              .copyWith(fontSize: responsiveSize(context, 0.04)),
        ),
      );
    }

    bool isImage = fileUrl.endsWith('.jpg') || fileUrl.endsWith('.png');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${type.replaceAll('_', ' ').toUpperCase()} Uploaded:',
          style: CustomTextStyle.regularText
              .copyWith(fontSize: responsiveSize(context, 0.04)),
        ),
        const SizedBox(height: 8),
        isImage
            ? Image.network(fileUrl, height: 100, width: 100, fit: BoxFit.cover)
            : const Icon(Icons.picture_as_pdf,
                size: 100, color: Color.fromARGB(255, 243, 107, 4)),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _pickFile(type: type),
          child: Text('Change File',
              style: CustomTextStyle.regularText
                  .copyWith(fontSize: responsiveSize(context, 0.04))),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text('Edit Resume Form',
            style: CustomTextStyle.semiBoldText
                .copyWith(fontSize: responsiveSize(context, 0.04))),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Education Form
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Education Attainment',
                      style: CustomTextStyle.typeRegularText.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: responsiveSize(context, 0.04),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildLabel('Select Education Level'),
                    DropdownButtonFormField<String>(
                      value: _selectedEducationLevel,
                      decoration: customInputDecoration(''),
                      items: _educationLevels.map((String level) {
                        return DropdownMenuItem<String>(
                          value: level,
                          child: Text(
                            level,
                            style: CustomTextStyle.regularText,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedEducationLevel = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an education level';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Enter School Name'),
                    TextFormField(
                      controller: _schoolNameController,
                      decoration: customInputDecoration(''),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the school name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Select Year Completed'),
                    DropdownButtonFormField<String>(
                      value: _selectedYearCompleted,
                      decoration: customInputDecoration(''),
                      items: _generateYears().map((String year) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Text(
                            year,
                            style: CustomTextStyle.regularText,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedYearCompleted = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a year';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),

                // Work Experience form
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'Working Experience',
                    style: CustomTextStyle.typeRegularText.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: responsiveSize(context, 0.04),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildLabel('Company Name'),
                  TextFormField(
                    controller: companyNameController,
                    decoration: customInputDecoration(''),
                  ),
                  const SizedBox(height: 10),
                  _buildLabel('Position Title'),
                  TextFormField(
                    controller: positionTitleController,
                    decoration: customInputDecoration(''),
                  ),
                  const SizedBox(height: 10),
                  _buildLabel('Duration'),
                  // Update the 'Duration' row in the build method

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: fromDateController,
                          decoration: customInputDecoration(
                            'From',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: fromDate ?? DateTime.now(),
                                  firstDate: DateTime(1950),
                                  lastDate: DateTime.now(),
                                );

                                if (pickedDate != null) {
                                  setState(() {
                                    fromDate = pickedDate;
                                    fromDateController.text =
                                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                  });
                                }
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a start date';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: toDateController,
                          decoration: customInputDecoration(
                            'To',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: toDate ?? DateTime.now(),
                                  firstDate: fromDate ?? DateTime(1950),
                                  lastDate: DateTime.now(),
                                );

                                if (pickedDate != null) {
                                  setState(() {
                                    toDate = pickedDate;
                                    toDateController.text =
                                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                  });
                                }
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an end date';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ]),
                // Seminars form
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'Seminar Attended',
                    style: CustomTextStyle.typeRegularText.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: responsiveSize(context, 0.04),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildLabel('Enter Seminar Attended'),
                  TextFormField(
                    decoration: customInputDecoration(''),
                    cursorColor: Color.fromARGB(255, 7, 30, 47),
                    onChanged: (value) {
                      _seminarName = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the seminar name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Year Attended'),
                  DropdownButtonFormField<String>(
                    value: _selectedYearAttended,
                    decoration: customInputDecoration(''),
                    items: _generateYears().map((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(
                          year,
                          style: CustomTextStyle
                              .regularText, // Apply custom text style
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedYearAttended = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a year';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                ]),

                // Skillset Form
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'Your Skillset',
                    style: CustomTextStyle.typeRegularText.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: responsiveSize(context, 0.04),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildLabel('Enter Skills'),
                  TextFormField(
                    decoration: customInputDecoration(''),
                    onChanged: (value) {
                      _skill = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a skill';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Select Skill Level'),
                  DropdownButtonFormField<String>(
                    value: _selectedSkillLevel,
                    decoration: customInputDecoration('Select Skill Level'),
                    items: _skillLevels.map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(
                          level,
                          style: CustomTextStyle.regularText,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSkillLevel = newValue!;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a skill level';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                ]),
                // References Form

                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'References',
                    style: CustomTextStyle.typeRegularText.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: responsiveSize(context, 0.04),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildLabel('Enter Name'),
                  TextFormField(
                    controller: _nameController,
                    decoration: customInputDecoration(''),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Enter Company'),
                  TextFormField(
                    controller: _companyController,
                    decoration: customInputDecoration(''),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a company';
                      }
                      return null;
                    },
                    cursorColor: Color.fromARGB(255, 7, 30, 47),
                    style: CustomTextStyle.regularText
                        .copyWith(fontSize: responsiveSize(context, 0.04)),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Enter Relationship'),
                  TextFormField(
                    controller: _relationshipController,
                    decoration: customInputDecoration(''),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a relationship';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Enter Contact Information'),
                  TextFormField(
                    controller: _contactInfoController,
                    decoration: customInputDecoration(''),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact information';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                ]),
                Text(
                  'Upload Files',
                  style: CustomTextStyle.typeRegularText.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: responsiveSize(context, 0.04),
                  ),
                ),
                Column(
                  children: [
                    _buildFilePreview(_policeClearanceUrl, 'police_clearance'),
                    const SizedBox(height: 16.0),
                    _buildFilePreview(_certificateUrl, 'certificate'),
                    const SizedBox(height: 16.0),
                    _buildFilePreview(_validIdUrl, 'valid_id'),
                    const SizedBox(height: 20.0),
                  ],
                ),
                CustomButton(
                  onPressed: _submitResume,
                  buttonText: 'Submit Resume',
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text(
        label,
        style: CustomTextStyle.semiBoldText.copyWith(
          fontSize: responsiveSize(context, 0.04),
        ),
      ),
    );
  }
}
