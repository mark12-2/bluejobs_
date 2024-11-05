import 'package:bluejobs/employer_screens/edit_jobpost.dart';
import 'package:bluejobs/jobhunter_screens/edit_post.dart';

import 'package:bluejobs/jobhunter_screens/resume_form.dart';
import 'package:bluejobs/jobhunter_screens/saved_post.dart';
import 'package:bluejobs/provider/mapping/location_service.dart';
import 'package:bluejobs/provider/posts_provider.dart';
import 'package:bluejobs/screens_for_auth/edit_user_information.dart';
import 'package:bluejobs/screens_for_auth/signin.dart';
import 'package:bluejobs/styles/custom_button.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:bluejobs/provider/auth_provider.dart' as auth_provider;

class JobHunterProfilePage extends StatefulWidget {
  const JobHunterProfilePage({super.key});

  @override
  State<JobHunterProfilePage> createState() => _JobHunterProfilePageState();
}

class _JobHunterProfilePageState extends State<JobHunterProfilePage> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
  }

  final double coverHeight = 200;
  final double profileHeight = 100;

  @override
  Widget build(BuildContext context) {
    final userLoggedIn =
        Provider.of<auth_provider.AuthProvider>(context, listen: false);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
          backgroundColor: Color.fromARGB(255, 251, 251, 251),
        ),
        body: Container(
          color: Color.fromARGB(255, 255, 255, 255),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      buildProfilePicture(),
                      const SizedBox(height: 10),
                      buildProfile(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                buildTabBar(),
                SizedBox(
                  height: 500,
                  child: Container(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    child: buildTabBarView(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfilePicture() {
    final userLoggedIn =
        Provider.of<auth_provider.AuthProvider>(context, listen: false);
    return CircleAvatar(
      radius: profileHeight / 2,
      backgroundImage: userLoggedIn.userModel.profilePic != null
          ? NetworkImage(userLoggedIn.userModel.profilePic!)
          : null,
      backgroundColor: Colors.white,
      child: userLoggedIn.userModel.profilePic == null
          ? Icon(Icons.person, size: profileHeight / 2)
          : null,
    );
  }

  Widget buildProfile() {
    final userLoggedIn =
        Provider.of<auth_provider.AuthProvider>(context, listen: false);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "${userLoggedIn.userModel.firstName} ${userLoggedIn.userModel.middleName} ${userLoggedIn.userModel.lastName} ${userLoggedIn.userModel.suffix}",
            style: CustomTextStyle.semiBoldText.copyWith(
              fontSize: responsiveSize(context, 0.04),
            ),
          ),
          Text(
            userLoggedIn.userModel.role,
            style: CustomTextStyle.regularText.copyWith(
              color: Color.fromARGB(255, 243, 107, 4),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabBar() => Container(
        color: Color.fromARGB(255, 255, 255, 255),
        alignment: Alignment.center,
        child: TabBar(
          isScrollable: true,
          indicatorColor: const Color.fromARGB(
              255, 7, 30, 47), // Set the indicator color to white
          indicatorWeight: 2, // Set the indicator weight to 2
          tabs: [
            Container(
              width: MediaQuery.of(context).size.width / 3,
              child: DefaultTextStyle(
                style: CustomTextStyle.semiBoldText,
                child: Tab(
                  text: 'My Posts',
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 3,
              child: DefaultTextStyle(
                style: CustomTextStyle.semiBoldText,
                child: Tab(
                  text: 'My Resume',
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 3,
              child: DefaultTextStyle(
                style: CustomTextStyle.semiBoldText,
                child: Tab(
                  text: 'Applied Jobs',
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 3,
              child: DefaultTextStyle(
                style: CustomTextStyle.semiBoldText,
                child: Tab(
                  text: 'About ',
                ),
              ),
            ),
          ],
          labelColor: Colors.white, // Set the label color to white
          unselectedLabelColor: const Color.fromARGB(
              255, 124, 118, 118), // Set the unselected label color to gray
        ),
      );

  Widget buildTabBarView() => TabBarView(
        children: [
          buildMyPostsTab(),
          buildResumeTab(),
          buildApplicationsTab(),
          buildAboutTab(context),
        ],
      );

  Widget buildMyPostsTab() {
    final PostsProvider postsProvider = PostsProvider();
    return StreamBuilder<QuerySnapshot>(
        stream: _userId != null
            ? postsProvider.getSpecificPostsStream(_userId)
            : const Stream.empty(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No posts available",
                style: CustomTextStyle.regularText,
              ),
            );
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];

                String name = post['name'];
                String role = post['role'];
                String profilePic = post['profilePic'];
                String title = post['title'];
                String description = post['description'];
                String type = post['type'];
                String location = post['location'];

                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        color: Color.fromARGB(255, 230, 234, 236),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4.0,
                        margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(profilePic),
                                        radius: 35.0,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: CustomTextStyle.semiBoldText
                                                .copyWith(
                                              fontSize:
                                                  responsiveSize(context, 0.04),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 55.0),
                                            child: Text(
                                              role,
                                              style:
                                                  CustomTextStyle.regularText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  role == 'Employer'
                                      ? Text(
                                          title,
                                          style: CustomTextStyle.semiBoldText,
                                        )
                                      : Container(),
                                  const SizedBox(height: 15),
                                  Text(
                                    description,
                                    style: CustomTextStyle.regularText,
                                  ),
                                  const SizedBox(height: 20),
                                  role == 'Employer'
                                      ? Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                final locations =
                                                    await locationFromAddress(
                                                        location);
                                                final lat =
                                                    locations[0].latitude;
                                                final lon =
                                                    locations[0].longitude;
                                                showLocationPickerModal(
                                                    context,
                                                    TextEditingController(
                                                        text: '$lat, $lon'));
                                              },
                                              child: Text(location,
                                                  style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 243, 107, 4))),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  Text(
                                    "Type of Job: $type",
                                    style: CustomTextStyle.regularText,
                                  ),
                                  const SizedBox(height: 15),
                                  Row(children: [
                                    IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color:
                                              Color.fromARGB(255, 243, 107, 4),
                                        ),
                                        onPressed: () {
                                          if (role == 'Employer') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      JobEditPost(
                                                          postId: post.id)),
                                            );
                                          } else if (role == 'Job Hunter') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditPost(
                                                          postId: post.id)),
                                            );
                                          }
                                        }),
                                    IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color:
                                              Color.fromARGB(255, 243, 107, 4),
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 255, 255, 255),
                                                title: Text(
                                                  'Confirm Deletion',
                                                  style: CustomTextStyle
                                                      .semiBoldText
                                                      .copyWith(
                                                          fontSize:
                                                              responsiveSize(
                                                                  context,
                                                                  0.04)),
                                                ),
                                                content: Text(
                                                  'Are you sure you want to delete this post? This action cannot be undone.',
                                                  style: CustomTextStyle
                                                      .regularText
                                                      .copyWith(
                                                          fontSize:
                                                              responsiveSize(
                                                                  context,
                                                                  0.04)),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text(
                                                      'Cancel',
                                                      style: CustomTextStyle
                                                          .regularText
                                                          .copyWith(
                                                              fontSize:
                                                                  responsiveSize(
                                                                      context,
                                                                      0.04)),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text(
                                                      'Delete',
                                                      style: CustomTextStyle
                                                          .regularText
                                                          .copyWith(
                                                              color:
                                                                  Colors.orange,
                                                              fontSize:
                                                                  responsiveSize(
                                                                      context,
                                                                      0.04)),
                                                    ),
                                                    onPressed: () async {
                                                      final postsProvider =
                                                          Provider.of<
                                                                  PostsProvider>(
                                                              context,
                                                              listen: false);
                                                      await postsProvider
                                                          .deletePost(post.id);
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        })
                                  ])
                                ]))));
              });
        });
  }

  Widget buildResumeTab() {
    final userLoggedIn =
        Provider.of<auth_provider.AuthProvider>(context, listen: false);
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final String? uid = user?.uid;
    return FutureBuilder(
      future: fetchResumeData(userLoggedIn.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final resumeData = snapshot.data as Map<String, dynamic>;

          return Scaffold(
            backgroundColor: Color.fromARGB(
                255, 255, 255, 255), // Set background color for the entire page
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: CustomTextStyle.typeRegularText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: responsiveSize(context, 0.04),
                        ),
                      ),
                      const SizedBox(height: 15),
                      buildResumeItem(
                        'Name',
                        "${userLoggedIn.userModel.firstName} ${userLoggedIn.userModel.middleName} ${userLoggedIn.userModel.lastName} ${userLoggedIn.userModel.suffix}",
                      ),
                      buildResumeItem('Sex', userLoggedIn.userModel.sex),
                      buildResumeItem(
                          'Birthday', userLoggedIn.userModel.birthdate),
                      buildResumeItem(
                          'Contacts', userLoggedIn.userModel.phoneNumber),
                      buildResumeItem(
                          'Email', userLoggedIn.userModel.email ?? ''),
                      buildResumeItem(
                          'Address', userLoggedIn.userModel.address),
                      const SizedBox(height: 20),

                      // Resume details section

                      //educational background
                      Text(
                        'Educational Background',
                        style: CustomTextStyle.typeRegularText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: responsiveSize(context, 0.04),
                        ),
                      ),
                      Column(
                        children: [
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Level: ${snapshot.data?['educationLevel'] ?? ''}',
                                      style: CustomTextStyle.regularText),
                                  Text(
                                      'School: ${snapshot.data?['schoolName'] ?? ''}',
                                      style: CustomTextStyle.regularText),
                                  Text(
                                      'Year Completed: ${snapshot.data?['yearCompleted'] ?? ''}',
                                      style: CustomTextStyle.regularText),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      //trying the editing of ewan hahashaha

                      // work experience section
                      Text(
                        'Work Experience',
                        style: CustomTextStyle.typeRegularText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: responsiveSize(context, 0.04),
                        ),
                      ),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Company Name: ${snapshot.data?['companyName'] ?? ''}',
                                  style: CustomTextStyle.regularText),
                              Text(
                                  'Position Title: ${snapshot.data?['positionTitle'] ?? ''}',
                                  style: CustomTextStyle.regularText),
                              Text(
                                  'Duration: ${snapshot.data?['duration'] ?? ''}',
                                  style: CustomTextStyle.regularText),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

// For seminars attended
                      Text(
                        'Seminar Attended',
                        style: CustomTextStyle.typeRegularText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: responsiveSize(context, 0.04),
                        ),
                      ),

                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  'Seminar: ${snapshot.data?['seminarName'] ?? ''}',
                                  style: CustomTextStyle.regularText.copyWith(
                                    fontSize: responsiveSize(context, 0.04),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Year Attended: ${snapshot.data?['yearAttended'] ?? ''}',
                                  style: CustomTextStyle.regularText.copyWith(
                                    fontSize: responsiveSize(context, 0.04),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

//for skills

                      Text(
                        'Skill ',
                        style: CustomTextStyle.typeRegularText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: responsiveSize(context, 0.04),
                        ),
                      ),

                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  'Skill: ${snapshot.data?['skills'] ?? ''}',
                                  style: CustomTextStyle.regularText.copyWith(
                                    fontSize: responsiveSize(context, 0.04),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Proficiency: ${snapshot.data?['skillSet'] ?? ''}',
                                  style: CustomTextStyle.regularText.copyWith(
                                    fontSize: responsiveSize(context, 0.04),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

//for people references

                      Text(
                        ' References ',
                        style: CustomTextStyle.typeRegularText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: responsiveSize(context, 0.04),
                        ),
                      ),

                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  'Name: ${snapshot.data?['referenceName'] ?? ''}',
                                  style: CustomTextStyle.regularText.copyWith(
                                    fontSize: responsiveSize(context, 0.04),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Company: ${snapshot.data?['referenceCompany'] ?? ''}',
                                  style: CustomTextStyle.regularText.copyWith(
                                    fontSize: responsiveSize(context, 0.04),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  ' Relationship: ${snapshot.data?['referenceRelationship'] ?? ''}',
                                  style: CustomTextStyle.regularText.copyWith(
                                    fontSize: responsiveSize(context, 0.04),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  ' Contact Number: ${snapshot.data?['referencePhoneNum'] ?? ''}',
                                  style: CustomTextStyle.regularText.copyWith(
                                    fontSize: responsiveSize(context, 0.04),
                                  ),
                                ),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Uploaded files display
                      Text(
                        'Uploaded Files:',
                        style: CustomTextStyle.typeRegularText.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: responsiveSize(context, 0.04)),
                      ),
                      const SizedBox(height: 5),
                      Column(
                        children: [
                          _buildFilePreviewList(snapshot.data),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0, top: 5.0),
                        child: CustomButton(
                          onPressed: () async {
                            try {
                              Map<String, dynamic>? existingResumeData =
                                  await fetchResumeData(uid!);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResumeForm(
                                    resumeData: existingResumeData,
                                    isEditMode: existingResumeData != null,
                                  ),
                                ),
                              );
                            } catch (e) {
                              // handle error
                            }
                          },
                          buttonText: 'Add/Edit Resume Details',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<Map<String, dynamic>> fetchResumeData(String uid) async {
    final firestore = FirebaseFirestore.instance;
    final resumeRef =
        firestore.collection("users").doc(uid).collection("resume").doc(uid);

    final resumeSnap = await resumeRef.get();
    if (resumeSnap.exists) {
      return resumeSnap.data() as Map<String, dynamic>;
    } else {
      return {};
    }
  }

  Widget _buildFilePreviewList(Map<String, dynamic>? data) {
    if (data == null) {
      return Text('No files uploaded',
          style: CustomTextStyle.typeRegularText.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: responsiveSize(context, 0.04)));
    }

    return Column(
      children: [
        _buildFilePreview(data['policeClearanceUrl'], 'Police Clearance'),
        const SizedBox(height: 10),
        _buildFilePreview(data['certificateUrl'], 'Certificate'),
        const SizedBox(height: 10),
        _buildFilePreview(data['validIdUrl'], 'Valid ID'),
      ],
    );
  }

  Widget _buildFilePreview(String? url, String label) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.90,
      height: 50,
      child: CustomButton(
        onPressed: () {
          _showFilePreviewModal(url, label);
        },
        buttonText: label,
        buttonColor: const Color.fromARGB(255, 7, 30, 47),
        textColor: Color.fromARGB(255, 243, 107, 4),
        borderColor: Colors.white,
        borderWidth: 2,
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
                  color: Colors.white, // Adjust label color if necessary
                ),
              ),
              const SizedBox(height: 10),

              // Image or file preview section
              url != null
                  ? Expanded(
                      child: InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(20.0),
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Container(
                          height: 300, // Set a specific height
                          width: MediaQuery.of(context).size.width *
                              0.9, // 90% of screen width
                          decoration: BoxDecoration(
                            color: Colors
                                .black, // Background for the image container
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.network(
                            url,
                            fit: BoxFit
                                .contain, // Ensure the image is contained within the box
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        'No file uploaded',
                        style: CustomTextStyle.regularText
                            .copyWith(fontSize: responsiveSize(context, 0.04)),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget buildResumeItem(String title, String? content) {
    if (content == null) {
      return Container(); // or some other default value
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$title: ',
              style: CustomTextStyle.semiBoldText.copyWith(
                fontSize: responsiveSize(context, 0.04),
              ),
            ),
            TextSpan(
              text: content,
              style: CustomTextStyle.regularText.copyWith(
                fontSize: responsiveSize(context, 0.04),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAboutTab(BuildContext context) {
    final userLoggedIn =
        Provider.of<auth_provider.AuthProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: const Icon(Icons.bookmark_added_outlined,
                color: Color.fromARGB(255, 0, 0, 0)),
            title: Text(
              'Saved Posts',
              style: CustomTextStyle.regularText.copyWith(
                fontSize: responsiveSize(context, 0.04),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SavedPostsPage(userId: userLoggedIn.uid),
                ),
              );
            },
            contentPadding: const EdgeInsets.all(10),
          ),
          ListTile(
            leading:
                const Icon(Icons.settings, color: Color.fromARGB(255, 0, 0, 0)),
            title: Text(
              'Edit Profile',
              style: CustomTextStyle.regularText.copyWith(
                fontSize: responsiveSize(context, 0.04),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditUserInformation()),
              );
            },
            contentPadding: const EdgeInsets.all(10),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded,
                color: Color.fromARGB(255, 0, 0, 0)),
            title: Text(
              'Log Out',
              style: CustomTextStyle.regularText.copyWith(
                fontSize: responsiveSize(context, 0.04),
              ),
            ),
            onTap: () {
              _showLogoutConfirmationDialog(context);
            },
            contentPadding: const EdgeInsets.all(10),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    final userLoggedIn =
        Provider.of<auth_provider.AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          title: Text('Log out',
              style: CustomTextStyle.semiBoldText
                  .copyWith(fontSize: responsiveSize(context, 0.04))),
          content: Text('Are you sure you want to log out?',
              style: CustomTextStyle.semiBoldText
                  .copyWith(fontSize: responsiveSize(context, 0.04))),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Hmm, no',
                style: CustomTextStyle.semiBoldText,
              ),
            ),
            TextButton(
              onPressed: () {
                userLoggedIn.userSignOut().then(
                      (value) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInPage(),
                        ),
                      ),
                    );
              },
              child: Text(
                'Yes, Im sure! ',
                style:
                    CustomTextStyle.semiBoldText.copyWith(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildApplicationsTab() {
    final userLoggedIn =
        Provider.of<auth_provider.AuthProvider>(context, listen: false);
    final PostsProvider _postsProvider = PostsProvider();

    return StreamBuilder<QuerySnapshot>(
      stream: getApplicationsStream(userLoggedIn.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          default:
            if (snapshot.hasData) {
              final applicationsData = snapshot.data!.docs;

              if (applicationsData.isEmpty) {
                return Center(
                  child: Text(
                    'No applications found.',
                    style: CustomTextStyle.regularText
                        .copyWith(fontSize: responsiveSize(context, 0.04)),
                  ),
                );
              }
              return ListView.builder(
                  itemCount: applicationsData.length,
                  itemBuilder: (context, index) {
                    final applicationData =
                        applicationsData[index].data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        // color: Color.fromARGB(255, 7, 30, 47),
                        color: Color.fromARGB(255, 255, 255, 255),
                        child: ListTile(
                            title: Text(
                              applicationData['jobTitle'],
                              style: CustomTextStyle.semiBoldText.copyWith(
                                  fontSize: responsiveSize(context, 0.04)),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  applicationData['jobDescription'],
                                  style: CustomTextStyle.regularText.copyWith(
                                      fontSize: responsiveSize(context, 0.04)),
                                ),
                                Text(
                                    'Employer: ${applicationData['employerName']}',
                                    style: CustomTextStyle.typeRegularText),
                              ],
                            ),
                            trailing: AbsorbPointer(
                              child: GestureDetector(
                                onTap: () async {
                                  bool newIsHired = !applicationData['isHired'];
                                  await _postsProvider.updateApplicantStatus(
                                    applicationData['jobId'],
                                    applicationData['idOfApplicant'],
                                    newIsHired,
                                  );

                                  snapshot.data!.docs[index].reference
                                      .get()
                                      .then((value) {
                                    setState(() {
                                      applicationData['isHired'] = newIsHired;
                                      applicationData['status'] =
                                          newIsHired ? 'Hired' : 'Pending';
                                    });
                                  });
                                },
                                child: Text(
                                  applicationData['status'] == 'Hired'
                                      ? 'Hired'
                                      : 'Pending',
                                  style: CustomTextStyle.regularText.copyWith(
                                    color: applicationData['status'] == 'Hired'
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            )),
                      ),
                    );
                  });
            } else {
              return Center(
                child: Text(
                  'No data available.',
                  style: CustomTextStyle.regularText
                      .copyWith(fontSize: responsiveSize(context, 0.04)),
                ),
              );
            }
        }
      },
    );
  }

  Stream<QuerySnapshot> getApplicationsStream(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('applications')
        .snapshots();
  }
}
