import 'package:bluejobs/screens_for_auth/confetti.dart';
import 'package:bluejobs/provider/auth_provider.dart' as auth_provider;
import 'package:bluejobs/styles/custom_button.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ButtonSpecializationPage extends StatefulWidget {
  const ButtonSpecializationPage({super.key});

  @override
  State<ButtonSpecializationPage> createState() =>
      _ButtonSpecializationPageState();
}

class _ButtonSpecializationPageState extends State<ButtonSpecializationPage> {
  final List<String> skills = [
    "Carpentry",
    "Plumbing",
    "Sewing",
    "Doing Laundry",
    "Electrician",
    "Mechanic",
    "Construction Worker",
    "Factory Worker",
    "Welder",
    "Painter",
    "Landscaper",
    "Janitor",
    "HVAC Technician",
    "Heavy Equipment Operator",
    "Truck Driver",
    "Roofer",
    "Mason",
    "Steelworker",
    "Pipefitter",
    "Boilermaker",
    "Chef",
    "Butcher",
    "Baker",
    "Fisherman",
    "Miner",
    "Housekeeper",
    "Security Guard",
    "Firefighter",
    "Paramedic",
    "Nursing Assistant",
    "Retail Worker",
    "Warehouse Worker"
  ];

  final Set<String> selectedSkills = {};

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<auth_provider.AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 30, 47),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Choose what you are good at!",
                  style: CustomTextStyle.semiBoldText.copyWith(
                    fontSize: responsiveSize(context, 0.05),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: skills
                        .map((skill) {
                          final isSelected = selectedSkills.contains(skill);
                          return InputChip(
                            label: Text(
                              skill,
                              style: CustomTextStyle.regularText.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color.fromARGB(255, 7, 30, 47),
                            backgroundColor:
                                const Color.fromARGB(255, 7, 30, 47),
                            checkmarkColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedSkills.add(skill);
                                } else {
                                  selectedSkills.remove(skill);
                                }
                              });
                            },
                          );
                        })
                        .toList()
                        .cast<Widget>(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            CustomButton(
              onPressed: () async {
                if (selectedSkills.isNotEmpty) {
                  final userId = authProvider.uid;
                  if (userId != null) {
                    final userRef = FirebaseFirestore.instance
                        .collection("users")
                        .doc(userId);

                    await userRef.update({
                      "skills": selectedSkills.toList(),
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DoneCreatePage(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User ID is empty'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select at least one skill'),
                    ),
                  );
                }
              },
              buttonText: 'Next',
            ),
          ],
        ),
      ),
    );
  }
}
