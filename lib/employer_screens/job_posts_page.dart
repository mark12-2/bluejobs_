import 'package:bluejobs/employer_screens/edit_jobpost.dart';
import 'package:bluejobs/jobhunter_screens/edit_post.dart';
import 'package:bluejobs/provider/posts_provider.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JobPostsPage extends StatefulWidget {
  const JobPostsPage({super.key});

  @override
  State<JobPostsPage> createState() => _JobPostsPageState();
}

class _JobPostsPageState extends State<JobPostsPage> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
  }

  final PostsProvider postsProvider = PostsProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 27, 74, 109),
        ),
        body: StreamBuilder<QuerySnapshot>(
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
                    String title = post['title'] ?? '';
                    String description = post['description'];
                    String type = post['type'];
                    String location = post['location'] ?? '';

                    String startDate = post['startDate'] ?? '';

                    String workingHours = post['workingHours'] ?? '';

                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            elevation: 4.0,
                            margin:
                                const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                            child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                style: CustomTextStyle
                                                    .semiBoldText
                                                    .copyWith(
                                                  color: const Color.fromARGB(
                                                      255, 0, 0, 0),
                                                  fontSize: responsiveSize(
                                                      context, 0.05),
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
                                              style:
                                                  CustomTextStyle.semiBoldText,
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
                                                Text(location,
                                                    style: const TextStyle(
                                                        color: Colors.blue)),
                                              ],
                                            )
                                          : Container(),
                                      Text(
                                        "Type of Job: $type",
                                        style: CustomTextStyle.typeRegularText,
                                      ),
                                      Text(
                                        "Working Hours: $workingHours",
                                        style: CustomTextStyle.regularText,
                                      ),
                                      Text(
                                        "Start Date: $startDate",
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
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Confirm Deletion'),
                                                    content: const Text(
                                                        'Are you sure you want to delete this post? This action cannot be undone.'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text(
                                                            'Cancel'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: const Text(
                                                            'Delete'),
                                                        onPressed: () async {
                                                          final postsProvider =
                                                              Provider.of<
                                                                      PostsProvider>(
                                                                  context,
                                                                  listen:
                                                                      false);
                                                          await postsProvider
                                                              .deletePost(
                                                                  post.id);
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
            }));
  }
}
