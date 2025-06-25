part of 'sign_up_cubit.dart';

@immutable
sealed class SignUpState {}

final class SignUpInitialState extends SignUpState {}

final class SignUpLoadingState extends SignUpState {}
final class SignUpSuccessState extends SignUpState {
  final UserModel userModel;
  SignUpSuccessState({required this.userModel});
}
final class SignUpFailureState extends SignUpState {
  final String errorMessage;
  SignUpFailureState({required this.errorMessage});
}
final class SingUpChangePasswordVisibility extends SignUpState {}
