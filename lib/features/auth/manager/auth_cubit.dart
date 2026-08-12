import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set(
          {
            'userName': user.displayName ?? '',
            'email': user.email ?? '',
            'profileImage': user.photoURL ?? '',
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

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