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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Hunter Resume'),
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchResumeData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No resume data found.'));
                }

                String firstName = userData?['firstName'] ?? '';
                String middleName = userData?['middleName'] ?? '';
                String lastName = userData?['lastName'] ?? '';
                String suffix = userData?['suffix'] ?? '';

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: profileHeight / 2,
                            backgroundImage: userData?['profilePic'] != null
                                ? NetworkImage(userData!['profilePic'])
                                : null,
                            backgroundColor: Colors.white,
                            child: userData?['profilePic'] == null
                                ? Icon(Icons.person, size: profileHeight / 2)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text('Bio Data',
                          style: CustomTextStyle.typeRegularText.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: responsiveSize(context, 0.04))),
                      const SizedBox(height: 15),
                      buildResumeItem(
                          'Name', '$firstName $middleName $lastName $suffix'),
                      buildResumeItem('Sex', userData?['sex'] ?? ''),
                      buildResumeItem('Birthday', userData?['birthdate'] ?? ''),
                      buildResumeItem(
                          'Contacts', userData?['phoneNumber'] ?? ''),
                      buildResumeItem('Email', userData?['email'] ?? ''),
                      buildResumeItem('Address', userData?['address'] ?? ''),
                      const SizedBox(height: 10),
                      for (var resumeData in snapshot.data!) ...[
                        // Education Attainment
                        Text('Education Attainment',
                            style: CustomTextStyle.typeRegularText.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: responsiveSize(context, 0.04))),
                        const SizedBox(height: 10),
                        buildResumeItem('Education Level',
                            resumeData['educationLevel'] ?? ''),
                        buildResumeItem(
                            'School Attended', resumeData['schoolName'] ?? ''),
                        buildResumeItem('Year Completed',
                            resumeData['year Completed'] ?? ''),
                        const SizedBox(height: 20),
                        // Work Experience
                        Text('Work Experience',
                            style: CustomTextStyle.typeRegularText.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: responsiveSize(context, 0.04))),
                        const SizedBox(height: 10),
                        buildResumeItem(
                            'Company Name', resumeData['companyName'] ?? ''),
                        buildResumeItem('Position Title',
                            resumeData['positionTitle'] ?? ''),
                        buildResumeItem(
                            'Duration of Work', resumeData['duration'] ?? ''),
                        const SizedBox(height: 20),
                        // Seminar Attended
                        Text('Seminar Attended',
                            style: CustomTextStyle.typeRegularText.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: responsiveSize(context, 0.04))),
                        const SizedBox(height: 10),
                        buildResumeItem(
                            'Seminar', resumeData['seminarName'] ?? ''),
                        buildResumeItem(
                            'Year Attended', resumeData['yearAttended'] ?? ''),
                        const SizedBox(height: 20),
                        // Skill
                        Text('Skill and Skillset',
                            style: CustomTextStyle.typeRegularText.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: responsiveSize(context, 0.04))),
                        const SizedBox(height: 10),
                        buildResumeItem('Skill', resumeData['skills'] ?? ''),
                        buildResumeItem(
                            'Proficiency', resumeData['skillSet'] ?? ''),
                        const SizedBox(height: 20),
                        // References
                        Text('References',
                            style: CustomTextStyle.typeRegularText.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: responsiveSize(context, 0.04))),
                        const SizedBox(height: 10),
                        buildResumeItem(
                            'Name', resumeData['referenceName'] ?? ''),
                        buildResumeItem(
                            'Company', resumeData['referenceCompany'] ?? ''),
                        buildResumeItem('Relationship',
                            resumeData['referenceRelationship'] ?? ''),
                        buildResumeItem('Contact Number',
                            resumeData['referencePhoneNum'] ?? ''),
                        const SizedBox(height: 20),
                        // Certs and ids
                        Text('Certificates and Validity Check',
                            style: CustomTextStyle.typeRegularText.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: responsiveSize(context, 0.04))),
                        const SizedBox(height: 10),
                        buildImageButton('Valid ID', resumeData['validIdUrl']),
                        buildImageButton('Police Clearance',
                            resumeData['policeClearanceUrl']),
                        buildImageButton(
                            'Certificate', resumeData['certificateUrl']),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget buildResumeItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
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
                  text: content.isEmpty ? 'None' : content,
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

  Widget buildImageButton(String title, String? imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          SizedBox(width: 10),
          Text(
            '$title: ',
            style: CustomTextStyle.regularText.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: responsiveSize(context, 0.03),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              if (imageUrl != null && imageUrl.isNotEmpty) {
                _showFilePreviewModal(imageUrl, title);
              }
            },
            child: Text('View'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Color.fromARGB(255, 243, 107, 4),
              backgroundColor:
                  const Color.fromARGB(255, 7, 30, 47), // Text color
            ),
          ),
        ],
      ),
    );
  }

  void _showFilePreviewModal(String? url, String label) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 7, 30, 47),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label at the top
              Text(
                label,
                style: CustomTextStyle.semiBoldText.copyWith(
                  fontSize: responsiveSize(context, 0.04),
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              // Image preview section
              url != null
                  ? Expanded(
                      child: InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(20.0),
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Container(
                          height: 300,
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.network(
                            url,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        'No file uploaded',
                        style: CustomTextStyle.regularText.copyWith(
                          fontSize: responsiveSize(context, 0.04),
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
