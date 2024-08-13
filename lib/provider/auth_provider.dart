import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bluejobs/model/user_model.dart';
import 'package:bluejobs/screens_for_auth/signin.dart';
import 'package:bluejobs/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthProvider with ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _uid;
  String get uid => _uid ?? '';
  UserModel? _userModel;
  UserModel get userModel => _userModel!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // check if user is signed in
  void checkSign() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;
    notifyListeners();
  }

  // sett user as sign in
  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("is_signedin", false);
    _isSignedIn = false;
    notifyListeners();
  }

  // sign up with email and password
  Future<void> signUpWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      _uid = userCredential.user?.uid;

      await userCredential.user?.sendEmailVerification();

      _isSignedIn = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

// check if user's email is verified
  Future<bool> isEmailVerified() async {
    if (_firebaseAuth.currentUser != null) {
      await _firebaseAuth.currentUser?.reload();
      return _firebaseAuth.currentUser?.emailVerified ?? false;
    } else {
      return false;
    }
  }

  // sign in with email and password
  Future<void> signInWithEmailAndPassword(
      {required String email,
      required String password,
      required context}) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      final userUid = userCredential.user?.uid;

      final userRef = _firebaseFirestore.collection('users').doc(userUid);
      final userData = await userRef.get();
      if (!userData.get('isEnabled')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Your account has been disabled. Please contact an administrator.'),
            backgroundColor: Colors.red,
          ),
        );

        await _firebaseAuth.signOut();
        return;
      }

      if (!await isEmailVerified()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please verify your email address before proceeding.'),
            backgroundColor: Colors.red,
          ),
        );

        await _firebaseAuth.signOut();
        return;
      }

      _uid = userUid;
      _isSignedIn = true;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

// check if user exists on database
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> checkExistingUser() async {
    if (_auth.currentUser != null) {
      DocumentSnapshot snapshot = await _firebaseFirestore
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .get();
      return snapshot.exists;
    } else {
      return false;
    }
  }

  // sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _isSignedIn = false;
    notifyListeners();
  }

  // save user information to firebase firestore
  Future<void> saveUserDataToFirebase({
    required BuildContext context,
    required UserModel userModel,
    required File profilePic,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      String profilePicUrl =
          await storeFileToStorage("profilePic/$_uid", profilePic);
      userModel.profilePic = profilePicUrl;
      userModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
      userModel.email = _firebaseAuth.currentUser!.email!;
      userModel.uid = _uid!;
      _userModel = userModel;

      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .set(userModel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  // update user information
  Future<void> updateUserData({
    required BuildContext context,
    String? firstName,
    String? middleName,
    String? lastName,
    String? suffix,
    String? address,
    File? profilePic,
    required String uid,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (profilePic != null && profilePic.existsSync()) {
        userModel.profilePic =
            await storeFileToStorage("profilePic/$uid", profilePic);
      }
      if (firstName != null && firstName.isNotEmpty) {
        userModel.firstName = firstName;
      }
      if (middleName != null && middleName.isNotEmpty) {
        userModel.middleName = middleName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        userModel.lastName = lastName;
      }
      if (suffix != null && suffix.isNotEmpty) {
        userModel.suffix = suffix;
      }
      if (address != null && address.isNotEmpty) {
        userModel.address = address;
      }
      userModel.updatedAt = DateTime.now().millisecondsSinceEpoch.toString();
      _userModel = userModel;

      await _firebaseFirestore
          .collection("users")
          .doc(uid)
          .update(userModel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      showSnackBar(context, e.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  // storing the image in firebase storage
  Future<String> storeFileToStorage(String ref, File file) async {
    if (!file.existsSync()) {
      throw Exception("File does not exist");
    }
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> getDataFromFirestore() async {
    try {
      await _firebaseFirestore
          .collection("users")
          .doc(_firebaseAuth.currentUser!.uid)
          .get()
          .then((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          _userModel = UserModel(
              firstName: snapshot['firstName'],
              middleName: snapshot['middleName'],
              lastName: snapshot['lastName'],
              suffix: snapshot['suffix'],
              email: snapshot['email'],
              role: snapshot['role'],
              sex: snapshot['sex'],
              address: snapshot['address'],
              birthdate: snapshot['birthdate'],
              createdAt: snapshot['createdAt'],
              uid: snapshot['uid'],
              profilePic: snapshot['profilePic'],
              phoneNumber: snapshot['phoneNumber'],
              isEnabled: true);
          _uid = userModel.uid;
        } else {
          // Handle the case where the user data is null
          print("User data not found");
        }
      });
    } catch (e) {
      // Handle any exceptions that might occur
      print("Error getting data from Firestore: $e");
    }
  }

  Future saveUserDataToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("user_model", jsonEncode(userModel.toMap()));
  }

  Future getDataFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("user_model") ?? '';
    _userModel = UserModel.fromMap(jsonDecode(data));
    _uid = _userModel!.uid;
    notifyListeners();
  }

  Future userSignOut() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isSignedIn = false;
    notifyListeners();
    s.clear();
  }

  // use with caution
  // deleting user information (account) and its posts
  Future<void> deleteUserFromFirestore(String uid, String password) async {
    User? user = _firebaseAuth.currentUser;

    if (user != null) {
      try {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);

        await _firebaseFirestore.collection("users").doc(uid).delete();

        // delete posts of user
        final postsQuery = _firebaseFirestore
            .collection("Posts")
            .where("ownerId", isEqualTo: uid);
        final postsSnapshot = await postsQuery.get();
        for (var doc in postsSnapshot.docs) {
          await doc.reference.delete();
        }

        // delete the user
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          print(
              'The user must reauthenticate before this operation can be executed.');
        } else {
          print('Error: $e');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void initiateUserDeletion(BuildContext context) async {
    String userId = _firebaseAuth.currentUser!.uid;

    String? password = await showPasswordPromptDialog(context);

    if (password != null && password.isNotEmpty) {
      await deleteUserFromFirestore(userId, password);
      await signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User successfully deleted')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    } else {
      print('Password not entered.');
    }
  }

  Future<String?> showPasswordPromptDialog(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(passwordController.text);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
