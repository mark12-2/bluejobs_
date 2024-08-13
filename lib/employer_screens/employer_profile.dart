import 'package:bluejobs/employer_screens/applicants.dart';
import 'package:bluejobs/employer_screens/edit_jobpost.dart';
import 'package:bluejobs/jobhunter_screens/edit_post.dart';
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

class EmployerProfilePage extends StatefulWidget {
  const EmployerProfilePage({super.key});

  @override
  State<EmployerProfilePage> createState() => _EmployerProfilePageState();
}

class _EmployerProfilePageState extends State<EmployerProfilePage> {
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
      length: 3,
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
              child: const Tab(text: 'Applicants'),
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
          buildApplicantsTab(),
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
                String title = post['title'] ?? ''; // for job post
                String description = post['description'];
                String type = post['type'];
                String location = post['location'] ?? ''; // for job post
                String rate = post['rate'] ?? ''; // for job post
                String numberOfWorkers = post['numberOfWorkers'] ?? '';
                String startDate = post['startDate'] ?? '';
                String endDate = post['endDate'] ?? '';
                String workingHours =
                    post['workingHours'] ?? ''; // for job post

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
                                  Text(
                                    "Rate: $rate",
                                    style: CustomTextStyle.regularText,
                                  ),
                                  Text(
                                    "Workers Needed: $numberOfWorkers",
                                    style: CustomTextStyle.regularText,
                                  ),
                                  Text(
                                    "Rate: $rate",
                                    style: CustomTextStyle.regularText,
                                  ),
                                  Text(
                                    "Working Hours: $workingHours",
                                    style: CustomTextStyle.regularText,
                                  ),
                                  Text(
                                    "Start Date: $startDate",
                                    style: CustomTextStyle.regularText,
                                  ),
                                  Text(
                                    "End Date: $endDate",
                                    style: CustomTextStyle.regularText,
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

  Widget buildAboutTab(BuildContext context) {
    final userLoggedIn =
        Provider.of<auth_provider.AuthProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          backgroundColor: Color.fromARGB(255, 196, 211, 224),
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

  Widget buildApplicantsTab() {
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
            child: Text("No job posts available"),
          );
        }

        final jobPosts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: jobPosts.length,
          itemBuilder: (context, index) {
            final jobPost = jobPosts[index];

            String title = jobPost['title'];
            String description = jobPost['description'];
            bool isApplicationFull = jobPost['isApplicationFull'];

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
                      Text(
                        title,
                        style: CustomTextStyle.semiBoldText,
                      ),
                      Text(
                        description,
                        style: CustomTextStyle.regularText,
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: isApplicationFull
                                ? () async {
                                    await Provider.of<PostsProvider>(context,
                                            listen: false)
                                        .setJobPostAsAvailable(jobPost.id);
                                    setState(() {
                                      isApplicationFull = false;
                                    });
                                  }
                                : () async {
                                    await Provider.of<PostsProvider>(context,
                                            listen: false)
                                        .setJobPostAsUnavailable(jobPost.id);
                                    setState(() {
                                      isApplicationFull = true;
                                    });
                                  },
                            child: Text(isApplicationFull
                                ? 'Make Available'
                                : 'Set as Unavailable'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ApplicantsPage(jobId: jobPost.id),
                                ),
                              );
                            },
                            child: Text('View Applicants'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
