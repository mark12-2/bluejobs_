import 'package:bluejobs/employer_screens/edit_jobpost.dart';
import 'package:bluejobs/jobhunter_screens/edit_post.dart';
import 'package:bluejobs/provider/mapping/location_service.dart';
import 'package:bluejobs/provider/posts_provider.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

class Fetch extends StatefulWidget {
  const Fetch({super.key});

  @override
  State<Fetch> createState() => _FetchState();
}

class _FetchState extends State<Fetch> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    final PostsProvider postsProvider = PostsProvider();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fetching owners' posts"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
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

                return Expanded(
                  child: ListView.builder(
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
                      String rate = post['rate'];

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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(profilePic),
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
                                          "$name",
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
                                            "$role",
                                            style:
                                                CustomTextStyle.roleRegularText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  "$title",
                                  style: CustomTextStyle.semiBoldText,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  "$description",
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
                                              final lat = locations[0].latitude;
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
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.edit),
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
                                      icon: Icon(Icons.delete),
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
                                                    Navigator.of(context).pop();
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
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
        ],
      ),
    );
  }
}
