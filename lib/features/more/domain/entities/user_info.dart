class UserInfo {
  final String firstName;
  final String lastName;
  final String userImagePath;
  final String phoneNumber;

  UserInfo({
    this.firstName = "",
    this.lastName = "",
    required this.userImagePath,
    this.phoneNumber = "",
  });

  String get userName => "$firstName $lastName";
}
