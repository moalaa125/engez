import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendOtp({required String phoneNumber}) async {
    emit(AuthLoading());

    String formattedPhone = phoneNumber.trim();
    if (formattedPhone.startsWith('0')) {
      formattedPhone = formattedPhone.substring(1);
    }
    formattedPhone = '+20$formattedPhone';

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {},

        verificationFailed: (FirebaseAuthException e) {
          emit(
            AuthError(
              errorMessage: e.message ?? 'حصل خطأ أثناء التحقق من الرقم',
            ),
          );
        },

        codeSent: (String verificationId, int? resendToken) {
          emit(OtpSentSuccess(verificationId: verificationId));
        },

        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      emit(AuthError(errorMessage: e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: <String>['email']);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        emit(const AuthError(errorMessage: 'تم إلغاء تسجيل الدخول'));
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      emit(AuthSuccess());
    } catch (e) {
      emit(
        AuthError(
          errorMessage: 'حصل مشكلة أثناء تسجيل الدخول: ${e.toString()}',
        ),
      );
    }
  }
}
