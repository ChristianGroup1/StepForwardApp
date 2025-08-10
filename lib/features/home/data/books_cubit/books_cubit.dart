import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:stepforward/features/home/domain/models/book_model.dart';
import 'package:stepforward/features/home/domain/repos/home_repo.dart';
part 'books_state.dart';

class BooksCubit extends Cubit<BooksState> {
  final HomeRepo homeRepo;
  BooksCubit(this.homeRepo) : super(BooksInitial());

  Future<void> fetchBooks() async {
    emit(GetBooksLoadingState());

    final result = await homeRepo.getBooks();
    result.fold(
      (failure) => emit(GetBooksFailureState(errorMessage: failure.message)),
      (books) => emit(GetBooksSuccessState(books: books)),
    );
  }
}
