import 'dart:io';
import 'package:bluejobs/dropdowns/addresses.dart';
import 'package:bluejobs/model/user_model.dart';
import 'package:bluejobs/navigation/employer_navigation.dart';
import 'package:bluejobs/navigation/jobhunter_navigation.dart';
import 'package:bluejobs/provider/auth_provider.dart';
import 'package:bluejobs/styles/custom_button.dart';
import 'package:bluejobs/styles/custom_theme.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';
import 'package:bluejobs/utils/utils.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

class UserInformation extends StatefulWidget {
  final String email;

  const UserInformation({super.key, required this.email});

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final ConfettiController _confettiKey =
      ConfettiController(duration: const Duration(seconds: 10));
  File? image;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _roleSelection;
  String? _sex;
  final _birthdayController = TextEditingController();
  String? _address;
  // focus node - name and email
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  // birthdate
  final FocusNode _birthdayFocusNode = FocusNode();
  DateTime? _selectedDate;

  bool _isNameFocused = false;

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _birthdayFocusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Listen for focus changes
    _nameFocusNode.addListener(_onFocusChange);
    _emailFocusNode.addListener(_onFocusChange);
    _roleSelection = null;
    _address = null;
  }

  void _onFocusChange() {
    setState(() {
      _isNameFocused = _nameFocusNode.hasFocus;
    });
  }

// birthdate input
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _birthdayController.text =
            DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  // for selecting image
  void selectImage() async {
    image = await pickImage(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: isLoading == true
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.grey,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Let's set up your account.",
                              style: CustomTextStyle.semiBoldText.copyWith(
                                  fontSize: responsiveSize(context, 0.05))),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    // circle avatar
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
                              backgroundImage: FileImage(image!),
                              radius: 50,
                            ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Tap to Select an Image',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListBody(children: [
                        TextField(
                          // name input
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
                        const SizedBox(
                          height: 20,
                        ),

                        IntlPhoneField(
                          decoration: customInputDecoration('Phone Number'),
                          controller: _phoneController,
                          initialCountryCode:
                              'PH', // Set the initial country code to Philippines
                          onChanged: (phone) {},
                        ),

                        // sex input
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sex',
                                    style: CustomTextStyle.regularText,
                                  ),
                                ],
                              ),
                              RadioListTile(
                                title: const Text(
                                  'Male',
                                  style: CustomTextStyle.regularText,
                                ),
                                value: 'Male',
                                groupValue: _sex,
                                onChanged: (value) {
                                  setState(() {
                                    _sex = value as String?;
                                  });
                                },
                              ),
                              RadioListTile(
                                title: const Text('Female',
                                    style: CustomTextStyle.regularText),
                                value: 'Female',
                                groupValue: _sex,
                                onChanged: (value) {
                                  setState(() {
                                    _sex = value as String?;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        // birthdate input
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: GestureDetector(
                            onTap: () => _selectDate(context),
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _birthdayController,
                                focusNode: _birthdayFocusNode,
                                decoration: const InputDecoration(
                                    labelText: 'Birthday',
                                    labelStyle: CustomTextStyle.regularText,
                                    suffixIcon: Icon(Icons.calendar_today),
                                    hintText: 'Select your birthday',
                                    hintStyle: CustomTextStyle.regularText,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                    )),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),

                        // address input
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          //auto complete search addresses, but only in albay
                          child: Autocomplete<String>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<String>.empty();
                              }
                              // fix input in adress because of other syntaxes like comma
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
                                  labelStyle: CustomTextStyle.regularText,
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
                              setState(
                                () {
                                  _address = selection;
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                        // user type or role input
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: [
                              Container(
                                height: 57.0,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: DropdownButton<String>(
                                  value: _roleSelection,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _roleSelection = newValue;
                                    });
                                  },
                                  items: <String>['Job Hunter', 'Employer']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  hint: const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('Select your role'),
                                  ),
                                  style: CustomTextStyle.regularText,
                                  isExpanded: true,
                                  underline: Container(
                                    height: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        // button for submition
                        SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.90,
                          child: CustomButton(
                            buttonText: "Continue",
                            onPressed: () {
                              storeData();
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    elevation: 15,
                                    child: Container(
                                      height: 150,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          ConfettiWidget(
                                            confettiController: _confettiKey,
                                            blastDirectionality:
                                                BlastDirectionality.explosive,
                                            colors: const [
                                              Colors.orange,
                                              Color.fromARGB(255, 7, 30, 47),
                                              Colors.white,
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                    "Welcome to BlueJobs!",
                                                    style: CustomTextStyle
                                                        .titleText
                                                        .copyWith(
                                                            fontSize:
                                                                responsiveSize(
                                                                    context,
                                                                    0.05))),
                                              )),
                                          const SizedBox(height: 20),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Get Started'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                              _confettiKey.play();
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 400,
                        ),
                      ]),
                    ),
                  ]),
                ),
        ));
  }

  // storing data function
  void storeData() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    if (_nameController.text.isEmpty ||
        _roleSelection == null ||
        _birthdayController.text.isEmpty ||
        _address == null) {
      showSnackBar(context, "Please fill in all fields...");
      return;
    }

    UserModel userModel = UserModel(
      name: _nameController.text.trim(),
      email: '',
      role: _roleSelection?.trim() ?? "",
      sex: _sex ?? "",
      birthdate: _birthdayController.text.trim(),
      address: _address?.trim() ?? "",
      profilePic: "",
      createdAt: "",
      phoneNumber: _phoneController.text.trim(),
      uid: ap.uid,
    );

    if (image != null) {
      ap.saveUserDataToFirebase(
        context: context,
        userModel: userModel,
        profilePic: image!,
        onSuccess: () {
          ap.saveUserDataToSP().then((value) {
            ap.setSignIn();
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
    } else {
      showSnackBar(context, "Please upload your profile photo");
    }
  }
}
