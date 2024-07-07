import 'package:bluejobs/chats/messaging_roompage.dart';
import 'package:bluejobs/default_screens/comment.dart';
import 'package:bluejobs/default_screens/view_profile.dart';
import 'package:bluejobs/provider/mapping/location_service.dart';
import 'package:bluejobs/provider/notifications/notifications_provider.dart';
import 'package:bluejobs/provider/posts_provider.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

class ViewPostPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const ViewPostPage({super.key, required this.post});

  @override
  State<ViewPostPage> createState() => _ViewPostPageState();
}

class _ViewPostPageState extends State<ViewPostPage> {
  bool _isApplied = false;
  final _commentTextController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  void showCommentDialog(String postId, BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => CommentScreen(postId: postId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post['title']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: widget.post['profilePic'] != null
                        ? NetworkImage(widget.post['profilePic'])
                        : null,
                    radius: 35.0,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfilePage(userId: widget.post['ownerId']),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              "${widget.post['name']}",
                              style: CustomTextStyle.semiBoldText.copyWith(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontSize: responsiveSize(context, 0.05),
                              ),
                            ),
                            const SizedBox(width: 5),
                            IconButton(
                              icon: Icon(Icons.message),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessagingBubblePage(
                                      receiverName: widget.post['name'],
                                      receiverId: widget.post['ownerId'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${widget.post['role']}",
                        style: CustomTextStyle.roleRegularText,
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 15),
              Text(
                "${widget.post['title']}",
                style: CustomTextStyle.semiBoldText,
              ),
              const SizedBox(height: 5),
              Text(
                "${widget.post['description']}",
                style: CustomTextStyle.regularText,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(
                    Icons.location_pin,
                    color: Colors.blue,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final locations =
                          await locationFromAddress(widget.post['location']);
                      final lat = locations[0].latitude;
                      final lon = locations[0].longitude;
                      showLocationPickerModal(
                          context, TextEditingController(text: '$lat, $lon'));
                    },
                    child: Text(
                      "${widget.post['location']} (tap to view location)",
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              Text(
                "Type of Job: ${widget.post['type']}",
                style: CustomTextStyle.typeRegularText,
              ),
              Text(
                "Rate: ${widget.post['rate'] ?? ''}",
                style: CustomTextStyle.regularText,
              ),
              const SizedBox(height: 20),
              // comment section and like
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            final postId = widget.post['id'];
                            final userId =
                                FirebaseAuth.instance.currentUser!.uid;

                            final postDoc = await FirebaseFirestore.instance
                                .collection('Posts')
                                .doc(postId)
                                .get();

                            if (postDoc.exists) {
                              final data =
                                  postDoc.data() as Map<String, dynamic>;

                              if (data.containsKey('likes')) {
                                final likes = (data['likes'] as List<dynamic>)
                                    .map((e) => e as String)
                                    .toList();

                                if (likes.contains(userId)) {
                                  likes.remove(userId);
                                } else {
                                  likes.add(userId);
                                }

                                await postDoc.reference
                                    .update({'likes': likes});
                              } else {
                                await postDoc.reference.update({
                                  'likes': [userId]
                                });
                              }
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.thumb_up),
                              const SizedBox(width: 5),
                              Text(
                                'Like',
                                style: CustomTextStyle.regularText,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 25),
                        InkWell(
                          onTap: () {
                            showCommentDialog(widget.post['id'], context);
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.comment),
                              SizedBox(width: 5),
                              Text(
                                'Comments',
                                style: CustomTextStyle.regularText,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        )
                      ],
                    ),
                    const SizedBox(width: 5),
                    widget.post['ownerId'] ==
                            FirebaseAuth.instance.currentUser!.uid
                        ? Container()
                        : widget.post['role'] == 'Employer'
                            ? FutureBuilder<bool>(
                                future: _checkApplicationStatus(
                                    widget.post['id'],
                                    FirebaseAuth.instance.currentUser!.uid),
                                builder: (context, snapshot) {
                                  bool isApplied = snapshot.data ?? false;
                                  return GestureDetector(
                                    onTap: isApplied || _isApplied
                                        ? null
                                        : () async {
                                            final notificationProvider =
                                                Provider.of<
                                                        NotificationProvider>(
                                                    context,
                                                    listen: false);
                                            String receiverId =
                                                widget.post['ownerId'];
                                            String applicantName = FirebaseAuth
                                                    .instance
                                                    .currentUser!
                                                    .displayName ??
                                                'Unknown';
                                            String applicantId = FirebaseAuth
                                                .instance.currentUser!.uid;

                                            await notificationProvider
                                                .someNotification(
                                              receiverId: receiverId,
                                              senderId: FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              senderName: applicantName,
                                              title: 'New Application',
                                              notif:
                                                  ', applied to your job entitled "${widget.post['title']}"',
                                            );

                                            // Save the applicant's information to the job post
                                            await Provider.of<PostsProvider>(
                                                    context,
                                                    listen: false)
                                                .addApplicant(widget.post['id'],
                                                    applicantId, applicantName);

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Successfully applied')),
                                            );

                                            setState(() {
                                              _isApplied = true;
                                            });
                                          },
                                    child: Container(
                                      height: 53,
                                      width: 105,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isApplied
                                              ? Colors.grey
                                              : Colors.orange,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                      ),
                                      child: Center(
                                        child: Text(
                                          isApplied ? 'Applied' : 'Apply Job',
                                          style: CustomTextStyle.regularText
                                              .copyWith(
                                            color: isApplied
                                                ? Colors.grey
                                                : const Color.fromARGB(
                                                    255, 0, 0, 0),
                                            fontSize:
                                                responsiveSize(context, 0.03),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(), // return empty container if role is not 'Employer'
                  ],
                ),
              ),
            ],
          ),
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
        // You can add a success message here if you want
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added successfully')),
        );
      } catch (e) {
        // Handle errors here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $e')),
        );
      }
    }
  }
}
