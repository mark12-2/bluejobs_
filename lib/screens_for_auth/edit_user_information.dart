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
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _suffixController = TextEditingController();
  final _birthdayController = TextEditingController();
  String? _address;
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _middleNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _suffixFocusNode = FocusNode();
  final authProvider = AuthProvider();

  bool _isSuffixFocused = false;

  @override
  void dispose() {
    super.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _suffixController.dispose();
    _birthdayController.dispose();
  }


  @override
  void initState() {
    super.initState();
    final ap = Provider.of<AuthProvider>(context, listen: false);
    if (ap.isSignedIn) {
      _firstNameController.text = ap.userModel.firstName;
      _middleNameController.text = ap.userModel.middleName;
      _lastNameController.text = ap.userModel.lastName;
      _suffixController.text = ap.userModel.suffix;
      _address = ap.userModel.address;
      image = File(ap.userModel.profilePic ?? '');
    }
    _firstNameFocusNode.addListener(_onFocusChange);
    _middleNameFocusNode.addListener(_onFocusChange);
    _lastNameFocusNode.addListener(_onFocusChange);
    _suffixFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isSuffixFocused = _suffixFocusNode.hasFocus;
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
                            // first name input
                            controller: _firstNameController,
                            focusNode: _firstNameFocusNode,
                            decoration: customInputDecoration('First Name'),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            // last name input
                            controller: _lastNameController,
                            focusNode: _lastNameFocusNode,
                            decoration: customInputDecoration('Last Name'),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            // middle name input
                            controller: _middleNameController,
                            focusNode: _middleNameFocusNode,
                            decoration:
                                customInputDecoration('Middle Name (Optional)'),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            // suffix input
                            controller: _suffixController,
                            focusNode: _suffixFocusNode,
                            decoration:
                                customInputDecoration('Suffix (Optional)'),
                          ),
                          if (_isSuffixFocused)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Suffixes: Sr., Jr., II, III,  etc.',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ),
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

    String? firstName = _firstNameController.text.trim().isEmpty
        ? null
        : _firstNameController.text.trim();
    String? middleName = _middleNameController.text.trim().isEmpty
        ? null
        : _middleNameController.text.trim();
    String? lastName = _lastNameController.text.trim().isEmpty
        ? null
        : _lastNameController.text.trim();
    String? suffix = _suffixController.text.trim().isEmpty
        ? null
        : _suffixController.text.trim();
    String? address =
        _address?.trim().isEmpty ?? true ? null : _address?.trim();
    image = image ?? null;

    await ap.updateUserData(
      context: context,
      uid: ap.uid,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      suffix: suffix,
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
