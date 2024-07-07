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
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(userData?['name'] ?? 'Profile'),
        ),
        body: userData == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          buildProfilePicture(),
                          const SizedBox(width: 20),
                          buildProfile(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildTabBar(),
                    SizedBox(
                      height: 500,
                      child: buildTabBarView(),
                    ),
                  ],
                ),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            userData?['name'] ?? '',
            style: CustomTextStyle.semiBoldText,
          ),
          Text(
            userData?['role'] ?? '',
            style: CustomTextStyle.typeRegularText,
          ),
        ],
      ),
    );
  }

  Widget buildTabBar() => Container(
        alignment: Alignment.center,
        child: TabBar(
          isScrollable: true,
          tabs: [
            Container(
              width: MediaQuery.of(context).size.width / 3,
              child: const Tab(text: 'Resume'),
            ),
          ],
          labelColor: const Color.fromARGB(255, 0, 0, 0),
          unselectedLabelColor: const Color.fromARGB(255, 124, 118, 118),
          labelStyle: CustomTextStyle.regularText,
        ),
      );

  Widget buildTabBarView() => TabBarView(
        children: [
          buildResumeTab(),
        ],
      );

  Widget buildResumeTab() {
    return resumeData == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: MediaQuery.of(context).size.height - 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildResumeItem('Name', userData?['name'] ?? ''),
                  buildResumeItem('Sex', userData?['sex'] ?? ''),
                  buildResumeItem('Birthday', userData?['birthdate'] ?? ''),
                  buildResumeItem('Contacts', userData?['phoneNumber'] ?? ''),
                  buildResumeItem('Email', userData?['email'] ?? ''),
                  buildResumeItem('Address', userData?['address'] ?? ''),
                  buildResumeItem('Skills', resumeData?['skills'] ?? ''),
                  buildResumeItem(
                      'Experience', resumeData?['experience'] ?? ''),
                  buildResumeItem(
                      'Expected Salary', resumeData?['expectedSalary'] ?? ''),
                ],
              ),
            ),
          );
  }

  Widget buildResumeItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: RichText(
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
    );
  }
}
