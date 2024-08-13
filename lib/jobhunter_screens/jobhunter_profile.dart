import 'package:bluejobs/employer_screens/edit_jobpost.dart';
import 'package:bluejobs/jobhunter_screens/edit_post.dart';
import 'package:bluejobs/utils/resume_form.dart';
import 'package:bluejobs/jobhunter_screens/saved_post.dart';
import 'package:bluejobs/provider/mapping/location_service.dart';
import 'package:bluejobs/provider/posts_provider.dart';
import 'package:bluejobs/screens_for_auth/edit_user_information.dart';
import 'package:bluejobs/screens_for_auth/signin.dart';
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
            // actions: [
            //   PopupMenuButton(
            //     icon: const Padding(
            //       padding: EdgeInsets.all(10.0),
            //       child: Icon(
            //         Icons.more_vert,
            //         size: 35,
            //       ),
            //     ),
            //     itemBuilder: (context) => [
            //       const PopupMenuItem(
            //         value: 'editProfile',
            //         child: Text('Edit Profile'),
            //       ),
            //       const PopupMenuItem(
            //         value: 'signOut',
            //         child: Text('Sign Out'),
            //       ),
            //       const PopupMenuItem(
            //         value: 'savedPosts',
            //         child: Text('Saved Posts'),
            //       ),
            //     ],
            //     onSelected: (value) {
            //       if (value == 'editProfile') {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => const EditUserInformation(),
            //           ),
            //         );
            //       } else if (value == 'signOut') {
            //         userLoggedIn.userSignOut().then(
            //               (value) => Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (context) => const SignInPage(),
            //                 ),
            //               ),
            //             );
            //       }
            //       if (value == 'savedPosts') {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) =>
            //                 SavedPostsPage(userId: userLoggedIn.uid),
            //           ),
            //         );
            //       }
            //     },
            //   )
            // ],
            ),
        body: SingleChildScrollView(
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
                child: buildTabBarView(),
              ),
            ],
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
            style: CustomTextStyle.semiBoldText,
          ),
          Text(
            userLoggedIn.userModel.role,
            style: CustomTextStyle.roleRegularText,
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
              child: const Tab(text: 'My Posts'),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 3,
              child: const Tab(text: 'Resume'),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 3,
              child: const Tab(text: 'Applications'),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 3,
              child: const Tab(text: 'About'),
            ),
          ],
          labelColor: const Color.fromARGB(255, 0, 0, 0),
          unselectedLabelColor: const Color.fromARGB(255, 124, 118, 118),
          labelStyle: CustomTextStyle.regularText,
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
              child: Text("No posts available"),
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
                        color: const Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
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
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0),
                                              fontSize:
                                                  responsiveSize(context, 0.05),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 55.0),
                                            child: Text(
                                              role,
                                              style: CustomTextStyle
                                                  .roleRegularText,
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
                                                      color: Colors.blue)),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  Text(
                                    "Type of Job: $type",
                                    style: CustomTextStyle.typeRegularText,
                                  ),
                                  const SizedBox(height: 15),
                                  Row(children: [
                                    IconButton(
                                        icon: const Icon(Icons.edit),
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
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Confirm Deletion'),
                                                content: const Text(
                                                    'Are you sure you want to delete this post? This action cannot be undone.'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text('Delete'),
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

    return FutureBuilder(
      future: fetchResumeData(userLoggedIn.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> skills = snapshot.data ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bio Data',
                      style: CustomTextStyle.typeRegularText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: responsiveSize(context, 0.03))),
                  const SizedBox(height: 15),
                  buildResumeItem(
                    'Name',
                    "${userLoggedIn.userModel.firstName} ${userLoggedIn.userModel.middleName} ${userLoggedIn.userModel.lastName} ${userLoggedIn.userModel.suffix}",
                  ),
                  buildResumeItem('Sex', userLoggedIn.userModel.sex),
                  buildResumeItem('Birthday', userLoggedIn.userModel.birthdate),
                  buildResumeItem(
                      'Contacts', userLoggedIn.userModel.phoneNumber),
                  buildResumeItem('Email', userLoggedIn.userModel.email ?? ''),
                  buildResumeItem('Address', userLoggedIn.userModel.address),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, top: 5.0),
                    child: Text(
                      'I am mostly good at!',
                      style: CustomTextStyle.typeRegularText.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: responsiveSize(context, 0.03),
                      ),
                    ),
                  ),
                  buildSpecializationChips(skills),
                ],
              ),
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
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

  Future<List<String>> fetchResumeData(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();
      final skillsList = List<String>.from(userDoc.get('skills'));

      return skillsList ?? [];
    } catch (e) {
      print('Error fetching resume data: $e');
      return [];
    }
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
              style: CustomTextStyle.semiBoldText.copyWith(
                fontSize: responsiveSize(context, 0.03),
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
              'Settings',
              style: CustomTextStyle.semiBoldText.copyWith(
                fontSize: responsiveSize(context, 0.03),
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
              style: CustomTextStyle.semiBoldText.copyWith(
                fontSize: responsiveSize(context, 0.03),
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
          backgroundColor: Color.fromARGB(255, 217, 228, 237),
          title: Text('Log out',
              style: CustomTextStyle.semiBoldText
                  .copyWith(fontSize: responsiveSize(context, 0.03))),
          content: const Text(
            'Are you sure you want to log out?',
            style: CustomTextStyle.semiBoldText,
          ),
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
                  child: Text('No applications found.'),
                );
              }
              return ListView.builder(
                  itemCount: applicationsData.length,
                  itemBuilder: (context, index) {
                    final applicationData =
                        applicationsData[index].data() as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                          title: Text(applicationData['jobTitle']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(applicationData['jobDescription']),
                              Text(
                                  'Employer: ${applicationData['employerName']}',
                                  style: CustomTextStyle.roleRegularText),
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
                                applicationData['status'] ? 'Hired' : 'Pending',
                                style: TextStyle(
                                  color: applicationData['status']
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          )),
                    );
                  });
            } else {
              return const Center(
                child: Text('No data available.'),
              );
            }
        }
      },
    );
  }
}

Stream<QuerySnapshot> getApplicationsStream(String uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('applications')
      .snapshots();
}
