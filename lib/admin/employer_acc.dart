import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployerVerify extends StatefulWidget {
  final String userId;

  const EmployerVerify({super.key, required this.userId});

  @override
  State<EmployerVerify> createState() => _EmployerVerifyState();
}

class _EmployerVerifyState extends State<EmployerVerify> {
  final double coverHeight = 200;
  final double profileHeight = 100;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? verificationData;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await fetchUserData();
    await fetchVerificationData();
  }

  Future<void> fetchUserData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    if (userDoc.exists) {
      setState(() {
        userData = userDoc.data();
      });
    }
  }

  Future<void> fetchVerificationData() async {
    final storage = FirebaseStorage.instance;
    final filesRef = storage.ref("resumes/${widget.userId}");

    final ListResult filesList = await filesRef.list();

    final filesData = <String, dynamic>{};
    for (var file in filesList.items) {
      final fileUrl = await file.getDownloadURL();
      filesData[file.name] = fileUrl;
    }

    final verificationRef = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .collection("verification")
        .doc(widget.userId);

    final verificationSnap = await verificationRef.get();
    if (verificationSnap.exists) {
      setState(() {
        verificationData = {
          ...verificationSnap.data() as Map<String, dynamic>,
          "files": filesData,
        };
      });
    } else {
      setState(() {
        verificationData = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Hunter Details'),
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                      'Name: ${userData?['firstName']} ${userData?['lastName']}'),
                  Text('Email: ${userData?['email']}'),
                  Text('Phone Number: ${userData?['phoneNumber']}'),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 500,
                    child: buildVerifyFilesTab(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildVerifyFilesTab() {
    return userData == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: MediaQuery.of(context).size.height - 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text('Verification Files:',
                      style: CustomTextStyle.typeRegularText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: responsiveSize(context, 0.04))),
                  _buildFilePreviewList(verificationData),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(widget.userId)
                          .collection("verification")
                          .doc(widget.userId)
                          .update({"isVerified": true});
                      setState(() {
                        verificationData!["isVerified"] = true;
                      });
                    },
                    child: Text('Verify Account'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(widget.userId)
                          .collection("verification")
                          .doc(widget.userId)
                          .update({"isVerified": false});
                      setState(() {
                        verificationData!["isVerified"] = false;
                      });
                    },
                    child: Text('Unverify Account'),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildFilePreviewList(Map<String, dynamic>? data) {
    if (data == null) {
      return Text('No files uploaded');
    }

    return Column(
      children: [
        _buildFilePreview(data['policeClearanceUrl'], 'Police Clearance'),
        _buildFilePreview(data['businessPermitUrl'], 'Certificate'),
        _buildFilePreview(data['validIdUrl'], 'Valid ID'),
        _buildFilePreview(data['selfieUrl'], 'Selfie'),
      ],
    );
  }

  Widget _buildFilePreview(String? url, String label) {
    if (url == null) {
      return Text('$label: Not uploaded');
    }

    return Row(
      children: [
        Text(label),
        const SizedBox(width: 10),
        url != null
            ? Image.network(
                url,
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              )
            : Container(),
      ],
    );
  }
}
