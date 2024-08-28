import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bluejobs/provider/auth_provider.dart' as auth_provider;

class VerificationForm extends StatefulWidget {
  final Map<String, dynamic>? credentials;
  final bool isEditMode;

  const VerificationForm(
      {super.key, this.credentials, this.isEditMode = false});

  @override
  State<VerificationForm> createState() => _VerificationFormState();
}

enum SelfieSourceType { camera, gallery }

class _VerificationFormState extends State<VerificationForm> {
  final _formKey = GlobalKey<FormState>();
  String? _policeClearanceUrl;
  String? _businessPermitUrl;
  String? _validIdUrl;
  String? _selfieUrl;
  String? _userId;
  File? _selfieImage;
  SelfieSourceType _selfieSourceType = SelfieSourceType.gallery;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider =
          Provider.of<auth_provider.AuthProvider>(context, listen: false);
      _userId = authProvider.uid;
    });

    if (widget.credentials != null) {
      _policeClearanceUrl = widget.credentials!['policeClearanceUrl'];
      _businessPermitUrl = widget.credentials!['businessPermitUrl'];
      _validIdUrl = widget.credentials!['validIdUrl'];
      _selfieUrl = widget.credentials!['selfieUrl'];
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickFile({required String type}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      await _uploadFile(file: file, type: type);
    }
  }

  Future<void> _takeSelfie() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image;

    if (_selfieSourceType == SelfieSourceType.camera) {
      image = await _picker.pickImage(source: ImageSource.camera);
    } else {
      image = await _picker.pickImage(source: ImageSource.gallery);
    }

    if (image != null) {
      setState(() {
        _selfieImage = File(image!.path);
      });
      await _uploadFile(file: _selfieImage!, type: 'selfie');
    }
  }

  Future<void> _uploadFile({required File file, required String type}) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('resumes/${_userId!}/${type}_${file.path}');
      final uploadTask = storageRef.putFile(file);

      final snapshot = await uploadTask;
      final fileUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        if (type == 'police_clearance') {
          _policeClearanceUrl = fileUrl;
        } else if (type == 'businessPermit') {
          _businessPermitUrl = fileUrl;
        } else if (type == 'valid_id') {
          _validIdUrl = fileUrl;
        } else if (type == 'selfie') {
          _selfieUrl = fileUrl;
        }
      });
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> _submitCredentials() async {
    if (_formKey.currentState!.validate()) {
      if (_selfieImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please take a selfie.'),
          ),
        );
        return;
      }

      if (!(_policeClearanceUrl != null ||
          _validIdUrl != null ||
          _businessPermitUrl != null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Please upload at least one of Police Clearance, Valid ID, or Business Permit.'),
          ),
        );
        return;
      }

      if (_userId != null) {
        final credentialsRef = FirebaseFirestore.instance
            .collection("users")
            .doc(_userId)
            .collection("verification")
            .doc(_userId);

        if (widget.isEditMode) {
          await credentialsRef.update({
            "policeClearanceUrl": _policeClearanceUrl,
            "businessPermitUrl": _businessPermitUrl,
            "validIdUrl": _validIdUrl,
            "selfieUrl": _selfieUrl,
            "isVerified": false,
          });
        } else {
          await credentialsRef.set({
            "policeClearanceUrl": _policeClearanceUrl,
            "businessPermitUrl": _businessPermitUrl,
            "validIdUrl": _validIdUrl,
            "selfieUrl": _selfieUrl,
            "isVerified": false,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Updated successfully'),
          ),
        );
        Navigator.of(context).pop(true);
      }
    }
  }

  Widget _buildFilePreview(String? fileUrl, String type) {
    if (fileUrl == null) {
      return TextButton(
        onPressed: () {
          if (type == 'selfie') {
            _takeSelfie();
          } else {
            _pickFile(type: type);
          }
        },
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
          onPressed: () {
            if (type == 'selfie') {
              _takeSelfie();
            } else {
              _pickFile(type: type);
            }
          },
          child: const Text('Change File'),
        ),
      ],
    );
  }

  Widget _buildSelfiePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selfie:'),
        const SizedBox(height: 8),
        _selfieImage != null
            ? Image.file(_selfieImage!,
                height: 100, width: 100, fit: BoxFit.cover)
            : const Icon(Icons.person, size: 100, color: Colors.grey),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: () async {
                final pickedFile = await ImagePicker().getImage(
                  source: ImageSource.camera,
                );
                setState(() {
                  if (pickedFile != null) {
                    _selfieImage = File(pickedFile.path);
                  } else {
                    _selfieImage = null;
                  }
                });
              },
              child: const Text('Take Selfie'),
            ),
            TextButton(
              onPressed: () async {
                final pickedFile = await ImagePicker().getImage(
                  source: ImageSource.gallery,
                );
                setState(() {
                  if (pickedFile != null) {
                    _selfieImage = File(pickedFile.path);
                  } else {
                    _selfieImage = null;
                  }
                });
              },
              child: const Text('Upload from Gallery'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              _buildFilePreview(_policeClearanceUrl, 'police_clearance'),
              const SizedBox(height: 16.0),
              _buildFilePreview(_businessPermitUrl, 'businessPermit'),
              const SizedBox(height: 16.0),
              _buildFilePreview(_validIdUrl, 'valid_id'),
              const SizedBox(height: 16.0),
              _buildSelfiePreview(),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _submitCredentials,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
