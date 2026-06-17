import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/services/offline_sync_service.dart';
import 'package:stepforward/core/utils/backend_endpoints.dart';
import 'package:stepforward/core/utils/chache_helper_keys.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:stepforward/features/home/domain/models/service_history_model.dart';
import 'package:stepforward/features/home/domain/models/team_game_model.dart';
import 'package:stepforward/features/home/domain/models/team_workspace_model.dart';

class TeamWorkspaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Random _random = Random.secure();

  CollectionReference<Map<String, dynamic>> get _teams =>
      _firestore.collection('teams');
  CollectionReference<Map<String, dynamic>> get _teamGames =>
      _firestore.collection('teamGames');

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<TeamWorkspaceModel?> getMyTeam() async {
    final userId = _currentUserId;
    if (userId == null) return getCachedTeam();
    final cachedTeam = getCachedTeam();
    if (cachedTeam != null && cachedTeam.members.contains(userId)) {
      return cachedTeam;
    }

    try {
      final snapshot = await _teams
          .where('members', arrayContains: userId)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        await CacheHelper.removeData(key: kTeamWorkspaceKey);
        return null;
      }

      final doc = snapshot.docs.first;
      final team = TeamWorkspaceModel.fromJson({...doc.data(), 'id': doc.id});
      await _cacheTeam(team);
      return team;
    } catch (_) {
      return getCachedTeam();
    }
  }

  Future<List<TeamWorkspaceModel>> getMyTeams() async {
    final userId = _currentUserId;
    if (userId == null) {
      final cachedTeam = getCachedTeam();
      return cachedTeam == null ? [] : [cachedTeam];
    }

    try {
      final snapshot = await _teams
          .where('members', arrayContains: userId)
          .get();
      final teams =
          snapshot.docs
              .map(
                (doc) =>
                    TeamWorkspaceModel.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (teams.isNotEmpty) {
        final cachedTeam = getCachedTeam();
        final selectedTeam = cachedTeam == null
            ? teams.first
            : teams.firstWhere(
                (team) => team.id == cachedTeam.id,
                orElse: () => teams.first,
              );
        await _cacheTeam(selectedTeam);
      }

      return teams;
    } catch (_) {
      final cachedTeam = getCachedTeam();
      return cachedTeam == null ? [] : [cachedTeam];
    }
  }

  Future<void> setCurrentTeam(TeamWorkspaceModel team) async {
    await _cacheTeam(team);
  }

  Future<TeamWorkspaceModel> createTeam(String name) async {
    final user = getUserData();
    if (_auth.currentUser == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unauthenticated',
        message: 'No authenticated Firebase user found.',
      );
    }

    final inviteCode = await _generateUniqueInviteCode();
    final team = TeamWorkspaceModel(
      id: '',
      name: name.trim(),
      inviteCode: inviteCode,
      ownerId: user.id,
      members: [user.id],
      createdAt: DateTime.now(),
    );

    final docRef = _teams.doc(inviteCode);
    await docRef.set(team.toFirestore());
    final savedTeam = team.copyWith(id: docRef.id);
    await _cacheTeam(savedTeam);
    return savedTeam;
  }

  Future<TeamWorkspaceModel?> joinTeamByInviteCode(String code) async {
    final user = getUserData();
    if (_auth.currentUser == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unauthenticated',
        message: 'No authenticated Firebase user found.',
      );
    }

    final normalizedCode = normalizeInviteCode(code);
    if (normalizedCode.isEmpty) return null;

    final docRef = _teams.doc(normalizedCode);
    await docRef.update({
      'members': FieldValue.arrayUnion([user.id]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return null;

    final data = doc.data()!;
    final members = List<String>.from(data['members'] ?? []);
    if (!members.contains(user.id)) members.add(user.id);
    final team = TeamWorkspaceModel.fromJson({
      ...data,
      'id': doc.id,
      'members': members,
    });
    await _cacheTeam(team);
    return team;
  }

  Future<void> leaveTeam(String teamId) async {
    final user = getUserData();
    await _teams.doc(teamId).update({
      'members': FieldValue.arrayRemove([user.id]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await CacheHelper.removeData(key: kTeamWorkspaceKey);
  }

  Future<void> removeTeamMember({
    required String teamId,
    required String userId,
  }) async {
    await _teams.doc(teamId).update({
      'members': FieldValue.arrayRemove([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (getCachedUserData()?.id == userId) {
      await CacheHelper.removeData(key: kTeamWorkspaceKey);
    }
  }

  Future<bool> isCurrentUserAdmin() async {
    final userId = getCachedUserData()?.id;
    if (userId == null) return false;

    try {
      final doc = await _firestore
          .collection(BackendEndpoints.getUserData)
          .doc(userId)
          .get();
      return doc.data()?['isAdmin'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<List<TeamMemberModel>> getTeamMembers(TeamWorkspaceModel team) async {
    final members = <TeamMemberModel>[];

    for (final userId in team.members) {
      try {
        final doc = await _firestore
            .collection(BackendEndpoints.getUserData)
            .doc(userId)
            .get();
        final data = doc.data();

        members.add(
          TeamMemberModel.fromJson(
            id: userId,
            json: data ?? const <String, dynamic>{},
            isOwner: userId == team.ownerId,
          ),
        );
      } catch (_) {
        members.add(
          TeamMemberModel(id: userId, isOwner: userId == team.ownerId),
        );
      }
    }

    members.sort((a, b) {
      if (a.isOwner != b.isOwner) return a.isOwner ? -1 : 1;
      if (a.isAdmin != b.isAdmin) return a.isAdmin ? -1 : 1;
      return a.displayName.compareTo(b.displayName);
    });

    return members;
  }

  Future<bool> canManageTeam(TeamWorkspaceModel team) async {
    final userId = _currentUserId;
    if (userId == null) return false;
    if (team.ownerId == userId) return true;
    return isCurrentUserAdmin();
  }

  Stream<List<TeamGameModel>> watchTeamGames(TeamWorkspaceModel team) {
    return _teamGames.where('teamId', isEqualTo: team.id).snapshots().map((
      snapshot,
    ) {
      final games =
          snapshot.docs
              .map(
                (doc) => TeamGameModel.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return games;
    });
  }

  Stream<List<TeamGameModel>> watchPublicTeamGames(TeamWorkspaceModel team) {
    return watchTeamGames(team).map(
      (games) =>
          games.where((game) => game.isVisible && game.isPublic).toList(),
    );
  }

  Future<void> addTeamGame({
    required TeamWorkspaceModel team,
    required TeamGameModel game,
  }) async {
    final canManage = await canManageTeam(team);
    if (!canManage) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Only team owner or app admin can manage team games.',
      );
    }

    final docRef = _teamGames.doc();
    await docRef.set(
      game
          .copyWith(
            id: docRef.id,
            teamId: team.id,
            teamName: team.name,
            createdAt: DateTime.now(),
          )
          .toFirestore(),
    );
  }

  Future<void> updateTeamGame({
    required TeamWorkspaceModel team,
    required TeamGameModel game,
  }) async {
    final canManage = await canManageTeam(team);
    if (!canManage) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Only team owner or app admin can manage team games.',
      );
    }

    await _teamGames
        .doc(game.id)
        .set(
          game
              .copyWith(teamName: team.name, updatedAt: DateTime.now())
              .toFirestore(),
          SetOptions(merge: true),
        );
  }

  Future<void> setTeamGameVisibility({
    required TeamWorkspaceModel team,
    required TeamGameModel game,
    required bool isVisible,
  }) async {
    await updateTeamGame(
      team: team,
      game: game.copyWith(isVisible: isVisible),
    );
  }

  Future<void> setTeamGamePublicStatus({
    required TeamWorkspaceModel team,
    required TeamGameModel game,
    required bool isPublic,
  }) async {
    await updateTeamGame(
      team: team,
      game: game.copyWith(isPublic: isPublic),
    );
  }

  Future<void> deleteTeamGame({
    required TeamWorkspaceModel team,
    required TeamGameModel game,
  }) async {
    final canManage = await canManageTeam(team);
    if (!canManage) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Only team owner or app admin can manage team games.',
      );
    }

    await _teamGames.doc(game.id).delete();
  }

  Future<void> saveTeamPreparationGames({
    required String teamId,
    required List<GameModel> games,
  }) async {
    final uniqueGames = _uniqueGamesById(games);
    final data = {
      'games': uniqueGames.map((game) => game.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    try {
      await _teams
          .doc(teamId)
          .collection('shared')
          .doc('preparation')
          .set(data);
    } catch (_) {
      await offlineSyncService.queueSet(
        documentPath: _teamPreparationPath(teamId),
        data: {
          'games': uniqueGames.map((game) => game.toJson()).toList(),
          'updatedAt': DateTime.now(),
        },
      );
    }
  }

  Future<void> addTeamPreparationGame({
    required String teamId,
    required GameModel game,
  }) async {
    final games = await getTeamPreparationGames(teamId);
    games
      ..removeWhere((item) => item.id == game.id)
      ..add(game);

    await saveTeamPreparationGames(teamId: teamId, games: games);
  }

  Future<void> removeTeamPreparationGame({
    required String teamId,
    required String gameId,
  }) async {
    final games = await getTeamPreparationGames(teamId);
    games.removeWhere((game) => game.id == gameId);

    await saveTeamPreparationGames(teamId: teamId, games: games);
  }

  Future<void> addPreparationGameToCurrentTeam(GameModel game) async {
    final team = await _getCurrentTeamForBackgroundSync();
    if (team == null) return;
    await addTeamPreparationGame(teamId: team.id, game: game);
  }

  Future<void> removePreparationGameFromCurrentTeam(String gameId) async {
    final team = await _getCurrentTeamForBackgroundSync();
    if (team == null) return;
    await removeTeamPreparationGame(teamId: team.id, gameId: gameId);
  }

  Future<List<GameModel>> getTeamPreparationGames(String teamId) async {
    final doc = await _teams
        .doc(teamId)
        .collection('shared')
        .doc('preparation')
        .get();
    final data = doc.data();
    if (data == null) return [];

    final games = data['games'];
    if (games is! List) return [];

    return games
        .whereType<Map>()
        .map((item) => GameModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Stream<List<GameModel>> watchTeamPreparationGames(String teamId) {
    return _teams
        .doc(teamId)
        .collection('shared')
        .doc('preparation')
        .snapshots()
        .map((doc) {
          final data = doc.data();
          if (data == null) return <GameModel>[];

          final games = data['games'];
          if (games is! List) return <GameModel>[];

          return games
              .whereType<Map>()
              .map(
                (item) => GameModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        });
  }

  Future<List<ServiceHistoryModel>> getTeamHistory(String teamId) async {
    final snapshot = await _teams
        .doc(teamId)
        .collection('serviceHistory')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => ServiceHistoryModel.fromJson({...doc.data(), 'id': doc.id}),
        )
        .toList();
  }

  Stream<List<ServiceHistoryModel>> watchTeamHistory(String teamId) {
    return _teams
        .doc(teamId)
        .collection('serviceHistory')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    ServiceHistoryModel.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  Future<void> addTeamHistory({
    required String teamId,
    required ServiceHistoryModel history,
  }) async {
    await _requireTeamAccess(teamId);
    final historyId = _teamHistoryDocumentId(history);
    final data = history
        .copyWith(id: historyId, syncId: history.syncId)
        .toFirestore();
    try {
      await _teams
          .doc(teamId)
          .collection('serviceHistory')
          .doc(historyId)
          .set(data);
    } catch (_) {
      await offlineSyncService.queueSet(
        documentPath: _teamHistoryPath(teamId, historyId),
        data: history
            .copyWith(id: historyId, syncId: history.syncId)
            .toFirestore(),
      );
    }
  }

  Future<void> updateTeamHistory({
    required String teamId,
    required ServiceHistoryModel history,
  }) async {
    await _requireTeamAccess(teamId);
    if (history.id.isEmpty) {
      await addTeamHistory(teamId: teamId, history: history);
      return;
    }

    try {
      await _teams
          .doc(teamId)
          .collection('serviceHistory')
          .doc(history.id)
          .set(history.toFirestore(), SetOptions(merge: true));
    } catch (_) {
      await offlineSyncService.queueSet(
        documentPath: _teamHistoryPath(teamId, history.id),
        data: history.toFirestore(),
      );
    }
  }

  Future<void> replaceTeamHistory({
    required String teamId,
    required ServiceHistoryModel history,
    ServiceHistoryModel? previousHistory,
  }) async {
    await _requireTeamAccess(teamId);

    if (previousHistory != null) {
      await _deletePossibleTeamHistoryDocs(
        teamId: teamId,
        history: previousHistory,
      );
    }

    await addTeamHistory(teamId: teamId, history: history);
  }

  Future<void> deleteTeamHistory({
    required String teamId,
    required String historyId,
  }) async {
    await _requireTeamAccess(teamId);
    if (historyId.isEmpty) return;

    try {
      await _teams
          .doc(teamId)
          .collection('serviceHistory')
          .doc(historyId)
          .delete();
    } catch (_) {
      await offlineSyncService.queueDelete(
        documentPath: _teamHistoryPath(teamId, historyId),
      );
    }
  }

  Future<void> deleteTeamHistoryByModel({
    required String teamId,
    required ServiceHistoryModel history,
  }) async {
    await _requireTeamAccess(teamId);
    await _deletePossibleTeamHistoryDocs(teamId: teamId, history: history);
  }

  Future<void> addHistoryToCurrentTeam(ServiceHistoryModel history) async {
    final team = await _getCurrentTeamForBackgroundSync();
    if (team == null) return;
    await addTeamHistory(teamId: team.id, history: history);
  }

  Future<void> replaceHistoryInCurrentTeam({
    required ServiceHistoryModel history,
    ServiceHistoryModel? previousHistory,
  }) async {
    final team = await _getCurrentTeamForBackgroundSync();
    if (team == null) return;
    await replaceTeamHistory(
      teamId: team.id,
      history: history,
      previousHistory: previousHistory,
    );
  }

  Future<void> deleteHistoryFromCurrentTeam(ServiceHistoryModel history) async {
    final team = await _getCurrentTeamForBackgroundSync();
    if (team == null) return;
    await deleteTeamHistoryByModel(teamId: team.id, history: history);
  }

  TeamWorkspaceModel? getCachedTeam() {
    final cachedData = CacheHelper.getData(key: kTeamWorkspaceKey);
    if (cachedData is! String || cachedData.isEmpty) return null;

    try {
      final decoded = jsonDecode(cachedData);
      if (decoded is! Map) return null;
      return TeamWorkspaceModel.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  String buildInviteLink(String inviteCode) {
    return '$kFirebaseHostingBaseUrl/team/${normalizeInviteCode(inviteCode)}';
  }

  String normalizeInviteCode(String code) {
    return code.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
  }

  Future<void> _cacheTeam(TeamWorkspaceModel team) async {
    await CacheHelper.saveData(
      key: kTeamWorkspaceKey,
      value: jsonEncode(team.toJson()),
    );
  }

  Future<void> _requireAuthenticatedUser() async {
    if (_auth.currentUser != null) return;

    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'unauthenticated',
      message: 'No authenticated Firebase user found.',
    );
  }

  Future<void> _requireTeamAccess(String teamId) async {
    await _requireAuthenticatedUser();

    final userId = _auth.currentUser!.uid;
    try {
      final teamDoc = await _teams.doc(teamId).get();
      if (!teamDoc.exists || teamDoc.data() == null) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'Team not found.',
        );
      }

      final members = List<String>.from(teamDoc.data()!['members'] ?? []);
      if (members.contains(userId)) return;
    } catch (_) {
      final cachedTeam = getCachedTeam();
      if (cachedTeam != null &&
          cachedTeam.id == teamId &&
          cachedTeam.members.contains(userId)) {
        return;
      }
    }

    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
      message: 'User is not a member of this team.',
    );
  }

  Future<TeamWorkspaceModel?> _getCurrentTeamForBackgroundSync() async {
    final userId = _currentUserId;
    if (userId == null) return null;

    final cachedTeam = getCachedTeam();
    if (cachedTeam != null && cachedTeam.members.contains(userId)) {
      return cachedTeam;
    }

    return getMyTeam();
  }

  List<GameModel> _uniqueGamesById(List<GameModel> games) {
    final byId = <String, GameModel>{};
    for (final game in games) {
      if (game.id.isEmpty) continue;
      byId[game.id] = game;
    }
    return byId.values.toList();
  }

  String _teamHistoryDocumentId(ServiceHistoryModel history) {
    final syncId = history.syncId.trim();
    if (syncId.isNotEmpty) return syncId;
    return _historyDocumentId(history);
  }

  String _teamPreparationPath(String teamId) {
    return 'teams/$teamId/shared/preparation';
  }

  String _teamHistoryPath(String teamId, String historyId) {
    return 'teams/$teamId/serviceHistory/$historyId';
  }

  Future<void> _deletePossibleTeamHistoryDocs({
    required String teamId,
    required ServiceHistoryModel history,
  }) async {
    final ids = <String>{
      if (history.id.trim().isNotEmpty) history.id.trim(),
      if (history.syncId.trim().isNotEmpty) history.syncId.trim(),
      _historyDocumentId(history),
    };

    for (final id in ids) {
      try {
        await _teams.doc(teamId).collection('serviceHistory').doc(id).delete();
      } catch (_) {
        await offlineSyncService.queueDelete(
          documentPath: _teamHistoryPath(teamId, id),
        );
      }
    }
  }

  String _historyDocumentId(ServiceHistoryModel history) {
    final normalizedGames = [...history.games]
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final signature = [
      history.title,
      history.place,
      history.ageGroup,
      '${history.date.year}-${history.date.month}-${history.date.day}',
      ...normalizedGames,
    ].map((value) => value.trim().toLowerCase()).join('|');

    return 'history_${_fnv1a32(signature).toRadixString(16)}';
  }

  int _fnv1a32(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }

  Future<String> _generateUniqueInviteCode() async {
    for (var i = 0; i < 8; i++) {
      final code = _generateInviteCode();
      final existing = await _teams.doc(code).get();
      if (!existing.exists) return code;
    }

    return _generateInviteCode(length: 8);
  }

  String _generateInviteCode({int length = 6}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(
      length,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
  }
}

final teamWorkspaceService = TeamWorkspaceService();

class TeamMemberModel {
  const TeamMemberModel({
    required this.id,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phoneNumber = '',
    this.churchName = '',
    this.isAdmin = false,
    this.isOwner = false,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String churchName;
  final bool isAdmin;
  final bool isOwner;

  String get displayName {
    final name = '$firstName $lastName'.trim();
    if (name.isNotEmpty) return name;
    if (email.isNotEmpty) return email;
    return id;
  }

  factory TeamMemberModel.fromJson({
    required String id,
    required Map<String, dynamic> json,
    required bool isOwner,
  }) {
    return TeamMemberModel(
      id: id,
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      churchName: json['churchName']?.toString() ?? '',
      isAdmin: json['isAdmin'] == true,
      isOwner: isOwner,
    );
  }
}
