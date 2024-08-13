import 'package:bluejobs/screens_for_auth/signin.dart';
import 'package:bluejobs/styles/custom_button.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class DoneCreatePage extends StatefulWidget {
  const DoneCreatePage({super.key});

  @override
  State<DoneCreatePage> createState() => _DoneCreatePageState();
}

class _DoneCreatePageState extends State<DoneCreatePage> {
  final ConfettiController _confettiKey =
      ConfettiController(duration: const Duration(seconds: 10));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiKey.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
        confettiController: _confettiKey,
        blastDirectionality: BlastDirectionality.explosive,
        colors: const [
          Colors.orange,
          Color.fromARGB(255, 7, 30, 47),
          Colors.white,
        ],
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 7, 30, 47),
            ),
            body: Column(children: [
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Welcome to BlueJobs!",
                            style: CustomTextStyle.titleText.copyWith(
                                fontSize: responsiveSize(context, 0.05))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text("You are one step closer...",
                            style: CustomTextStyle.typeRegularText.copyWith(
                                fontSize: responsiveSize(context, 0.04))),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        "Check your email to verify your account before logging in.",
                        style: CustomTextStyle.roleRegularText
                            .copyWith(fontSize: responsiveSize(context, 0.04))),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ListBody(
                  children: [
                    CustomButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInPage(),
                          ),
                        );
                      },
                      buttonText: 'Proceed to Log In',
                    ),
                  ],
                ),
              )
            ])));
  }
}
