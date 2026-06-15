import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stepforward/core/errors/failures.dart';
import 'package:stepforward/features/auth/domain/repos/auth_repo.dart';
import 'package:stepforward/features/home/data/games_cubit/games_cubit.dart';
import 'package:stepforward/features/home/domain/models/book_model.dart';
import 'package:stepforward/features/home/domain/models/brothers_model.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:stepforward/features/home/domain/repos/home_repo.dart';

void main() {
  test('GameModel reads goalTag from string or list', () {
    final stringGoalTag = GameModel.fromJson({'goalTag': 'faith'});
    final listGoalTag = GameModel.fromJson({
      'goalTag': ['faith', 'team work'],
    });
    final hiddenGame = GameModel.fromJson({'isVisible': 'false'});
    final visibleGame = GameModel.fromJson({'isVisible': '1'});

    expect(stringGoalTag.goalTags, ['faith']);
    expect(listGoalTag.goalTags, ['faith', 'team work']);
    expect(hiddenGame.isVisible, isFalse);
    expect(visibleGame.isVisible, isTrue);
  });

  test('GamesCubit sorts newest games first and searches by target', () async {
    final games = [
      _game(
        id: 'old',
        target: 'A long explanation about team work',
        goalTag: 'team work',
        tags: const ['Children'],
        createdAt: DateTime(2024, 1, 1),
      ),
      _game(
        id: 'new',
        target: 'A long explanation about prayer and faith',
        goalTag: 'faith',
        tags: const ['University'],
        createdAt: DateTime(2024, 2, 1),
      ),
      _game(
        id: 'middle',
        target: 'A long explanation about faith',
        goalTag: 'faith',
        tags: const ['Children'],
        createdAt: DateTime(2024, 1, 15),
      ),
      _game(
        id: 'hidden',
        target: 'A hidden faith game',
        goalTag: 'faith',
        tags: const ['Children'],
        createdAt: DateTime(2024, 3, 1),
        isVisible: false,
      ),
    ];
    final homeRepo = _FakeHomeRepo(games);
    final cubit = GamesCubit(homeRepo, _FakeAuthRepo());

    await cubit.getGames();

    final loadedState = cubit.state as GetGamesSuccessState;
    expect(loadedState.games.map((game) => game.id), ['new', 'middle', 'old']);
    expect(cubit.isNewestGame(loadedState.games.first), isTrue);

    cubit.searchController.text = 'faith';
    cubit.searchGames();

    final searchState = cubit.state as GetGamesSuccessState;
    expect(searchState.games.map((game) => game.id), ['new', 'middle']);
    expect(homeRepo.searchCallCount, 0);

    cubit.toggleTag('Children');
    cubit.selectTarget('faith');

    final combinedFilterState = cubit.state as GetGamesSuccessState;
    expect(combinedFilterState.games.map((game) => game.id), ['middle']);

    await cubit.close();
  });
}

GameModel _game({
  required String id,
  required String target,
  required String goalTag,
  required List<String> tags,
  required DateTime createdAt,
  bool isVisible = true,
}) {
  return GameModel(
    coverUrl: '',
    name: id,
    id: id,
    explanation: '',
    isVisible: isVisible,
    laws: '',
    tags: tags,
    target: target,
    goalTag: goalTag,
    tools: '',
    videoLink: '',
    createdAt: createdAt,
  );
}

class _FakeHomeRepo implements HomeRepo {
  _FakeHomeRepo(this.games);

  final List<GameModel> games;
  int searchCallCount = 0;

  @override
  Future<Either<Failure, List<GameModel>>> getGames() async => right(games);

  @override
  Future<Either<Failure, List<String>>> getUserFavoritesIDs() async =>
      right([]);

  @override
  Future<Either<Failure, List<GameModel>>> searchGames(
    String searchText,
  ) async {
    searchCallCount++;
    return right([]);
  }

  @override
  Future<Either<Failure, void>> changeGameFavoriteState({
    required String gameId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<BookModel>>> getBooks() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<BrothersModel>>> getBrothers() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, GameModel>> getGameById(String gameId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<GameModel>>> getUserFavorites({
    required String userId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> removeGameFromFavorites({
    required String gameId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<BrothersModel>>> searchBrothers(
    String searchText,
  ) {
    throw UnimplementedError();
  }
}

class _FakeAuthRepo implements AuthRepo {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
