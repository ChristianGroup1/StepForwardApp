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