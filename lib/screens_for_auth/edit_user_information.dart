import 'dart:io';
import 'package:bluejobs/dropdowns/addresses.dart';
import 'package:bluejobs/navigation/employer_navigation.dart';
import 'package:bluejobs/navigation/jobhunter_navigation.dart';
import 'package:bluejobs/provider/auth_provider.dart';
import 'package:bluejobs/styles/custom_button.dart';
import 'package:bluejobs/styles/custom_theme.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:bluejobs/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditUserInformation extends StatefulWidget {
  const EditUserInformation({super.key});

  @override
  State<EditUserInformation> createState() => _EditUserInformationState();
}

class _EditUserInformationState extends State<EditUserInformation> {
  File? image;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdayController = TextEditingController();
  String? _address;
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final authProvider = AuthProvider();

  bool _isNameFocused = false;
  bool _isEmailFocused = false;

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
  }

  @override
  void initState() {
    super.initState();
    final ap = Provider.of<AuthProvider>(context, listen: false);
    if (ap.isSignedIn) {
      _nameController.text = ap.userModel.name;
      _emailController.text = ap.userModel.email ?? '';
      _address = ap.userModel.address;
      image = File(ap.userModel.profilePic ?? '');
    }
    _nameFocusNode.addListener(_onFocusChange);
    _emailFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isNameFocused = _nameFocusNode.hasFocus;
      _isEmailFocused = _emailFocusNode.hasFocus;
    });
  }

  void selectImage() async {
    image = await pickImage(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userLoggedIn = Provider.of<AuthProvider>(context, listen: false);
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Edit your account details.",
                          style: CustomTextStyle.semiBoldText.copyWith(
                              fontSize: responsiveSize(context, 0.05)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => selectImage(),
                      child: image == null
                          ? const CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 50,
                              child: Icon(
                                Icons.account_circle,
                                size: 50,
                                color: Colors.white,
                              ),
                            )
                          : CircleAvatar(
                              backgroundImage: NetworkImage(
                                  userLoggedIn.userModel.profilePic ?? 'null'),
                              radius: 50,
                            ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListBody(
                        children: [
                          TextField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            decoration: customInputDecoration('Full Name'),
                          ),
                          if (_isNameFocused)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Enter your full name. Ex. Juan A. Dela CRUZ',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ),
                          const SizedBox(height: 20),
                          // TextField(
                          //   controller: _emailController,
                          //   focusNode: _emailFocusNode,
                          //   decoration: customInputDecoration('Email'),
                          // ),
                          // if (_isEmailFocused)
                          //   const Padding(
                          //     padding: EdgeInsets.only(top: 8.0),
                          //     child: Text(
                          //       'Use an active email',
                          //       style:
                          //           TextStyle(color: Colors.grey, fontSize: 12),
                          //     ),
                          //   ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Autocomplete<String>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<String>.empty();
                                }
                                String normalizedInput = textEditingValue.text
                                    .toLowerCase()
                                    .replaceAll(',', '');
                                return Addresses.allAddresses
                                    .where((String option) {
                                  String normalizedOption =
                                      option.toLowerCase().replaceAll(',', '');
                                  return normalizedOption
                                      .contains(normalizedInput);
                                }).toList();
                              },
                              fieldViewBuilder: (BuildContext context,
                                  TextEditingController
                                      fieldTextEditingController,
                                  FocusNode fieldFocusNode,
                                  VoidCallback onFieldSubmitted) {
                                return TextField(
                                  controller: fieldTextEditingController,
                                  focusNode: fieldFocusNode,
                                  decoration: const InputDecoration(
                                    labelText: 'Find your Address',
                                    suffixIcon: Icon(Icons.search),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              optionsViewBuilder: (BuildContext context,
                                  AutocompleteOnSelected<String> onSelected,
                                  Iterable<String> options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    child: ListView(
                                      padding: EdgeInsets.zero,
                                      children:
                                          options.map<Widget>((String option) {
                                        return InkWell(
                                          onTap: () => onSelected(option),
                                          child: ListTile(
                                            title: Text(option),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                              onSelected: (String selection) {
                                setState(() {
                                  _address = selection;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 50),
                          SizedBox(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.90,
                            child: CustomButton(
                              buttonText: "Save",
                              onPressed: () {
                                storeData();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Profile edited successfully'),
                                ));
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.90,
                            child: CustomButton(
                              buttonText: "Cancel",
                              buttonColor: Colors.red,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () {
                              authProvider.initiateUserDeletion(context);
                            },
                            child: Text('Delete Account'),
                          ),
                          const SizedBox(height: 400),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void storeData() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);

    String? name = _nameController.text.trim().isEmpty
        ? null
        : _nameController.text.trim();
    String? address =
        _address?.trim().isEmpty ?? true ? null : _address?.trim();
    image = image ?? null;

    await ap.updateUserData(
      context: context,
      uid: ap.uid,
      name: name,
      address: address,
      profilePic: image,
      onSuccess: () {
        ap.saveUserDataToSP().then((value) {
          String role = ap.userModel.role;

          // Navigate to the designated page based on the role
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
        });
      },
    );
  }
}
