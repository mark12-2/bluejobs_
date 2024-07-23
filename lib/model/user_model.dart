class UserModel {
  String firstName;
  String middleName;
  String lastName;
  String suffix;
  String email;
  String role;
  String sex;
  String birthdate;
  String address;
  String? profilePic;
  String createdAt;
  String phoneNumber;
  String uid;
  bool isEnabled;

  UserModel({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.suffix,
    required this.email,
    required this.role,
    required this.sex,
    required this.birthdate,
    required this.address,
    this.profilePic,
    required this.createdAt,
    required this.phoneNumber,
    required this.uid,
    required this.isEnabled
  });

  // from map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'] ?? '',
      lastName: map['lastName'] ?? '',
      suffix: map['suffix'] ?? '',
      email: map['email'],
      role: map['role'] ?? '',
      sex: map['sex'] ?? '',
      birthdate: map['birthdate'] ?? '',
      address: map['address'] ?? '',
      profilePic: map['profilePic'],
      createdAt: map['createdAt'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      uid: map['uid'] ?? '',
      isEnabled: map['isEnabled'] = true
    );
  }

  set updatedAt(String updatedAt) {}

  // to map
  Map<String, dynamic> toMap() {
    return {
      "firstName": firstName,
      "middleName": middleName,
      "lastName": lastName,
      "suffix": suffix,
      "email": email,
      "role": role,
      "sex": sex,
      "birthdate": birthdate,
      "address": address,
      "profilePic": profilePic,
      "phoneNumber": phoneNumber,
      "createdAt": createdAt,
      "uid": uid,
      "isEnabled": isEnabled
    };
  }
}
