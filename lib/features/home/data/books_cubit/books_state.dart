part of 'books_cubit.dart';

@immutable
sealed class BooksState {}

final class BooksInitial extends BooksState {}

final class GetBooksLoadingState extends BooksState {}

final class GetBooksSuccessState extends BooksState {
  final List<BookModel> books;
  GetBooksSuccessState({required this.books});
}

final class GetBooksFailureState extends BooksState {
  final String errorMessage;
  GetBooksFailureState({required this.errorMessage});
}
