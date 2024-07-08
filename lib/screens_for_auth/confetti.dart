import 'package:bluejobs/navigation/employer_navigation.dart';
import 'package:bluejobs/navigation/jobhunter_navigation.dart';
import 'package:bluejobs/provider/auth_provider.dart';
import 'package:bluejobs/styles/custom_button.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String role = ap.userModel.role;
    return ConfettiWidget(
        confettiController: _confettiKey,
        blastDirectionality: BlastDirectionality.explosive, // Explosive blast
        colors: const [
          Colors.orange,
          Color.fromARGB(255, 7, 30, 47),
          Colors.white,
        ],
        child: Scaffold(
            appBar: AppBar(),
            body: Column(children: [
              const SizedBox(
                height: 50,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Welcome to BlueJobs!",
                        style: CustomTextStyle.titleText
                            .copyWith(fontSize: responsiveSize(context, 0.05))),
                  )),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ListBody(
                  children: [
                    CustomButton(
                      onPressed: () {
                        if (role == 'Employer') {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmployerNavigation(),
                            ),
                            (route) => false,
                          );
                        } else if (role == 'Job Hunter') {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const JobhunterNavigation(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      buttonText: 'Next',
                    ),
                  ],
                ),
              )
            ])));
  }
}
