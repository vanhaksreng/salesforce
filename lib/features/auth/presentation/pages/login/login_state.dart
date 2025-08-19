import 'package:salesforce/realm/scheme/schemas.dart';

class LoginState {
  final bool isLoading;
  final String? keys;
  final CompanyInformation? company;

  const LoginState({this.isLoading = false, this.keys, this.company});

  LoginState copyWith({bool? isLoading, String? keys, CompanyInformation? company}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      keys: keys ?? this.keys,
      company: company ?? this.company,
    );
  }
}
