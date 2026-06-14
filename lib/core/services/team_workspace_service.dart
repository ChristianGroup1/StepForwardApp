import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stepforward/core/helper_functions/cache_helper.dart';
import 'package:stepforward/core/helper_functions/get_user_data.dart';
import 'package:stepforward/core/utils/chache_helper_keys.dart';
import 'package:stepforward/core/utils/constants.dart';
import 'package:stepforward/features/home/domain/models/game_model.dart';
import 'package:stepforward/features/home/domain/models/service_history_model.dart';
import 'package:stepforward/features/home/domain/models/team_workspace_model.dart';

class TeamWorkspaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Random _random = Random.secure();

  CollectionReference<Map<String, dynamic>> get _teams =>
      _firestore.collection('teams');

  Future<TeamWorkspaceModel?> getMyTeam() async {
    final user = getCachedUserData();
    if (user == null) return getCachedTeam();

    try {
      final snapshot = await _teams
          .where('members', arrayContains: user.id)
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
    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return null;

    await docRef.update({
      'members': FieldValue.arrayUnion([user.id]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

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

  Future<void> saveTeamPreparationGames({
    required String teamId,
    required List<GameModel> games,
  }) async {
    await _teams.doc(teamId).collection('shared').doc('preparation').set({
      'games': games.map((game) => game.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
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

  Future<void> addTeamHistory({
    required String teamId,
    required ServiceHistoryModel history,
  }) async {
    await _teams
        .doc(teamId)
        .collection('serviceHistory')
        .add(history.toFirestore());
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
