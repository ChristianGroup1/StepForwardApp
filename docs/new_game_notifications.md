# New Game Notifications

The app subscribes every device to the Firebase Cloud Messaging topic:

```text
new_games
```

Send a notification to this topic when a new game is published.

Required data payload:

```json
{
  "gameId": "ق"
}
```

Example notification payload:

```json
{
  "topic": "new_games",
  "notification": {
    "title": "لعبة جديدة على Step Forward",
    "body": "اضغط لفتح اللعبة الجديدة"
  },
  "data": {
    "gameId": "FIRESTORE_GAME_DOCUMENT_ID"
  }
}
```

When the user taps the notification, the app opens the matching game details screen.

## Game target fields

For better filtering, keep the long spiritual goal in `target`, and add a short
filter key in `targetKey`.

Example:

```json
{
  "targetKey": "الصلاة",
  "target": "تعليم الأولاد أهمية الصلاة والثقة في ربنا وقت الضيق"
}
```

The app uses `targetKey` for filters/search/similar games, and still displays
the full `target` text in the game details screen. If `targetKey` is missing,
the app falls back to `target` so old game documents keep working.
