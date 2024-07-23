import 'package:bluejobs/jobhunter_screens/resume_view.dart';
import 'package:bluejobs/provider/notifications/notifications_provider.dart';
import 'package:bluejobs/provider/posts_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ApplicantsPage extends StatefulWidget {
  final String jobId;

  const ApplicantsPage({super.key, required this.jobId});

  @override
  State<ApplicantsPage> createState() => _ApplicantsPageState();
}

class _ApplicantsPageState extends State<ApplicantsPage> {
  final PostsProvider _postsProvider = PostsProvider();
  final _notificationProvider = NotificationProvider();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot> _applicantsStream;

  @override
  void initState() {
    super.initState();
    _applicantsStream = _postsProvider.getApplicantsStream(widget.jobId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applicants'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _applicantsStream,
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
              child: Text("No applicants"),
            );
          }

          final applicants = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: applicants.length,
                  itemBuilder: (context, index) {
                    final applicant = applicants[index];

                    String applicantName = applicant['applicantName'];
                    String applicantPhone = applicant['applicantPhone'];
                    String applicantId = applicant['idOfApplicant'];
                    bool isHired = applicant['isHired'] ?? false;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: ListTile(
                          title: Text(applicantName),
                          subtitle: Text(applicantPhone),
                          trailing: ElevatedButton(
                            onPressed: isHired
                                ? null
                                : () {
                                    _hireApplicant(applicantId);
                                  },
                            child: Text(isHired ? 'Hired' : 'Hire'),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobHunterResumeView(
                                    userId: applicant['idOfApplicant']),
                              ),
                            );
                          },
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Deletion'),
                                  content: const Text(
                                      'Are you sure you want to remove this applicant?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                        child: const Text('Delete'),
                                        onPressed: () {
                                          _deleteApplicant(applicantId);
                                        }),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _hireApplicant(String applicantId) async {
    await _postsProvider.updateApplicantStatus(widget.jobId, applicantId, true);

    // Send a notification to the applicant
    await _notificationProvider.someNotification(
      receiverId: applicantId,
      senderId: _auth.currentUser!.uid,
      senderName: _auth.currentUser!.displayName ?? '',
      title: 'Job Update',
      notif: ', hired you for the job',
    );

    print('Hiring $applicantId and sending a notification');
  }

  void _deleteApplicant(String applicantId) async {
    await _postsProvider.removeApplicantFromJob(widget.jobId, applicantId);

    print('Deleting $applicantId');
  }
}
