import 'dart:io';
import 'package:flutter/material.dart';
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
  final _experienceDescriptionController = TextEditingController();
  final _skillsController = TextEditingController();
  String? _educationAttainment;
  String? _skillLevel;
  String? _policeClearanceUrl;
  String? _certificateUrl;
  String? _validIdUrl;
  String? _userId;

  final List<String> educationLevels = [
    "Elementary",
    "High School",
    "College",
  ];

  final List<String> skillLevels = [
    "Beginner",
    "Intermediate",
    "Advanced",
    "Expert",
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
      _experienceDescriptionController.text =
          widget.resumeData!['experienceDescription'] ?? '';
      _skillsController.text = widget.resumeData!['skills'] ?? '';
      _educationAttainment = widget.resumeData!['educationAttainment'];
      _skillLevel = widget.resumeData!['skillLevel'];
      _policeClearanceUrl = widget.resumeData!['policeClearanceUrl'];
      _certificateUrl = widget.resumeData!['certificateUrl'];
      _validIdUrl = widget.resumeData!['validIdUrl'];
    }
  }

  @override
  void dispose() {
    _experienceDescriptionController.dispose();
    _skillsController.dispose();
    super.dispose();
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
      if (_policeClearanceUrl == null && _validIdUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please upload either Police Clearance or a Valid ID.'),
          ),
        );
        return;
      }

      final experienceDescription = _experienceDescriptionController.text;
      final skills = _skillsController.text;

      if (_userId != null) {
        final resumeRef = FirebaseFirestore.instance
            .collection("users")
            .doc(_userId)
            .collection("resume")
            .doc(_userId);

        if (widget.isEditMode) {
          // Update existing resume data
          await resumeRef.update({
            "experienceDescription": experienceDescription,
            "skills": skills,
            "educationAttainment": _educationAttainment,
            "skillLevel": _skillLevel,
            "policeClearanceUrl": _policeClearanceUrl,
            "certificateUrl": _certificateUrl,
            "validIdUrl": _validIdUrl,
          });
        } else {
          // Create new resume data
          await resumeRef.set({
            "experienceDescription": experienceDescription,
            "skills": skills,
            "educationAttainment": _educationAttainment,
            "skillLevel": _skillLevel,
            "policeClearanceUrl": _policeClearanceUrl,
            "certificateUrl": _certificateUrl,
            "validIdUrl": _validIdUrl,
          });
        }

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume updated successfully'),
          ),
        );

        // Navigate back to the previous screen with a callback to reload
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID is empty'),
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
            'Upload ${type.replaceAll('_', ' ').toUpperCase()} (PDF, JPG, PNG)'),
      );
    }

    bool isImage = fileUrl.endsWith('.jpg') || fileUrl.endsWith('.png');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${type.replaceAll('_', ' ').toUpperCase()} Uploaded:'),
        const SizedBox(height: 8),
        isImage
            ? Image.network(fileUrl, height: 100, width: 100, fit: BoxFit.cover)
            : const Icon(Icons.picture_as_pdf, size: 100, color: Colors.red),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _pickFile(type: type),
          child: const Text('Change File'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _experienceDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Experience Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your experience description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _educationAttainment,
                decoration: const InputDecoration(
                  labelText: 'Education Attainment',
                  border: OutlineInputBorder(),
                ),
                items: educationLevels
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _educationAttainment = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your education level';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'Skills',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your skills';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _skillLevel,
                decoration: const InputDecoration(
                  labelText: 'Skill Level',
                  border: OutlineInputBorder(),
                ),
                items: skillLevels
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _skillLevel = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your skill level';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _buildFilePreview(_policeClearanceUrl, 'police_clearance'),
              const SizedBox(height: 16.0),
              _buildFilePreview(_certificateUrl, 'certificate'),
              const SizedBox(height: 16.0),
              _buildFilePreview(_validIdUrl, 'valid_id'),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _submitResume,
                child: const Text('Save Resume'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
