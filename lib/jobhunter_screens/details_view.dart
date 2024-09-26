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
        title: const Text('Job Hunter Resume'),
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
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

    return userData == null
        ? const Center(child: CircularProgressIndicator())
        : FutureBuilder(
            future: fetchResumeData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
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
                        buildResumeItem(
                            'Sex', userData?['sex'] ?? '', Icons.male),
                        buildResumeItem('Birthday',
                            userData?['birthdate'] ?? '', Icons.cake),
                        buildResumeItem('Contacts',
                            userData?['phoneNumber'] ?? '', Icons.phone),
                        buildResumeItem(
                            'Email', userData?['email'] ?? '', Icons.email),
                        buildResumeItem('Address', userData?['address'] ?? '',
                            Icons.location_on),
                        const SizedBox(height: 10),
                        Text('Details',
                            style: CustomTextStyle.typeRegularText.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: responsiveSize(context, 0.04))),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> resumeData =
                                snapshot.data![index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildResumeItem(
                                    'Education Attainment',
                                    resumeData['educationAttainment'] ?? '',
                                    Icons.school),
                                buildResumeItem(
                                    'Experience Description',
                                    resumeData['experienceDescription'] ?? '',
                                    Icons.work),
                                buildResumeItem('Skill Level',
                                    resumeData['skillLevel'] ?? '', Icons.star),
                                buildResumeItem('Skills',
                                    resumeData['skills'] ?? '', Icons.work),
                                const SizedBox(height: 10),
                                Text('Certificates and Validity Check',
                                    style: CustomTextStyle.typeRegularText
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                responsiveSize(context, 0.04))),
                                const SizedBox(height: 10),
                                buildResumeItem(
                                    'Valid ID URL',
                                    resumeData['validIdUrl'] ?? '',
                                    Icons.file_copy),
                                buildResumeItem(
                                    'Police Clearance URL',
                                    resumeData['policeClearanceUrl'] ?? '',
                                    Icons.file_copy),
                                buildResumeItem(
                                    'Certificate URL',
                                    resumeData['certificateUrl'] ?? '',
                                    Icons.file_copy),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
  }

  Future<List<Map<String, dynamic>>> fetchResumeData() async {
    final resumeCollection = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('resume')
        .get();
    List<Map<String, dynamic>> resumeData = [];
    for (var resume in resumeCollection.docs) {
      resumeData.add(resume.data());
    }
    return resumeData;
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
                    if (title == 'Certificate URL' ||
                        title == 'Police Clearance URL' ||
                        title == 'Valid ID URL')
                      TextSpan(
                        text: content.isEmpty ? 'None' : '',
                        style: CustomTextStyle.regularText.copyWith(
                          fontSize: responsiveSize(context, 0.03),
                        ),
                        children: content.isEmpty
                            ? []
                            : [
                                WidgetSpan(
                                  child: Image.network(
                                    content,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                      )
                    else
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
        ],
      ),
    );
  }
}
