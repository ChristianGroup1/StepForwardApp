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

      updatedHistory = history.copyWith(id: docRef.id);
    } catch (_) {
      updatedHistory = history.copyWith(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    final cachedHistory = getCachedHistory()
      ..removeWhere((item) => item.id == updatedHistory.id)
      ..insert(0, updatedHistory);
    await _cacheHistory(cachedHistory);
    await _runTeamSync(
      () => teamWorkspaceService.addHistoryToCurrentTeam(updatedHistory),
    );
  }

  Future<void> deleteHistory(String historyId) async {
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
}

final serviceHistoryService = ServiceHistoryService();
