import 'package:bluejobs/provider/mapping/employee_location.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

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

  @override
  void initState() {
    super.initState();
    fetchUserData();
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
                  // Padding(
                  //   padding: const EdgeInsets.all(20.0),
                  //   child: Column(
                  //     children: [
                  //       buildProfilePicture(),
                  //       const SizedBox(height: 10),
                  //       buildProfile(),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 40),
                  // Container(
                  //   height: 1,
                  //   width: double.infinity,
                  //   color: Colors.black,
                  // ),
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
    List<String> skills = List<String>.from(userData?['skills'] ?? []);

    return userData == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: MediaQuery.of(context).size.height - 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bio Data',
                      style: CustomTextStyle.typeRegularText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: responsiveSize(context, 0.04))),
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
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, top: 5.0),
                    child: Text(
                      'I am mostly good at!',
                      style: CustomTextStyle.typeRegularText.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: responsiveSize(context, 0.04),
                      ),
                    ),
                  ),
                  buildSpecializationChips(skills),
                ],
              ),
            ),
          );
  }

  Widget buildSpecializationChips(List<String> skills) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: skills.map((specialization) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Chip(
            backgroundColor: const Color.fromARGB(255, 243, 107, 4),
            label: Text(
              specialization,
              style: CustomTextStyle.regularText.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildResumeItem(
    String title,
    String content,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          if (title == 'Address')
            TextButton(
              onPressed: () async {
                final location = content;
                final locations = await locationFromAddress(location);
                final lat = locations[0].latitude;
                final lon = locations[0].longitude;
                showLocationPickerModal(
                  context,
                  TextEditingController(text: '$lat, $lon'),
                );
              },
              child: Text('View on Map'),
            ),
        ],
      ),
    );
  }
}
