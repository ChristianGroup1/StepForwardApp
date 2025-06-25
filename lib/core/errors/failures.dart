abstract class Failure{
  final String message;

  Failure({required this.message});
 
}
class CustomFailure extends Failure{
  CustomFailure({required super.message});
}