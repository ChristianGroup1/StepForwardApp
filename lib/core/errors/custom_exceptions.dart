import 'package:firebase_auth/firebase_auth.dart';

class CustomException implements Exception {
  final String message;

  CustomException({required this.message});

  @override
  String toString() {
    return message;
  }
}

String mapException(FirebaseAuthException e) {
  switch (e.code) {
    // Email and Password-specific errors
    case 'weak-password':
      return 'كلمة المرور ضعيفة';
    case 'email-already-in-use':
      return 'هذا البريد مستخدم من قبل';
    case 'user-not-found':
      return 'هذا البريد غير موجود';
    case 'wrong-password':
      return 'كلمة المرور غير صحيحة';
    case 'invalid-credential':
      return 'تأكد من صحة بياناتك';
    case 'invalid-email':
      return 'البريد غير صالح';
    case 'operation-not-allowed':
      return 'لم يتم تفعيل حسابك';
    case 'user-disabled':
      return 'تم تعطيل حسابك';
    case 'network-request-failed':
      return 'تأكد من الاتصال بالانترنت';

    // Google-specific errors
    case 'account-exists-with-different-credential':
      return 'هذا الحساب مرتبط بمزود مختلف. حاول تسجيل الدخول باستخدام طريقة أخرى';
    case 'invalid-verification-code':
      return 'رمز التحقق غير صالح';
    case 'invalid-verification-id':
      return 'معرّف التحقق غير صالح';
    case 'credential-already-in-use':
      return 'بيانات الاعتماد هذه مستخدمة بالفعل من قبل حساب مختلف';
    case 'timeout':
      return 'العملية استغرقت وقتًا طويلاً. حاول مرة أخرى';
    case 'popup-closed-by-user':
      return 'تم إغلاق نافذة تسجيل الدخول قبل إتمام العملية';
    case 'quota-exceeded':
      return 'تم تجاوز الحد الأقصى للطلبات. حاول لاحقًا';
    case 'sign-in-canceled':
      return 'تم إلغاء تسجيل الدخول';

    // Facebook-specific errors
    case 'access-denied':
      return 'تم رفض الوصول إلى حسابك على فيسبوك. تأكد من الصلاحيات الممنوحة';
    case 'invalid-access-token':
      return 'رمز الوصول إلى فيسبوك غير صالح أو منتهي الصلاحية';
    case 'facebook-login-failed':
      return 'فشل تسجيل الدخول إلى فيسبوك. حاول مرة أخرى';
    case 'cancelled':
      return 'تم إلغاء تسجيل الدخول إلى فيسبوك';
      
    default:
      return 'حدث خطاء ما، حاول مرة اخرى';
  }
}
   