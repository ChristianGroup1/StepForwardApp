import 'package:stepforward/features/home/domain/models/game_model.dart';

GameModel getDummyGames() {
  return GameModel(
    coverUrl: 'https://img.freepik.com/free-vector/man-shows-gesture-great-idea_10045-637.jpg?t=st=1746547552~exp=1746551152~hmac=5e83ad2d2dcd1105ec90c4a9d3abc20e401cc12b4e14dc5b2e1b523583807bf3&w=826',
    name: 'لعبة القراءة',
    id: '123456',
    explanation: 'On a quiet morning, the sun rose gently to the sound of birds singing. Golden rays danced on the windows, announcing a new day filled with hope. I stepped onto the balcony, breathed in the fresh air, sipped my coffee slowly, and dreamed of better days, wishing for something beautiful to begin.',
    isVisible: true,
    laws: 'laws',
    tags: ['اطفال ', ' كبار'],
    target: 'target',
    tools: 'tools',
    videoLink: 'videoLink',
  );
}
