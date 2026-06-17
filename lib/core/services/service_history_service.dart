import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/services/team_workspace_service.dart';
import 'package:stepforward/core/utils/backend_endpoints.dart';
import 'package:stepforward/core/utils/chache_helper_keys.dart';
import 'package:stepforward/features/home/domain/models/service_history_model.dart';

class ServiceHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ServiceHistoryModel>> getHistory() async {
    try {
      final userId = getUserData().id;
      final snapshot = await _firestore
          .collection(BackendEndpoints.getUserData)
          .doc(userId)
          .collection('serviceHistory')
          .orderBy('date', descending: true)
          .get();

      final history = snapshot.docs
          .map(
            (doc) =>
                ServiceHistoryModel.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();
      final localOnlyHistory = getCachedHistory().where(
        (item) => item.id.startsWith('local_'),
      );
      for (final item in localOnlyHistory) {
        if (!history.any((historyItem) => historyItem.id == item.id)) {
          history.add(item);
        }
      }
      history.sort((a, b) => b.date.compareTo(a.date));

      await _cacheHistory(history);
      return history;
    } catch (_) {
      return getCachedHistory();
    }
  }

  List<ServiceHistoryModel> getCachedHistory() {
    final cachedData = CacheHelper.getData(key: kServiceHistoryKey);
    if (cachedData is! String || cachedData.isEmpty) return [];

    try {
      final decoded = jsonDecode(cachedData);
      if (decoded is! List) return [];

      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                ServiceHistoryModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      return [];
    }
  }

  Future<void> addHistory(ServiceHistoryModel history) async {
    ServiceHistoryModel updatedHistory;

    try {
      final userId = getUserData().id;
      final docRef = await _firestore
          .collection(BackendEndpoints.getUserData)
          .doc(userId)
          .collection('serviceHistory')
          .add(history.toFirestore());

      updatedHistory = history.copyWith(id: docRef.id, syncId: docRef.id);
    } catch (_) {
      final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      updatedHistory = history.copyWith(id: localId, syncId: localId);
    }

    final cachedHistory = getCachedHistory()
      ..removeWhere((item) => item.id == updatedHistory.id)
      ..insert(0, updatedHistory);
    await _cacheHistory(cachedHistory);
    await _runTeamSync(
      () => teamWorkspaceService.addHistoryToCurrentTeam(updatedHistory),
    );
  }

  Future<void> updateHistory(
    ServiceHistoryModel history, {
    ServiceHistoryModel? previousHistory,
    bool syncTeam = true,
  }) async {
    final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final updatedHistory = history.id.isEmpty
        ? history.copyWith(id: localId, syncId: localId)
        : history.copyWith(
            syncId: history.syncId.isEmpty ? history.id : history.syncId,
          );

    try {
      final userId = getUserData().id;
      await _firestore
          .collection(BackendEndpoints.getUserData)
          .doc(userId)
          .collection('serviceHistory')
          .doc(updatedHistory.id)
          .set(updatedHistory.toFirestore(), SetOptions(merge: true));
    } catch (_) {}

    final cachedHistory = getCachedHistory()
      ..removeWhere((item) => item.id == updatedHistory.id)
      ..insert(0, updatedHistory);
    cachedHistory.sort((a, b) => b.date.compareTo(a.date));
    await _cacheHistory(cachedHistory);

    if (syncTeam) {
      await _runTeamSync(
        () => teamWorkspaceService.replaceHistoryInCurrentTeam(
          history: updatedHistory,
          previousHistory: previousHistory,
        ),
      );
    }
  }

  Future<void> deleteHistory(
    String historyId, {
    ServiceHistoryModel? history,
    bool syncTeam = true,
  }) async {
    final historyToDelete =
        history ?? _findHistoryById(getCachedHistory(), historyId);

    try {
      final userId = getUserData().id;
      await _firestore
          .collection(BackendEndpoints.getUserData)
          .doc(userId)
          .collection('serviceHistory')
          .doc(historyId)
          .delete();
    } catch (_) {}

    final cachedHistory = getCachedHistory()
      ..removeWhere((item) => item.id == historyId);
    await _cacheHistory(cachedHistory);

    if (syncTeam && historyToDelete != null) {
      await _runTeamSync(
        () =>
            teamWorkspaceService.deleteHistoryFromCurrentTeam(historyToDelete),
      );
    }
  }

  Future<void> updateSyncedHistoryFromTeam({
    required ServiceHistoryModel history,
    ServiceHistoryModel? previousHistory,
  }) async {
    final cachedHistory = getCachedHistory();
    final matchingHistory = _findSyncedHistory(
      cachedHistory,
      previousHistory ?? history,
    );
    if (matchingHistory == null) return;

    await updateHistory(
      history.copyWith(
        id: matchingHistory.id,
        syncId: matchingHistory.syncId,
        createdAt: matchingHistory.createdAt,
      ),
      previousHistory: matchingHistory,
      syncTeam: false,
    );
  }

  Future<void> deleteSyncedHistoryFromTeam(ServiceHistoryModel history) async {
    final matchingHistory = _findSyncedHistory(getCachedHistory(), history);
    if (matchingHistory == null) return;
    await deleteHistory(
      matchingHistory.id,
      history: matchingHistory,
      syncTeam: false,
    );
  }

  Future<void> _cacheHistory(List<ServiceHistoryModel> history) async {
    await CacheHelper.saveData(
      key: kServiceHistoryKey,
      value: jsonEncode(history.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> _runTeamSync(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {}
  }

  ServiceHistoryModel? _findSyncedHistory(
    List<ServiceHistoryModel> history,
    ServiceHistoryModel target,
  ) {
    for (final item in history) {
      if (item.id == target.id ||
          item.id == target.syncId ||
          item.syncId == target.id ||
          item.syncId == target.syncId ||
          _historySignature(item) == _historySignature(target)) {
        return item;
      }
    }
    return null;
  }

  ServiceHistoryModel? _findHistoryById(
    List<ServiceHistoryModel> history,
    String historyId,
  ) {
    for (final item in history) {
      if (item.id == historyId) return item;
    }
    return null;
  }

  String _historySignature(ServiceHistoryModel history) {
    final games = [...history.games]
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return [
      history.title,
      history.place,
      history.ageGroup,
      '${history.date.year}-${history.date.month}-${history.date.day}',
      ...games,
    ].map((value) => value.trim().toLowerCase()).join('|');
  }
}

final serviceHistoryService = ServiceHistoryService();
