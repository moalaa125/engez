import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendOtp({required String phoneNumber}) async {
    emit(AuthLoading());

    // 1. تنظيف الرقم: لو بدأ بصفر نشيله عشان نركب كود الدولة صح
    String formattedPhone = phoneNumber.trim();
    if (formattedPhone.startsWith('0')) {
      formattedPhone = formattedPhone.substring(1);
    }
    // إضافة كود مصر الدولي
    formattedPhone = '+20$formattedPhone';

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),

        // لو التحقق تم تلقائياً (في بعض أجهزة أندرويد)
        verificationCompleted: (PhoneAuthCredential credential) async {
          // هنا نقدر نعمل تسجيل دخول تلقائي لو حابين
        },

        // لو حصلت مشكلة أثناء الإرسال (مثلاً الرقم غلط أو باقة الرسايل خلصت)
        verificationFailed: (FirebaseAuthException e) {
          emit(
            AuthError(
              errorMessage: e.message ?? 'حصل خطأ أثناء التحقق من الرقم',
            ),
          );
        },

        // الكود اتبعت بنجاح! هنا بناخد الـ verificationId ونروح لشاشة الـ OTP
        codeSent: (String verificationId, int? resendToken) {
          emit(OtpSentSuccess(verificationId: verificationId));
        },

        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      emit(AuthError(errorMessage: e.toString()));
    }
  }

  // دالة تسجيل الدخول بجوجل
  // دالة تسجيل الدخول بجوجل المحدثة
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      // 1. فتح شاشة اختيار حساب جوجل
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: <String>['email']);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // لو اليوزر داس "رجوع" ومختارش إيميل
      if (googleUser == null) {
        emit(const AuthError(errorMessage: 'تم إلغاء تسجيل الدخول'));
        return;
      }

      // 2. استخراج بيانات المصادقة من جوجل
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. تجهيز الـ Credential (النسخة المتوافقة مع أحدث تحديث)
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // accessToken مش مطلوب في التحديثات الجديدة للـ Auth
      );

      // 4. تسجيل الدخول الفعلي في فايربيز
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 5. إرسال حالة النجاح النهائي
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
