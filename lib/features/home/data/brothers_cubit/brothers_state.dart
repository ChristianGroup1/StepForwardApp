part of 'brothers_cubit.dart';

@immutable
sealed class BrothersState {}

final class BrothersInitialState extends BrothersState {}

class GetBrothersLoadingState extends BrothersState {}

class GetBrothersSuccessState extends BrothersState {
  final List<BrothersModel> brothers;
  GetBrothersSuccessState({required this.brothers});
}

class GetBrothersFailureState extends BrothersState {
  final String errorMessage;
  GetBrothersFailureState({required this.errorMessage});
}

class CheckUserEmailVerification extends BrothersState {
  final bool isVerified;
  CheckUserEmailVerification({this.isVerified = false});
}

  
  
class AddUserIdsFailureState extends BrothersState {
  final String errorMessage;
  AddUserIdsFailureState({required this.errorMessage});
}

class AddUserIdsSuccessState extends BrothersState {}
class AddUserIdsLoadingState extends BrothersState {}

