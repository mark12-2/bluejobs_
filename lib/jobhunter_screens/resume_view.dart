import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JobHunterResumeView extends StatefulWidget {
  final String userId;

  const JobHunterResumeView({super.key, required this.userId});

  @override
  State<JobHunterResumeView> createState() => _JobHunterResumeViewState();
}

class _JobHunterResumeViewState extends State<JobHunterResumeView> {
  final double coverHeight = 200;
  final double profileHeight = 100;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? resumeData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchResumeData();
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

  Future<void> fetchResumeData() async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection("users").doc(widget.userId);
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        final resumeRef = userRef.collection("resume").limit(1);
        final resumeQuerySnapshot = await resumeRef.get();
        if (resumeQuerySnapshot.docs.isNotEmpty) {
          final resumeDoc = resumeQuerySnapshot.docs.first;
          setState(() {
            resumeData = resumeDoc.data();
          });
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume'),
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        buildProfilePicture(),
                        const SizedBox(height: 10),
                        buildProfile(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.black,
                  ),
                  SizedBox(
                    height: 500,
                    child: buildResumeTab(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildProfilePicture() {
    return CircleAvatar(
      radius: profileHeight / 2,
      backgroundImage: userData?['profilePic'] != null
          ? NetworkImage(userData!['profilePic'])
          : null,
      backgroundColor: Colors.white,
      child: userData?['profilePic'] == null
          ? Icon(Icons.person, size: profileHeight / 2)
          : null,
    );
  }

  Widget buildProfile() {
    String firstName = userData?['firstName'] ?? '';
    String middleName = userData?['middleName'] ?? '';
    String lastName = userData?['lastName'] ?? '';
    String suffix = userData?['suffix'] ?? '';

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          '$firstName $middleName $lastName $suffix',
          style: CustomTextStyle.semiBoldText,
        ),
        Text(
          userData?['role'] ?? '',
          style: CustomTextStyle.roleRegularText,
        ),
      ],
    );
  }

  Widget buildResumeTab() {
    String firstName = userData?['firstName'] ?? '';
    String middleName = userData?['middleName'] ?? '';
    String lastName = userData?['lastName'] ?? '';
    String suffix = userData?['suffix'] ?? '';

    return resumeData == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: MediaQuery.of(context).size.height - 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bio Data',
                      style: CustomTextStyle.typeRegularText
                          .copyWith(fontSize: responsiveSize(context, 0.03))),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      buildResumeItem(
                          'Name',
                          '$firstName $middleName $lastName $suffix',
                          Icons.person),
                    ],
                  ),
                  buildResumeItem('Sex', userData?['sex'] ?? '', Icons.male),
                  buildResumeItem(
                      'Birthday', userData?['birthdate'] ?? '', Icons.cake),
                  buildResumeItem(
                      'Contacts', userData?['phoneNumber'] ?? '', Icons.phone),
                  buildResumeItem(
                      'Email', userData?['email'] ?? '', Icons.email),
                  buildResumeItem(
                      'Address', userData?['address'] ?? '', Icons.location_on),
                  const SizedBox(height: 15),
                  Text('Backgound Details',
                      style: CustomTextStyle.typeRegularText
                          .copyWith(fontSize: responsiveSize(context, 0.03))),
                  const SizedBox(height: 15),
                  buildResumeItem(
                      'Skills', resumeData?['skills'] ?? '', Icons.work),
                  buildResumeItem('Experience', resumeData?['experience'] ?? '',
                      Icons.business),
                  buildResumeItem('Expected Salary',
                      resumeData?['expectedSalary'] ?? '', Icons.attach_money),
                ],
              ),
            ),
          );
  }

  Widget buildResumeItem(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(icon, size: responsiveSize(context, 0.03)),
          SizedBox(width: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$title: ',
                  style: CustomTextStyle.regularText.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: responsiveSize(context, 0.03),
                  ),
                ),
                TextSpan(
                  text: content,
                  style: CustomTextStyle.regularText.copyWith(
                    fontSize: responsiveSize(context, 0.03),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
