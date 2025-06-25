part of 'login_cubit.dart';

@immutable
sealed class LoginState {}

final class LoginInitialState extends LoginState {}

final class LoginLoadingState extends LoginState {}
final class LoginSuccessState extends LoginState {
  final UserModel userModel;
  LoginSuccessState({required this.userModel}); 
}
final class LoginFailureState extends LoginState {
  final String errorMessage;
  LoginFailureState({required this.errorMessage});
}

final class SingUpChangePasswordVisibility extends LoginState {}
final class SendEmailToResetPasswordSuccessState extends LoginState {}


final class SendEmailToResetPasswordFailureState extends LoginState {
  final String errMessage;

  SendEmailToResetPasswordFailureState({required this.errMessage});
}
class SendEmailToResetPasswordTimerState extends LoginState {
  final int seconds;
  SendEmailToResetPasswordTimerState(this.seconds);
}