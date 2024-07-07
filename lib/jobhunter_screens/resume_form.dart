import 'package:bluejobs/provider/auth_provider.dart' as auth_provider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResumeForm extends StatefulWidget {
  final Map<String, dynamic>? resumeData;

  const ResumeForm({super.key, this.resumeData});

  @override
  State<ResumeForm> createState() => _ResumeFormState();
}

class _ResumeFormState extends State<ResumeForm> {
  final _formKey = GlobalKey<FormState>();
  final _skillsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _expectedSalaryController = TextEditingController();
  String? _userId;

  @override
  void initState() {
    super.initState();
    final authProvider =
        Provider.of<auth_provider.AuthProvider>(context, listen: false);
    _userId = authProvider.uid;

    if (widget.resumeData != null) {
      _skillsController.text = widget.resumeData!['skills'] ?? '';
      _experienceController.text = widget.resumeData!['experience'] ?? '';
      _expectedSalaryController.text =
          widget.resumeData!['expectedSalary'] ?? '';
    }
  }

  @override
  void dispose() {
    _skillsController.dispose();
    _experienceController.dispose();
    _expectedSalaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<auth_provider.AuthProvider>(context);

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
              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(
                  labelText: 'Experience',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your experience';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _expectedSalaryController,
                decoration: const InputDecoration(
                  labelText: 'Expected Salary',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final skills = _skillsController.text;
                    final experience = _experienceController.text;
                    final expectedSalary = _expectedSalaryController.text;

                    // Get the current user's ID from the AuthProvider
                    _userId = authProvider.uid;

                    if (_userId != null) {
                      // Create a new document in the "resume" collection
                      final resumeRef = FirebaseFirestore.instance
                          .collection("users")
                          .doc(_userId)
                          .collection("resume")
                          .doc(_userId);

                      // Add the skills, experience, and expected salary to the document
                      await resumeRef.set({
                        "skills": skills,
                        "experience": experience,
                        "expectedSalary": expectedSalary,
                      });

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
                },
                child: const Text('Save Resume'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
