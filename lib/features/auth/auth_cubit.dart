import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesforce/features/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState(isLoading: false));
}
