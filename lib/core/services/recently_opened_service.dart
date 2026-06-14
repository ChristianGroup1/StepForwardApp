import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/utils/chache_helper_keys.dart';
import 'package:stepforward/features/home/domain/models/book_model.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';

enum RecentlyOpenedItemType { game, book }

class RecentlyOpenedItem {
  const RecentlyOpenedItem({
    required this.id,
    required this.type,
    required this.name,
    required this.coverUrl,
    required this.openedAt,
    this.game,
    this.bookUrl,
  });

  final String id;
  final RecentlyOpenedItemType type;
  final String name;
  final String coverUrl;
  final DateTime openedAt;
  final GameModel? game;
  final String? bookUrl;

  factory RecentlyOpenedItem.game(GameModel game) {
    return RecentlyOpenedItem(
      id: game.id,
      type: RecentlyOpenedItemType.game,
      name: game.name,
      coverUrl: game.coverUrl,
      openedAt: DateTime.now(),
      game: game,
    );
  }

  factory RecentlyOpenedItem.book(BookModel book) {
    return RecentlyOpenedItem(
      id: book.id.isNotEmpty ? book.id : book.url,
      type: RecentlyOpenedItemType.book,
      name: book.name,
      coverUrl: book.coverUrl ?? '',
      openedAt: DateTime.now(),
      bookUrl: book.url,
    );
  }

  factory RecentlyOpenedItem.fromJson(Map<String, dynamic> json) {
    final typeName = json['type']?.toString() ?? '';
    final type = typeName == RecentlyOpenedItemType.book.name
        ? RecentlyOpenedItemType.book
        : RecentlyOpenedItemType.game;

    return RecentlyOpenedItem(
      id: json['id'] ?? '',
      type: type,
      name: json['name'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
      openedAt: DateTime.tryParse(json['openedAt'] ?? '') ?? DateTime.now(),
      game: json['game'] is Map
          ? GameModel.fromJson(Map<String, dynamic>.from(json['game']))
          : null,
      bookUrl: json['bookUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'coverUrl': coverUrl,
      'openedAt': openedAt.toIso8601String(),
      'game': game?.toJson(),
      'bookUrl': bookUrl,
    };
  }
}

class RecentlyOpenedService {
  static const _maxItems = 10;

  final ValueNotifier<List<RecentlyOpenedItem>> itemsNotifier = ValueNotifier(
    [],
  );

  void refresh() {
    itemsNotifier.value = getItems();
  }

  List<RecentlyOpenedItem> getItems() {
    final cachedData = CacheHelper.getData(key: kRecentlyOpenedItemsKey);
    if (cachedData is! String || cachedData.isEmpty) return [];

    try {
      final decoded = jsonDecode(cachedData);
      if (decoded is! List) return [];

      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                RecentlyOpenedItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList()
        ..sort((a, b) => b.openedAt.compareTo(a.openedAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> addGame(GameModel game) {
    return _addItem(RecentlyOpenedItem.game(game));
  }

  Future<void> addBook(BookModel book) {
    return _addItem(RecentlyOpenedItem.book(book));
  }

  Future<void> _addItem(RecentlyOpenedItem item) async {
    final items = getItems()
      ..removeWhere(
        (cached) => cached.type == item.type && cached.id == item.id,
      )
      ..insert(0, item);

    final limitedItems = items.take(_maxItems).toList();
    await CacheHelper.saveData(
      key: kRecentlyOpenedItemsKey,
      value: jsonEncode(limitedItems.map((item) => item.toJson()).toList()),
    );
    itemsNotifier.value = limitedItems;
  }
}

final recentlyOpenedService = RecentlyOpenedService();
