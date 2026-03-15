import 'package:flutter/material.dart';
import 'package:stepforward/core/helper_functions/extentions.dart';
import 'package:stepforward/core/services/get_it_service.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:stepforward/features/home/domain/repos/home_repo.dart';
import 'package:stepforward/features/home/presentation/views/game_details.dart';

/// Shown when the app is opened via a deep link like `stepforward://game/{id}`.
/// Fetches the [GameModel] by [gameId] and then pushes [GameDetails].
class GameDetailsByIdView extends StatefulWidget {
  final String gameId;

  const GameDetailsByIdView({super.key, required this.gameId});

  @override
  State<GameDetailsByIdView> createState() => _GameDetailsByIdViewState();
}

class _GameDetailsByIdViewState extends State<GameDetailsByIdView> {
  GameModel? _game;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchGame();
  }

  Future<void> _fetchGame() async {
    final result = await getIt.get<HomeRepo>().getGameById(widget.gameId);
    result.fold(
      (failure) {
        if (mounted) setState(() => _error = failure.message);
      },
      (game) {
        if (mounted) setState(() => _game = game);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = context.isEn;

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(isEn ? 'Game not found' : 'اللعبة غير موجودة'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  if (Navigator.canPop(context)) context.pop();
                },
                child: Text(isEn ? 'Go Back' : 'رجوع'),
              ),
            ],
          ),
        ),
      );
    }

    if (_game == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              if (Navigator.canPop(context)) context.pop();
            },
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return GameDetails(game: _game!);
  }
}
