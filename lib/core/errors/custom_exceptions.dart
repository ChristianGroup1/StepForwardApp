import 'package:firebase_auth/firebase_auth.dart';

class CustomException implements Exception {
  final String message;

  CustomException({required this.message});

  @override
  String toString() {
    return message;
  }
}

String mapException(FirebaseAuthException e, {bool isEn = false}) {
  switch (e.code) {
    // Email and Password-specific errors
    case 'weak-password':
      return isEn ? 'Password is too weak' : 'كلمة المرور ضعيفة';
    case 'email-already-in-use':
      return isEn ? 'This email is already in use' : 'هذا البريد مستخدم من قبل';
    case 'user-not-found':
      return isEn ? 'This email does not exist' : 'هذا البريد غير موجود';
    case 'wrong-password':
      return isEn ? 'Incorrect password' : 'كلمة المرور غير صحيحة';
    case 'invalid-credential':
      return isEn ? 'Please check your credentials' : 'تأكد من صحة بياناتك';
    case 'invalid-email':
      return isEn ? 'Invalid email address' : 'البريد غير صالح';
    case 'operation-not-allowed':
      return isEn ? 'Your account is not activated' : 'لم يتم تفعيل حسابك';
    case 'user-disabled':
      return isEn ? 'Your account has been disabled' : 'تم تعطيل حسابك';
    case 'network-request-failed':
      return isEn ? 'Check your internet connection' : 'تأكد من الاتصال بالانترنت';

    // Google-specific errors
    case 'account-exists-with-different-credential':
      return isEn
          ? 'This account is linked to a different provider. Try signing in with another method'
          : 'هذا الحساب مرتبط بمزود مختلف. حاول تسجيل الدخول باستخدام طريقة أخرى';
    case 'invalid-verification-code':
      return isEn ? 'Invalid verification code' : 'رمز التحقق غير صالح';
    case 'invalid-verification-id':
      return isEn ? 'Invalid verification ID' : 'معرّف التحقق غير صالح';
    case 'credential-already-in-use':
      return isEn
          ? 'These credentials are already used by a different account'
          : 'بيانات الاعتماد هذه مستخدمة بالفعل من قبل حساب مختلف';
    case 'timeout':
      return isEn ? 'The operation timed out. Please try again' : 'العملية استغرقت وقتًا طويلاً. حاول مرة أخرى';
    case 'popup-closed-by-user':
      return isEn ? 'Sign-in window was closed before completing' : 'تم إغلاق نافذة تسجيل الدخول قبل إتمام العملية';
    case 'quota-exceeded':
      return isEn ? 'Request limit exceeded. Try again later' : 'تم تجاوز الحد الأقصى للطلبات. حاول لاحقًا';
    case 'sign-in-canceled':
      return isEn ? 'Sign-in was cancelled' : 'تم إلغاء تسجيل الدخول';

    // Facebook-specific errors
    case 'access-denied':
      return isEn
          ? 'Access to your Facebook account was denied. Check the granted permissions'
          : 'تم رفض الوصول إلى حسابك على فيسبوك. تأكد من الصلاحيات الممنوحة';
    case 'invalid-access-token':
      return isEn ? 'Facebook access token is invalid or expired' : 'رمز الوصول إلى فيسبوك غير صالح أو منتهي الصلاحية';
    case 'facebook-login-failed':
      return isEn ? 'Facebook login failed. Please try again' : 'فشل تسجيل الدخول إلى فيسبوك. حاول مرة أخرى';
    case 'cancelled':
      return isEn ? 'Facebook login was cancelled' : 'تم إلغاء تسجيل الدخول إلى فيسبوك';

    default:
      return isEn ? 'Something went wrong, please try again' : 'حدث خطاء ما، حاول مرة اخرى';
  }
}