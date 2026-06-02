import 'package:flutter/foundation.dart';
import 'dart:async';

enum Difficulty { easy, normal, hard, expert }

class Song {
  final String id;
  final String name;
  final String artist;
  final int bpm;
  final Duration duration;
  final Difficulty baseDifficulty;
  bool isUnlocked;

  Song({
    required this.id,
    required this.name,
    required this.artist,
    required this.bpm,
    required this.duration,
    required this.baseDifficulty,
    this.isUnlocked = false,
  });
}

class SongManager extends ChangeNotifier {
  final List<Song> _songs = [];

  List<Song> get songs => _songs;
  Difficulty currentDifficulty = Difficulty.normal;

  // Statistics
  int totalSongsPlayed = 0;
  Map<String, int> highScores = {};
  Map<String, Difficulty> bestDifficultyCleared = {};

  SongManager() {
    _initializeSongs();
  }

  void _initializeSongs() {
    _songs.addAll([
      // Tier 1: Beginner Songs (Easy)
      Song(
        id: 'morning_sunrise',
        name: 'Morning Sunrise',
        artist: 'Pixel Beats',
        bpm: 80,
        duration: const Duration(minutes: 2, seconds: 30),
        baseDifficulty: Difficulty.easy,
        isUnlocked: true,
      ),
      Song(
        id: 'gentle_breeze',
        name: 'Gentle Breeze',
        artist: 'Chiptune Collective',
        bpm: 90,
        duration: const Duration(minutes: 2, seconds: 15),
        baseDifficulty: Difficulty.easy,
        isUnlocked: true,
      ),
      Song(
        id: 'happy_hop',
        name: 'Happy Hop',
        artist: '8-Bit Dreams',
        bpm: 100,
        duration: const Duration(minutes: 2, seconds: 45),
        baseDifficulty: Difficulty.easy,
        isUnlocked: true,
      ),
      Song(
        id: 'crystal_cave',
        name: 'Crystal Cave',
        artist: 'Dungeon Synth',
        bpm: 85,
        duration: const Duration(minutes: 2, seconds: 20),
        baseDifficulty: Difficulty.easy,
        isUnlocked: true,
      ),
      Song(
        id: 'forest_walk',
        name: 'Forest Walk',
        artist: 'Nature Beats',
        bpm: 95,
        duration: const Duration(minutes: 2, seconds: 40),
        baseDifficulty: Difficulty.easy,
        isUnlocked: true,
      ),

      // Tier 2: Normal Songs
      Song(
        id: 'thunder_strike',
        name: 'Thunder Strike',
        artist: 'Electric Dreams',
        bpm: 120,
        duration: const Duration(minutes: 3, seconds: 0),
        baseDifficulty: Difficulty.normal,
        isUnlocked: false,
      ),
      Song(
        id: 'neon_nights',
        name: 'Neon Nights',
        artist: 'Synthwave Central',
        bpm: 130,
        duration: const Duration(minutes: 3, seconds: 15),
        baseDifficulty: Difficulty.normal,
        isUnlocked: false,
      ),
      Song(
        id: 'robot_boogie',
        name: 'Robot Boogie',
        artist: 'Mechanical Melodies',
        bpm: 125,
        duration: const Duration(minutes: 2, seconds: 50),
        baseDifficulty: Difficulty.normal,
        isUnlocked: false,
      ),
      Song(
        id: 'space_odyssey',
        name: 'Space Odyssey',
        artist: 'Cosmic Sounds',
        bpm: 110,
        duration: const Duration(minutes: 3, seconds: 20),
        baseDifficulty: Difficulty.normal,
        isUnlocked: false,
      ),
      Song(
        id: 'urban_rush',
        name: 'Urban Rush',
        artist: 'City Beats',
        bpm: 140,
        duration: const Duration(minutes: 2, seconds: 55),
        baseDifficulty: Difficulty.normal,
        isUnlocked: false,
      ),
      Song(
        id: 'dragon_dance',
        name: 'Dragon Dance',
        artist: 'Fantasy Frequencies',
        bpm: 115,
        duration: const Duration(minutes: 3, seconds: 10),
        baseDifficulty: Difficulty.normal,
        isUnlocked: false,
      ),
      Song(
        id: 'pirate_quest',
        name: 'Pirate Quest',
        artist: 'Sea Shanties Remix',
        bpm: 105,
        duration: const Duration(minutes: 3, seconds: 0),
        baseDifficulty: Difficulty.normal,
        isUnlocked: false,
      ),

      // Tier 3: Hard Songs
      Song(
        id: 'inferno_fury',
        name: 'Inferno Fury',
        artist: 'Hellfire Harmonics',
        bpm: 160,
        duration: const Duration(minutes: 3, seconds: 30),
        baseDifficulty: Difficulty.hard,
        isUnlocked: false,
      ),
      Song(
        id: 'blizzard_storm',
        name: 'Blizzard Storm',
        artist: 'Frozen Audio',
        bpm: 150,
        duration: const Duration(minutes: 3, seconds: 15),
        baseDifficulty: Difficulty.hard,
        isUnlocked: false,
      ),
      Song(
        id: 'chaos_theory',
        name: 'Chaos Theory',
        artist: 'Math Metal Beats',
        bpm: 170,
        duration: const Duration(minutes: 3, seconds: 45),
        baseDifficulty: Difficulty.hard,
        isUnlocked: false,
      ),
      Song(
        id: 'dark_castle',
        name: 'Dark Castle',
        artist: 'Gothic Game Music',
        bpm: 145,
        duration: const Duration(minutes: 3, seconds: 20),
        baseDifficulty: Difficulty.hard,
        isUnlocked: false,
      ),
      Song(
        id: 'speed_demon',
        name: 'Speed Demon',
        artist: 'Velocity Records',
        bpm: 180,
        duration: const Duration(minutes: 3, seconds: 0),
        baseDifficulty: Difficulty.hard,
        isUnlocked: false,
      ),
      Song(
        id: 'boss_battle',
        name: 'Boss Battle',
        artist: 'Epic Orchestra',
        bpm: 155,
        duration: const Duration(minutes: 3, seconds: 40),
        baseDifficulty: Difficulty.hard,
        isUnlocked: false,
      ),
      Song(
        id: 'time_trial',
        name: 'Time Trial',
        artist: 'Chrono Sounds',
        bpm: 165,
        duration: const Duration(minutes: 3, seconds: 25),
        baseDifficulty: Difficulty.hard,
        isUnlocked: false,
      ),

      // Tier 4: Expert Songs
      Song(
        id: 'impossible_challenge',
        name: 'Impossible Challenge',
        artist: 'Master Level Music',
        bpm: 200,
        duration: const Duration(minutes: 4, seconds: 0),
        baseDifficulty: Difficulty.expert,
        isUnlocked: false,
      ),
      Song(
        id: 'final_showdown',
        name: 'Final Showdown',
        artist: 'Ultimate Beats',
        bpm: 190,
        duration: const Duration(minutes: 4, seconds: 15),
        baseDifficulty: Difficulty.expert,
        isUnlocked: false,
      ),
      Song(
        id: 'god_tier',
        name: 'God Tier',
        artist: 'Legends Only',
        bpm: 195,
        duration: const Duration(minutes: 3, seconds: 50),
        baseDifficulty: Difficulty.expert,
        isUnlocked: false,
      ),
    ]);
  }

  List<Song> getSongsByDifficulty(Difficulty difficulty) {
    return _songs.where((song) => song.baseDifficulty == difficulty).toList();
  }

  List<Song> getUnlockedSongs() {
    return _songs.where((song) => song.isUnlocked).toList();
  }

  bool unlockSong(String songId) {
    final song = _songs.firstWhere(
      (s) => s.id == songId,
      orElse: () => _songs.first,
    );

    if (song.isUnlocked) return false;

    song.isUnlocked = true;
    notifyListeners();
    return true;
  }

  void setDifficulty(Difficulty difficulty) {
    currentDifficulty = difficulty;
    notifyListeners();
  }

  void submitScore(String songId, int score) {
    totalSongsPlayed++;

    // Update high score
    if (!highScores.containsKey(songId) || score > highScores[songId]!) {
      highScores[songId] = score;
    }

    // Track best difficulty cleared
    final song = _songs.firstWhere((s) => s.id == songId);
    if (!bestDifficultyCleared.containsKey(songId) ||
        currentDifficulty.index > bestDifficultyCleared[songId]!.index) {
      bestDifficultyCleared[songId] = currentDifficulty;
    }

    notifyListeners();
  }

  int getHighScore(String songId) {
    return highScores[songId] ?? 0;
  }

  double getCompletionPercentage() {
    if (_songs.isEmpty) return 0.0;
    final unlocked = _songs.where((s) => s.isUnlocked).length;
    return (unlocked / _songs.length) * 100;
  }

  Song? getSongById(String id) {
    try {
      return _songs.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get recommended next song based on progress
  Song? getNextRecommendedSong() {
    final unlocked = getUnlockedSongs();
    for (var song in unlocked) {
      if (getHighScore(song.id) == 0) {
        return song; // First unplayed unlocked song
      }
    }

    // If all unlocked songs played, recommend next locked song
    for (var song in _songs) {
      if (!song.isUnlocked) {
        return song;
      }
    }

    return null;
  }
}
