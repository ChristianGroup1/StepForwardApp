part of 'more_cubit.dart';

@immutable
sealed class MoreState {}

final class MoreInitial extends MoreState {}
final class UserMakeChangesInProfile extends MoreState {}

final class UpdateUserProfileLoadingState extends MoreState {}
final class UpdateUserProfileFailureState extends MoreState {
  final String errorMessage;
  UpdateUserProfileFailureState({required this.errorMessage});
}
final class UpdateUserProfileSuccessState extends MoreState {}

final class DeleteAccountFailureState extends MoreState {
  final String errorMessage;
  DeleteAccountFailureState({required this.errorMessage});
}
final class DeleteAccountSuccessState extends MoreState {}
