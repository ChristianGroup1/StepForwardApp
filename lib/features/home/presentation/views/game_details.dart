import 'package:flutter/material.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:stepforward/features/home/presentation/views/widgets/game_details_view_body.dart';

class GameDetails extends StatelessWidget {
final GameModel game;
  const GameDetails({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: GameDetailsViewBody(
        game: game,
      ),
    );
  }
}
