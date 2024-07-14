import 'package:bluejobs/chats/messaging_roompage.dart';
import 'package:bluejobs/default_screens/comment.dart';
import 'package:bluejobs/default_screens/view_profile.dart';
import 'package:bluejobs/provider/mapping/location_service.dart';
import 'package:bluejobs/provider/notifications/notifications_provider.dart';
import 'package:bluejobs/provider/posts_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bluejobs/default_screens/notification.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();
  final _commentTextController = TextEditingController();
  bool _isApplied = false;
  bool _isSaved = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void showCommentDialog(String postId, BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => CommentScreen(postId: postId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PostsProvider postDetails = Provider.of<PostsProvider>(context);
    final FirebaseAuth auth = FirebaseAuth.instance;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 27, 74, 109),
        leading: GestureDetector(
          onTap: () {
            _scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          },
          child: Image.asset('assets/images/bluejobs.png'),
        ),
        actions: <Widget>[
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return Stack(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      await notificationProvider.markAsRead();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      );
                    },
                  ),
                  if (notificationProvider.unreadNotifications > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: postDetails.getPostsStream(),
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

                      String userId = post['ownerId'];
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

                      return userId != auth.currentUser!.uid
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                elevation: 4.0,
                                margin: const EdgeInsets.fromLTRB(
                                    0.0, 10.0, 0.0, 10.0),
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
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfilePage(
                                                              userId: userId),
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "$name",
                                                      style: CustomTextStyle
                                                          .semiBoldText
                                                          .copyWith(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 0, 0, 0),
                                                        fontSize:
                                                            responsiveSize(
                                                                context, 0.05),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    auth.currentUser?.uid !=
                                                            userId
                                                        ? IconButton(
                                                            icon: const Icon(
                                                                Icons.message),
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          MessagingBubblePage(
                                                                    receiverName:
                                                                        name,
                                                                    receiverId:
                                                                        userId,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                "$role",
                                                style: CustomTextStyle
                                                    .roleRegularText,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      // post description
                                      role == 'Employer'
                                          ? Text(
                                              "$title",
                                              style:
                                                  CustomTextStyle.semiBoldText,
                                            )
                                          : Container(), // return empty 'title belongs to employer'
                                      const SizedBox(height: 5),
                                      Text(
                                        "$description",
                                        style: CustomTextStyle.regularText,
                                      ),
                                      const SizedBox(height: 15),
                                      role == 'Employer'
                                          ? Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_pin,
                                                  color: Colors.blue,
                                                ),
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
                                                            text:
                                                                '$lat, $lon'));
                                                  },
                                                  child: Text(
                                                      "$location (tap to view location)",
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
                                      role == 'Employer'
                                          ? Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Workers Needed: $numberOfWorkers",
                                                      style: CustomTextStyle
                                                          .regularText,
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Rate: $rate",
                                                      style: CustomTextStyle
                                                          .regularText,
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Working Hours: $workingHours",
                                                      style: CustomTextStyle
                                                          .regularText,
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Start Date: $startDate",
                                                      style: CustomTextStyle
                                                          .regularText,
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "End Date: $endDate",
                                                      style: CustomTextStyle
                                                          .regularText,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : Container(),
                                      const SizedBox(height: 20),
                                      // comment section and like
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            role == 'Job Hunter'
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      InkWell(
                                                        onTap: () async {
                                                          final postId =
                                                              post.id;
                                                          final userId = auth
                                                              .currentUser!.uid;

                                                          final postDoc =
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Posts')
                                                                  .doc(postId)
                                                                  .get();

                                                          if (postDoc.exists) {
                                                            final data = postDoc
                                                                    .data()
                                                                as Map<String,
                                                                    dynamic>;

                                                            if (data
                                                                .containsKey(
                                                                    'likes')) {
                                                              final likes = (data[
                                                                          'likes']
                                                                      as List<
                                                                          dynamic>)
                                                                  .map((e) => e
                                                                      as String)
                                                                  .toList();

                                                              if (likes
                                                                  .contains(
                                                                      userId)) {
                                                                likes.remove(
                                                                    userId);
                                                              } else {
                                                                likes.add(
                                                                    userId);
                                                              }

                                                              await postDoc
                                                                  .reference
                                                                  .update({
                                                                'likes': likes
                                                              });
                                                            } else {
                                                              await postDoc
                                                                  .reference
                                                                  .update({
                                                                'likes': [
                                                                  userId
                                                                ]
                                                              });
                                                            }
                                                          }
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .thumb_up_alt_rounded,
                                                              color: post.data() !=
                                                                          null &&
                                                                      (post.data() as Map<
                                                                              String,
                                                                              dynamic>)
                                                                          .containsKey(
                                                                              'likes') &&
                                                                      ((post.data() as Map<String, dynamic>)['likes'] as List<
                                                                              dynamic>)
                                                                          .contains(auth
                                                                              .currentUser!
                                                                              .uid)
                                                                  ? Colors.blue
                                                                  : Colors.grey,
                                                            ),
                                                            const SizedBox(
                                                                width: 5),
                                                            Text(
                                                              'React (${(post.data() as Map<String, dynamic>)['likes']?.length ?? 0})',
                                                              style: CustomTextStyle
                                                                  .regularText,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 25),
                                                      InkWell(
                                                        onTap: () {
                                                          showCommentDialog(
                                                              post.id, context);
                                                        },
                                                        child: const Row(
                                                          children: [
                                                            Icon(Icons.comment),
                                                            SizedBox(width: 5),
                                                            Text(
                                                              'Comments',
                                                              style: CustomTextStyle
                                                                  .regularText,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 50,
                                                      )
                                                    ],
                                                  )
                                                : Container(),
                                            const SizedBox(width: 5),
                                            userId == auth.currentUser!.uid
                                                ? Container()
                                                : role == 'Employer'
                                                    ? FutureBuilder<bool>(
                                                        future:
                                                            _checkApplicationStatus(
                                                                post.id,
                                                                auth.currentUser!
                                                                    .uid),
                                                        builder: (context,
                                                            snapshot) {
                                                          bool isApplied =
                                                              snapshot.data ??
                                                                  false;
                                                          return GestureDetector(
                                                            onTap: isApplied ||
                                                                    _isApplied
                                                                ? null
                                                                : () async {
                                                                    final notificationProvider = Provider.of<
                                                                            NotificationProvider>(
                                                                        context,
                                                                        listen:
                                                                            false);
                                                                    String
                                                                        receiverId =
                                                                        userId;
                                                                    String applicantName = auth
                                                                            .currentUser!
                                                                            .displayName ??
                                                                        'Unknown';
                                                                    String
                                                                        applicantId =
                                                                        auth.currentUser!
                                                                            .uid;

                                                                    await notificationProvider
                                                                        .someNotification(
                                                                      receiverId:
                                                                          receiverId,
                                                                      senderId: auth
                                                                          .currentUser!
                                                                          .uid,
                                                                      senderName:
                                                                          applicantName,
                                                                      title:
                                                                          'New Application',
                                                                      notif:
                                                                          ', applied to your job entitled "$title"',
                                                                    );
                                                                    await Provider.of<PostsProvider>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .applyJob(
                                                                      post.id,
                                                                      title,
                                                                      description,
                                                                      userId,
                                                                      name,
                                                                    );

                                                                    // Save the applicant's information to the job post
                                                                    await Provider.of<PostsProvider>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .addApplicant(
                                                                            post.id,
                                                                            applicantId,
                                                                            applicantName);

                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      const SnackBar(
                                                                          content:
                                                                              Text('Successfully applied')),
                                                                    );

                                                                    setState(
                                                                        () {
                                                                      _isApplied =
                                                                          true;
                                                                    });
                                                                  },
                                                            child: Container(
                                                              height: 53,
                                                              width: 165,
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: isApplied
                                                                      ? Colors
                                                                          .grey
                                                                      : const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          7,
                                                                          30,
                                                                          47),
                                                                  width: 2,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  postDetails
                                                                          .isJobPostAvailable
                                                                      ? (isApplied
                                                                          ? 'Applied'
                                                                          : 'Apply Job')
                                                                      : 'Unavailable',
                                                                  style: CustomTextStyle
                                                                      .regularText
                                                                      .copyWith(
                                                                    color: isApplied
                                                                        ? Colors
                                                                            .grey
                                                                        : const Color
                                                                            .fromARGB(
                                                                            255,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    fontSize: responsiveSize(
                                                                        context,
                                                                        0.03),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : Container(), // return empty container if role is not 'Employer'
                                            const SizedBox(width: 10),
                                            FutureBuilder(
                                              future: postDetails.savePost(
                                                  post.id,
                                                  auth.currentUser!.uid),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.done) {
                                                  _isSaved = true;
                                                }
                                                return InkWell(
                                                  onTap: _isSaved
                                                      ? null
                                                      : () async {
                                                          await postDetails
                                                              .savePost(
                                                                  post.id,
                                                                  auth.currentUser!
                                                                      .uid);
                                                        },
                                                  child: Container(
                                                    height: 53,
                                                    width: 165,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: _isSaved
                                                            ? Colors.grey
                                                            : Colors.orange,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.white,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        _isSaved
                                                            ? 'Saved'
                                                            : 'Save for Later',
                                                        style: CustomTextStyle
                                                            .regularText
                                                            .copyWith(
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 0, 0, 0),
                                                          fontSize:
                                                              responsiveSize(
                                                                  context,
                                                                  0.03),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _checkApplicationStatus(String postId, String userId) async {
    final postRef = FirebaseFirestore.instance.collection('Posts').doc(postId);
    final postDoc = await postRef.get();
    final applicants = postDoc.get('applicants') as List<dynamic>?;
    return applicants != null && applicants.contains(userId);
  }

  // adding a comment
  void addComment(BuildContext context, String postId) async {
    if (_commentTextController.text.isNotEmpty) {
      String comment = _commentTextController.text;

      try {
        await Provider.of<PostsProvider>(context, listen: false)
            .addComment(comment, postId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $e')),
        );
      }
    }
  }

  Future<void> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    _refreshIndicatorKey.currentState?.show();

    // Refresh posts data
    final PostsProvider postDetails =
        Provider.of<PostsProvider>(context, listen: false);
    postDetails.refreshPosts();
  }
}
