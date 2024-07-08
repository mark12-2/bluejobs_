import 'package:bluejobs/provider/auth_provider.dart';
import 'package:bluejobs/screens_for_auth/signin.dart';
import 'package:bluejobs/screens_for_auth/user_information.dart';
import 'package:bluejobs/styles/custom_button.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Create an Account.",
                          style: CustomTextStyle.semiBoldTextWhite.copyWith(
                              fontSize: responsiveSize(context, 0.05))),
                    )),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(height: 20),
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
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
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
                CustomButton(
                  onPressed: () async {
                    if (_passwordController.text ==
                        _confirmPasswordController.text) {
                      if (_emailController.text.isValidEmail) {
                        if (_passwordController.text.isValidPassword) {
                          try {
                            await Provider.of<AuthProvider>(context,
                                    listen: false)
                                .signUpWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserInformation(
                                    email: _emailController.text),
                              ),
                            );
                          } catch (e) {
                            print(e);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Password must be at least 8 characters, contain one uppercase letter, one lowercase letter, and one number'),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invalid email address'),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Passwords do not match'),
                        ),
                      );
                    }
                  },
                  buttonText: 'Next',
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
                            builder: (context) => const SignInPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Already have an account? Sign In",
                        style: CustomTextStyle.regularText.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension EmailValidator on String {
  bool get isValidEmail {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

extension PasswordValidator on String {
  bool get isValidPassword {
    return RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$')
        .hasMatch(this);
  }
}
