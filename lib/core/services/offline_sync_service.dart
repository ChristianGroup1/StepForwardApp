import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/utils/chache_helper_keys.dart';

class OfflineSyncService {
  Timer? _retryTimer;
  bool _isSyncing = false;

  void start() {
    _retryTimer?.cancel();
    unawaited(syncPendingWrites());
    _retryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      unawaited(syncPendingWrites());
    });
  }

  void dispose() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  Future<void> queueSet({
    required String documentPath,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    await _appendWrite(
      _PendingFirestoreWrite(
        id: _newId(),
        type: _PendingWriteType.set,
        documentPath: documentPath,
        data: _encodeData(data),
        merge: merge,
      ),
    );
  }

  Future<void> queueDelete({required String documentPath}) async {
    await _appendWrite(
      _PendingFirestoreWrite(
        id: _newId(),
        type: _PendingWriteType.delete,
        documentPath: documentPath,
      ),
    );
  }

  Future<void> queueRating({
    required String gameId,
    required String userId,
    required int rating,
  }) async {
    await _appendWrite(
      _PendingFirestoreWrite(
        id: _newId(),
        type: _PendingWriteType.rating,
        documentPath: 'games/$gameId/ratings/$userId',
        data: {
          'gameId': gameId,
          'userId': userId,
          'rating': rating.clamp(1, 5),
        },
      ),
    );
  }

  Future<void> syncPendingWrites() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final writes = _readWrites();
      if (writes.isEmpty) return;

      final remaining = <_PendingFirestoreWrite>[];
      for (final write in writes) {
        try {
          await _applyWrite(write);
        } catch (error) {
          debugPrint('Offline sync failed for ${write.documentPath}: $error');
          remaining.add(write);
        }
      }

      await _saveWrites(remaining);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _applyWrite(_PendingFirestoreWrite write) async {
    final doc = FirebaseFirestore.instance.doc(write.documentPath);
    switch (write.type) {
      case _PendingWriteType.set:
        await doc.set(_decodeData(write.data), SetOptions(merge: write.merge));
        return;
      case _PendingWriteType.delete:
        await doc.delete();
        return;
      case _PendingWriteType.rating:
        await _applyRatingWrite(write);
        return;
    }
  }

  Future<void> _applyRatingWrite(_PendingFirestoreWrite write) async {
    final gameId = write.data['gameId']?.toString() ?? '';
    final userId = write.data['userId']?.toString() ?? '';
    final rating = _parseInt(write.data['rating']).clamp(1, 5);
    if (gameId.isEmpty || userId.isEmpty) return;

    final firestore = FirebaseFirestore.instance;
    final gameRef = firestore.collection('games').doc(gameId);
    final ratingRef = gameRef.collection('ratings').doc(userId);

    await firestore.runTransaction((transaction) async {
      final ratingSnapshot = await transaction.get(ratingRef);
      final gameSnapshot = await transaction.get(gameRef);

      final previousRating = ratingSnapshot.exists
          ? _parseInt(ratingSnapshot.data()?['rating']).clamp(0, 5)
          : 0;
      final gameData = gameSnapshot.data() ?? {};
      final currentSum = _parseInt(gameData['ratingSum']);
      final currentCount = _parseInt(gameData['ratingCount']);
      final nextSum = currentSum - previousRating + rating;
      final nextCount = previousRating == 0 ? currentCount + 1 : currentCount;

      transaction.set(ratingRef, {
        'rating': rating,
        'userId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(gameRef, {
        'ratingSum': nextSum,
        'ratingCount': nextCount,
        'ratingAverage': nextCount == 0 ? 0 : nextSum / nextCount,
      }, SetOptions(merge: true));
    });
  }

  Future<void> _appendWrite(_PendingFirestoreWrite write) async {
    final writes = _readWrites()
      ..removeWhere((item) {
        return item.documentPath == write.documentPath &&
            item.type == write.type;
      })
      ..add(write);
    await _saveWrites(writes);
  }

  List<_PendingFirestoreWrite> _readWrites() {
    final cachedData = CacheHelper.getData(key: kPendingFirestoreWritesKey);
    if (cachedData is! String || cachedData.isEmpty) return [];

    try {
      final decoded = jsonDecode(cachedData);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map(
            (item) => _PendingFirestoreWrite.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveWrites(List<_PendingFirestoreWrite> writes) async {
    await CacheHelper.saveData(
      key: kPendingFirestoreWritesKey,
      value: jsonEncode(writes.map((write) => write.toJson()).toList()),
    );
  }

  Map<String, dynamic> _encodeData(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, _encodeValue(value)));
  }

  dynamic _encodeValue(dynamic value) {
    if (value is Timestamp) {
      return {
        '__type': 'timestamp',
        'milliseconds': value.millisecondsSinceEpoch,
      };
    }
    if (value is DateTime) {
      return {
        '__type': 'timestamp',
        'milliseconds': value.millisecondsSinceEpoch,
      };
    }
    if (value is List) return value.map(_encodeValue).toList();
    if (value is Map) {
      return value.map(
        (key, value) => MapEntry(key.toString(), _encodeValue(value)),
      );
    }
    return value;
  }

  Map<String, dynamic> _decodeData(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, _decodeValue(value)));
  }

  dynamic _decodeValue(dynamic value) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      if (map['__type'] == 'timestamp') {
        return Timestamp.fromMillisecondsSinceEpoch(
          (map['milliseconds'] as num).toInt(),
        );
      }
      return map.map((key, value) => MapEntry(key, _decodeValue(value)));
    }
    if (value is List) return value.map(_decodeValue).toList();
    return value;
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _PendingFirestoreWrite {
  const _PendingFirestoreWrite({
    required this.id,
    required this.type,
    required this.documentPath,
    this.data = const {},
    this.merge = true,
  });

  final String id;
  final _PendingWriteType type;
  final String documentPath;
  final Map<String, dynamic> data;
  final bool merge;

  factory _PendingFirestoreWrite.fromJson(Map<String, dynamic> json) {
    return _PendingFirestoreWrite(
      id: json['id']?.toString() ?? '',
      type: _PendingWriteType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => _PendingWriteType.set,
      ),
      documentPath: json['documentPath']?.toString() ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? const {}),
      merge: json['merge'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'documentPath': documentPath,
      'data': data,
      'merge': merge,
    };
  }
}

enum _PendingWriteType { set, delete, rating }

final offlineSyncService = OfflineSyncService();
