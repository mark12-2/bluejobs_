import 'package:bluejobs/navigation/employer_navigation.dart';
import 'package:bluejobs/navigation/jobhunter_navigation.dart';
import 'package:bluejobs/provider/auth_provider.dart';
import 'package:bluejobs/screens_for_auth/password_change.dart';
import 'package:bluejobs/screens_for_auth/signup.dart';
import 'package:bluejobs/styles/custom_button.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  final bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 30, 47),
      ),
      backgroundColor: const Color.fromARGB(255, 19, 52, 77),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Connecting Blue Collars. One Tap at a time!',
                style: CustomTextStyle.semiBoldText.copyWith(
                  color: Colors.white,
                  fontSize: responsiveSize(context, 0.03),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sign in Your Account',
                style: CustomTextStyle.semiBoldText.copyWith(
                  color: Colors.white,
                  fontSize: responsiveSize(context, 0.03),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: CustomTextStyle.regularText,
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: CustomTextStyle.regularText,
                  fillColor: Colors.white,
                  filled: true,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 220.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PasswordChange(),
                      ),
                    );
                  },
                  child: Text(
                    "Forgot Password?",
                    style: CustomTextStyle.regularText.copyWith(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                onPressed: () async {
                  try {
                    final ap = Provider.of<AuthProvider>(context, listen: false);
                    await Provider.of<AuthProvider>(context, listen: false)
                        .signInWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                    ap.checkExistingUser().then((value) async {
          if (value == true) {
            ap.getDataFromFirestore().then(
              (userData) async {
                await ap.saveUserDataToSP();
                await ap.setSignIn();

                // Fetch the user's role from the fetched data
                String role = ap.userModel.role;

                // Navigate to the designated page based on the role
                if (role == 'Employer') {
                  if (isLoading == true) {
                    CircularProgressIndicator();
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmployerNavigation(),
                      ),
                      (route) => false,
                    );
                  }
                } else if (role == 'Job Hunter') {
                  if (isLoading == true) {
                    CircularProgressIndicator();
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JobhunterNavigation(),
                      ),
                      (route) => false,
                    );
                  }
                }
              },
            );
            }
                    });
                  } catch (e) {
                    // Handle the error
                    print(e);
                  }
                },
                buttonText: 'Sign In',
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Don't have an account? Register here",
                      style: CustomTextStyle.regularText.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
