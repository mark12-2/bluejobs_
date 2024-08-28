import 'package:bluejobs/model/posts_model.dart';
import 'package:bluejobs/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PostsProvider with ChangeNotifier {
  final CollectionReference posts =
      FirebaseFirestore.instance.collection('Posts');
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isJobPostAvailable = true;
  bool get isJobPostAvailable => _isJobPostAvailable;

  Future<UserModel?> fetchCurrentUserDetails() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser != null) {
        final docRef =
            FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
        final docSnap = await docRef.get();

        if (docSnap.exists) {
          return UserModel.fromMap(docSnap.data() ?? {});
        } else {
          debugPrint("No user found!");
          return null;
        }
      } else {
        debugPrint("No current user signed in.");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching user details: $e");
      return null;
    }
  }

  // method to add a job post
  Future<DocumentReference> addPost(Post post) async {
    final currentUser = await FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('No user signed in.');
    }

    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
    final userDocSnap = await userDocRef.get();

    if (userDocSnap.exists) {
      final UserModel currentUserDetails =
          UserModel.fromMap(userDocSnap.data() ?? {});

      return posts.add({
        "ownerId": currentUserDetails.uid,
        "name":
            "${currentUserDetails.firstName} ${currentUserDetails.middleName} ${currentUserDetails.lastName} ${currentUserDetails.suffix}",
        "email": currentUserDetails.email,
        "role": currentUserDetails.role,
        "profilePic": currentUserDetails.profilePic,
        "title": post.title ?? '',
        "description": post.description,
        "type": post.type,
        "location": post.location ?? '',
        "startDate": post.startDate ?? '',
        "workingHours": post.workingHours ?? '',
        "timestamp": Timestamp.now(),
        "likes": [],
        "isApplicationFull": false,
      });
    } else {
      throw Exception('User document not found.');
    }
  }

  Future<void> setJobPostAsUnavailable(String postId) async {
    await FirebaseFirestore.instance.collection('Posts').doc(postId).update({
      'isApplicationFull': true,
    });
    _isJobPostAvailable = false;
    notifyListeners();
  }

  Future<void> setJobPostAsAvailable(String postId) async {
    await FirebaseFirestore.instance.collection('Posts').doc(postId).update({
      'isApplicationFull': false,
    });
  }

  // deleting a post
  Future<void> deletePost(String postId) async {
    final postRef = FirebaseFirestore.instance.collection('Posts').doc(postId);
    await postRef.delete();
  }

  // fetch all the post from firestore to home page for viewing
  Stream<QuerySnapshot> getPostsStream() {
    final postsStream = FirebaseFirestore.instance
        .collection('Posts')
        .orderBy("timestamp", descending: true)
        .snapshots();

    return postsStream;
  }

  Future<void> refreshPosts() async {
    getPostsStream();
  }

  // fetching users' own post
  Stream<QuerySnapshot> getSpecificPostsStream(String? userId) {
    if (userId == null || userId.isEmpty) {
      return Stream.empty();
    }
    return posts.where('ownerId', isEqualTo: userId).snapshots();
  }

// update post method
  Future<void> updatePost(Post post) async {
    UserModel? currentUserDetails = await fetchCurrentUserDetails();

    if (currentUserDetails == null) {
      throw Exception('Current user details could not be fetched.');
    }

    await posts.doc(post.id).update({
      "title": post.title ?? '',
      "description": post.description,
      "type": post.type,
      "location": post.location ?? '',
      "name":
          "${currentUserDetails.firstName} ${currentUserDetails.middleName} ${currentUserDetails.lastName} ${currentUserDetails.suffix}",
      "email": currentUserDetails.email,
      "role": currentUserDetails.role,
      "profilePic": currentUserDetails.profilePic,
      "startDate": post.startDate ?? '',
      "workingHours": post.workingHours ?? '',
      "timestamp": Timestamp.now(),
    });
  }

  // adding a comment
  Future<DocumentReference> addComment(
      String commentText, String postId) async {
    UserModel? currentUserDetails = await fetchCurrentUserDetails();
    if (currentUserDetails == null) {
      throw Exception('Current user details could not be fetched.');
    }

    Map<String, dynamic> commentData = {
      'commentText': commentText,
      'postId': postId,
      'profilePic': currentUserDetails.profilePic,
      'username':
          "${currentUserDetails.firstName} ${currentUserDetails.middleName} ${currentUserDetails.lastName} ${currentUserDetails.suffix}",
      'userId': currentUserDetails.uid,
      'createdAt': Timestamp.now(),
    };

    return FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .add(commentData);
  }

  Future<void> addApplicant(
    String postId,
    String applicantId,
    String applicantName,
  ) async {
    final postRef = FirebaseFirestore.instance.collection('Posts').doc(postId);
    final postDoc = await postRef.get();

    if (postDoc.exists) {
      UserModel? currentUserDetails = await fetchCurrentUserDetails();
      if (currentUserDetails == null) {
        throw Exception('Current user details could not be fetched.');
      }

      await FirebaseFirestore.instance
          .collection('Posts')
          .doc(postId)
          .collection('Applicants')
          .doc(applicantId)
          .set({
        'applicantName':
            "${currentUserDetails.firstName} ${currentUserDetails.middleName} ${currentUserDetails.lastName} ${currentUserDetails.suffix}",
        'applicantPhone': currentUserDetails.phoneNumber,
        'idOfApplicant': applicantId,
        'isHired': false,
        'timestamp': Timestamp.now()
      });

      await postRef.update({
        'applicants': FieldValue.arrayUnion([applicantId]),
      });
    } else {
      // Show an error message or notification
      print('Cannot add more applicants. The job is full.');
    }
  }

  Future<void> applyJob(String jobId, String jobTitle, String jobDescription,
      String employerId, String employerName) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final applicantRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("applications")
        .doc(jobId);

    await applicantRef.set({
      "jobId": jobId,
      "jobTitle": jobTitle,
      "jobDescription": jobDescription,
      "employerId": employerId,
      "employerName": employerName,
      "status": false,
      "timestamp": Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getApplicantsStream(String jobId) {
    return FirebaseFirestore.instance
        .collection('Posts')
        .doc(jobId)
        .collection('Applicants')
        .snapshots();
  }

  // Function to check if the current user has applied for a job
  Future<bool> hasApplied(String postId, String applicantId) async {
    final postDoc = await _firestore.collection('Posts').doc(postId).get();
    if (postDoc.exists) {
      final data = postDoc.data() as Map<String, dynamic>;
      if (data.containsKey('applicants')) {
        final applicants = (data['applicants'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        return applicants
            .any((applicant) => applicant['applicantId'] == applicantId);
      }
    }
    return false;
  }

  Future<void> updateApplicantStatus(
      String jobId, String applicantId, bool isHired) async {
    await FirebaseFirestore.instance
        .collection('Posts')
        .doc(jobId)
        .collection('Applicants')
        .doc(applicantId)
        .update({'isHired': isHired});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(applicantId)
        .collection('applications')
        .doc(jobId)
        .update({'status': isHired});
  }

  Future<void> removeApplicantFromJob(String jobId, String applicantId) async {
    await FirebaseFirestore.instance
        .collection('Posts')
        .doc(jobId)
        .collection('Applicants')
        .doc(applicantId)
        .delete();
  }

  Future<bool> savePost(String postId, String userId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final savedPostsRef = userRef.collection('saved');
    await savedPostsRef.doc(postId).set({'postId': postId, 'isSaved': true});
    return true;
  }

  Future<bool> isPostSaved(String postId, String userId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final savedPostsRef = userRef.collection('saved');
    final postDoc = await savedPostsRef.doc(postId).get();
    return postDoc.exists && postDoc.get('isSaved');
  }
}
