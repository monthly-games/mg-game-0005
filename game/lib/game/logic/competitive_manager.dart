import 'package:flutter/foundation.dart';
import 'dart:async';
import 'rhythm_system.dart';
import 'song_manager.dart';

enum MatchStatus { waiting, active, completed, abandoned }

enum CompetitiveMode { realtime, weeklyRanking }

class PlayerScore {
  final String playerId;
  final String playerName;
  int score;
  int maxCombo;
  double accuracy;
  int perfectCount;
  int greatCount;
  int goodCount;
  int missCount;

  PlayerScore({
    required this.playerId,
    required this.playerName,
    this.score = 0,
    this.maxCombo = 0,
    this.accuracy = 0.0,
    this.perfectCount = 0,
    this.greatCount = 0,
    this.goodCount = 0,
    this.missCount = 0,
  });

  double get performanceRating {
    final comboBonus = maxCombo * 10;
    final accuracyBonus = accuracy * 100;
    return score + comboBonus + accuracyBonus;
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'score': score,
      'maxCombo': maxCombo,
      'accuracy': accuracy,
      'perfectCount': perfectCount,
      'greatCount': greatCount,
      'goodCount': goodCount,
      'missCount': missCount,
    };
  }

  factory PlayerScore.fromJson(Map<String, dynamic> json) {
    return PlayerScore(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      score: json['score'] as int,
      maxCombo: json['maxCombo'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      perfectCount: json['perfectCount'] as int,
      greatCount: json['greatCount'] as int,
      goodCount: json['goodCount'] as int,
      missCount: json['missCount'] as int,
    );
  }
}

class CompetitiveMatch {
  final String matchId;
  final String songId;
  final Difficulty difficulty;
  final DateTime createdAt;
  final List<PlayerScore> participants;
  MatchStatus status;
  DateTime? completedAt;

  CompetitiveMatch({
    required this.matchId,
    required this.songId,
    required this.difficulty,
    required this.participants,
    this.status = MatchStatus.waiting,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  PlayerScore? get winner {
    if (participants.isEmpty) return null;
    participants.sort((a, b) => b.performanceRating.compareTo(a.performanceRating));
    return participants.first;
  }

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'songId': songId,
      'difficulty': difficulty.toString(),
      'createdAt': createdAt.toIso8601String(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'status': status.toString(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory CompetitiveMatch.fromJson(Map<String, dynamic> json) {
    return CompetitiveMatch(
      matchId: json['matchId'] as String,
      songId: json['songId'] as String,
      difficulty: Difficulty.values.firstWhere(
        (d) => d.toString() == json['difficulty'],
        orElse: () => Difficulty.normal,
      ),
      participants: (json['participants'] as List)
          .map((p) => PlayerScore.fromJson(p as Map<String, dynamic>))
          .toList(),
      status: MatchStatus.values.firstWhere(
        (s) => s.toString() == json['status'],
        orElse: () => MatchStatus.waiting,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

class WeeklyRankingEntry {
  final String playerId;
  final String playerName;
  int totalScore;
  int matchesPlayed;
  int wins;
  DateTime weekStart;
  DateTime weekEnd;

  WeeklyRankingEntry({
    required this.playerId,
    required this.playerName,
    this.totalScore = 0,
    this.matchesPlayed = 0,
    this.wins = 0,
    DateTime? weekStart,
    DateTime? weekEnd,
  })  : weekStart = weekStart ?? _getWeekStart(),
        weekEnd = weekEnd ?? _getWeekEnd();

  static DateTime _getWeekStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).subtract(
      Duration(days: now.weekday - 1),
    );
  }

  static DateTime _getWeekEnd() {
    final start = _getWeekStart();
    return start.add(const Duration(days: 7));
  }

  bool get isCurrentWeek {
    final now = DateTime.now();
    return now.isAfter(weekStart) && now.isBefore(weekEnd);
  }

  double get winRate {
    if (matchesPlayed == 0) return 0.0;
    return (wins / matchesPlayed) * 100;
  }

  double get averageScore {
    if (matchesPlayed == 0) return 0.0;
    return totalScore / matchesPlayed;
  }

  void addMatchResult(int score, bool isWin) {
    totalScore += score;
    matchesPlayed++;
    if (isWin) wins++;
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'totalScore': totalScore,
      'matchesPlayed': matchesPlayed,
      'wins': wins,
      'weekStart': weekStart.toIso8601String(),
      'weekEnd': weekEnd.toIso8601String(),
    };
  }

  factory WeeklyRankingEntry.fromJson(Map<String, dynamic> json) {
    return WeeklyRankingEntry(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      totalScore: json['totalScore'] as int,
      matchesPlayed: json['matchesPlayed'] as int,
      wins: json['wins'] as int,
      weekStart: DateTime.parse(json['weekStart'] as String),
      weekEnd: DateTime.parse(json['weekEnd'] as String),
    );
  }
}

class CompetitiveManager extends ChangeNotifier {
  final List<CompetitiveMatch> _activeMatches = [];
  final List<WeeklyRankingEntry> _weeklyRankings = [];
  final List<CompetitiveMatch> _matchHistory = [];

  // Current user session
  String? _currentPlayerId;
  String? _currentPlayerName;
  CompetitiveMatch? _currentMatch;

  // Ranking period
  DateTime get _currentWeekStart => WeeklyRankingEntry._getWeekStart();
  DateTime get _currentWeekEnd => WeeklyRankingEntry._getWeekEnd();

  // Getters
  List<CompetitiveMatch> get activeMatches => _activeMatches;
  List<WeeklyRankingEntry> get weeklyRankings => _weeklyRankings;
  List<CompetitiveMatch> get matchHistory => _matchHistory;
  CompetitiveMatch? get currentMatch => _currentMatch;

  // Streams
  final _matchController = StreamController<CompetitiveMatch>.broadcast();
  final _rankingController = StreamController<List<WeeklyRankingEntry>>.broadcast();

  Stream<CompetitiveMatch> get matchStream => _matchController.stream;
  Stream<List<WeeklyRankingEntry>> get rankingStream => _rankingController.stream;

  CompetitiveManager() {
    _initializeRankings();
  }

  void _initializeRankings() {
    // Add some sample rankings for demonstration
    _weeklyRankings.addAll([
      WeeklyRankingEntry(
        playerId: 'bot1',
        playerName: 'RhythmMaster',
        totalScore: 15000,
        matchesPlayed: 10,
        wins: 8,
      ),
      WeeklyRankingEntry(
        playerId: 'bot2',
        playerName: 'BeatKing',
        totalScore: 12000,
        matchesPlayed: 8,
        wins: 6,
      ),
      WeeklyRankingEntry(
        playerId: 'bot3',
        playerName: 'TempoQueen',
        totalScore: 10000,
        matchesPlayed: 12,
        wins: 5,
      ),
    ]);
    _updateRankings();
  }

  // Initialize player session
  void initializePlayer(String playerId, String playerName) {
    _currentPlayerId = playerId;
    _currentPlayerName = playerName;

    // Check if player has existing ranking entry
    final existingEntry = _weeklyRankings.firstWhere(
      (entry) => entry.playerId == playerId && entry.isCurrentWeek,
      orElse: () => WeeklyRankingEntry(
        playerId: playerId,
        playerName: playerName,
      ),
    );

    if (!_weeklyRankings.any((entry) => entry.playerId == playerId && entry.isCurrentWeek)) {
      _weeklyRankings.add(existingEntry);
      _updateRankings();
    }

    notifyListeners();
  }

  // Create a new multiplayer match
  CompetitiveMatch createRealtimeMatch(String songId, Difficulty difficulty) {
    final matchId = 'match_${DateTime.now().millisecondsSinceEpoch}';
    final match = CompetitiveMatch(
      matchId: matchId,
      songId: songId,
      difficulty: difficulty,
      participants: [
        if (_currentPlayerId != null)
          PlayerScore(
            playerId: _currentPlayerId!,
            playerName: _currentPlayerName ?? 'Player',
          ),
      ],
      status: MatchStatus.waiting,
    );

    _activeMatches.add(match);
    _currentMatch = match;
    _matchController.add(match);
    notifyListeners();

    return match;
  }

  // Join an existing match
  bool joinMatch(String matchId) {
    final match = _activeMatches.firstWhere(
      (m) => m.matchId == matchId,
      orElse: () => _activeMatches.first,
    );

    if (match.status != MatchStatus.waiting) return false;
    if (_currentPlayerId == null) return false;

    // Check if already joined
    if (match.participants.any((p) => p.playerId == _currentPlayerId)) {
      return false;
    }

    match.participants.add(PlayerScore(
      playerId: _currentPlayerId!,
      playerName: _currentPlayerName ?? 'Player',
    ));

    _currentMatch = match;
    _matchController.add(match);
    notifyListeners();

    return true;
  }

  // Start the match
  void startMatch(String matchId) {
    final match = _activeMatches.firstWhere(
      (m) => m.matchId == matchId,
      orElse: () => _activeMatches.first,
    );

    if (match.participants.length < 1) return;

    match.status = MatchStatus.active;
    _matchController.add(match);
    notifyListeners();
  }

  // Submit score for current match
  void submitMatchScore(RhythmSystem rhythmSystem) {
    if (_currentMatch == null || _currentPlayerId == null) return;
    if (_currentMatch!.status != MatchStatus.active) return;

    final stats = rhythmSystem.getStatistics();
    final accuracy = rhythmSystem.accuracyPercentage;

    final playerScore = _currentMatch!.participants.firstWhere(
      (p) => p.playerId == _currentPlayerId,
    );

    playerScore.score = rhythmSystem.currentScore;
    playerScore.maxCombo = rhythmSystem.maxCombo;
    playerScore.accuracy = accuracy;
    playerScore.perfectCount = stats['perfectCount'] as int;
    playerScore.greatCount = stats['greatCount'] as int;
    playerScore.goodCount = stats['goodCount'] as int;
    playerScore.missCount = stats['missCount'] as int;

    // Check if match should complete
    final allScoresSubmitted = _currentMatch!.participants.every(
      (p) => p.score > 0,
    );

    if (allScoresSubmitted) {
      _completeMatch(_currentMatch!);
    }

    _matchController.add(_currentMatch!);
    notifyListeners();
  }

  // Complete a match and update rankings
  void _completeMatch(CompetitiveMatch match) {
    match.status = MatchStatus.completed;
    match.completedAt = DateTime.now();

    final winner = match.winner;
    if (winner != null) {
      // Update weekly rankings
      for (final participant in match.participants) {
        final entry = _weeklyRankings.firstWhere(
          (e) => e.playerId == participant.playerId && e.isCurrentWeek,
          orElse: () => WeeklyRankingEntry(
            playerId: participant.playerId,
            playerName: participant.playerName,
          ),
        );

        if (!_weeklyRankings.any((e) => e.playerId == participant.playerId && e.isCurrentWeek)) {
          _weeklyRankings.add(entry);
        }

        final isWin = participant.playerId == winner.playerId;
        entry.addMatchResult(participant.score, isWin);
      }
    }

    // Move to history
    _activeMatches.remove(match);
    _matchHistory.add(match);
    _currentMatch = null;

    _updateRankings();
    notifyListeners();
  }

  // Get current weekly rankings
  List<WeeklyRankingEntry> getWeeklyRankings() {
    final current = _weeklyRankings
        .where((entry) => entry.isCurrentWeek)
        .toList()
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return current;
  }

  // Get player's current ranking
  int getPlayerRanking() {
    if (_currentPlayerId == null) return -1;
    final rankings = getWeeklyRankings();
    return rankings.indexWhere((r) => r.playerId == _currentPlayerId) + 1;
  }

  // Get player's ranking entry
  WeeklyRankingEntry? getPlayerEntry() {
    if (_currentPlayerId == null) return null;
    try {
      return _weeklyRankings.firstWhere(
        (entry) => entry.playerId == _currentPlayerId && entry.isCurrentWeek,
      );
    } catch (e) {
      return null;
    }
  }

  void _updateRankings() {
    _rankingController.add(getWeeklyRankings());
  }

  // Get available matches to join
  List<CompetitiveMatch> getAvailableMatches() {
    return _activeMatches
        .where((match) =>
            match.status == MatchStatus.waiting &&
            (_currentPlayerId == null ||
                !match.participants.any((p) => p.playerId == _currentPlayerId)))
        .toList();
  }

  // Get match history
  List<CompetitiveMatch> getPlayerMatchHistory() {
    if (_currentPlayerId == null) return [];
    return _matchHistory
        .where((match) =>
            match.participants.any((p) => p.playerId == _currentPlayerId))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  void dispose() {
    _matchController.close();
    _rankingController.close();
    super.dispose();
  }
}