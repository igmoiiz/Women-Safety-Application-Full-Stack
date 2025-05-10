class OnboardingUserModel {
  final String? fatherName;
  final String? cnic;
  final String? gender;
  final String? bloodGroup;
  final String? username;
  final String? password;
  final String? phoneNumber;
  final String? emergencyPhoneNumber;
  final String? email;
  final String? emergencyEmail;
  final String? address;
  final List<String>? savedPosts;

  OnboardingUserModel({
    this.fatherName,
    this.cnic,
    this.gender,
    this.bloodGroup,
    this.username,
    this.password,
    this.phoneNumber,
    this.emergencyPhoneNumber,
    this.email,
    this.emergencyEmail,
    this.address,
    this.savedPosts,
  });

  Map<String, dynamic> toMap() {
    return {
      'fatherName': fatherName ?? '',
      'cnic': cnic ?? '',
      'gender': gender ?? '',
      'bloodGroup': bloodGroup ?? '',
      'username': username ?? '',
      'password': password ?? '',
      'phoneNumber': phoneNumber ?? '',
      'emergencyPhoneNumber': emergencyPhoneNumber ?? '',
      'email': email ?? '',
      'emergencyEmail': emergencyEmail ?? '',
      'address': address ?? '',
      'savedPosts': savedPosts ?? [],
    };
  }

  factory OnboardingUserModel.fromMap(Map<String, dynamic> map) {
    return OnboardingUserModel(
      fatherName: map['fatherName'] ?? '',
      cnic: map['cnic'] ?? '',
      gender: map['gender'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      emergencyPhoneNumber: map['emergencyPhoneNumber'] ?? '',
      email: map['email'] ?? '',
      emergencyEmail: map['emergencyEmail'] ?? '',
      address: map['address'] ?? '',
      savedPosts: map['savedPosts'] != null 
          ? List<String>.from(map['savedPosts']) 
          : [],
    );
  }
}
