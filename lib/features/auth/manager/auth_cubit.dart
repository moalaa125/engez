import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));
      
      if (username.isNotEmpty && password.isNotEmpty) {
        emit(AuthSuccess());
      } else {
        emit(const AuthFailure(errorMessage: 'الرجاء إدخال اسم المستخدم وكلمة المرور'));
      }
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString()));
    }
  }
}
