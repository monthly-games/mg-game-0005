import 'package:flutter/foundation.dart';
import 'dart:async';

enum RhythmAccuracy {
  perfect,
  great,
  good,
  miss,
}

extension RhythmAccuracyExtension on RhythmAccuracy {
  double get scoreMultiplier {
    switch (this) {
      case RhythmAccuracy.perfect:
        return 1.0;
      case RhythmAccuracy.great:
        return 0.8;
      case RhythmAccuracy.good:
        return 0.5;
      case RhythmAccuracy.miss:
        return 0.0;
    }
  }

  int get points {
    switch (this) {
      case RhythmAccuracy.perfect:
        return 100;
      case RhythmAccuracy.great:
        return 75;
      case RhythmAccuracy.good:
        return 50;
      case RhythmAccuracy.miss:
        return 0;
    }
  }

  String get label {
    switch (this) {
      case RhythmAccuracy.perfect:
        return 'PERFECT!';
      case RhythmAccuracy.great:
        return 'GREAT!';
      case RhythmAccuracy.good:
        return 'GOOD';
      case RhythmAccuracy.miss:
        return 'MISS';
    }
  }
}

class RhythmTimingWindow {
  final Duration perfectWindow;
  final Duration greatWindow;
  final Duration goodWindow;

  const RhythmTimingWindow({
    this.perfectWindow = const Duration(milliseconds: 50),
    this.greatWindow = const Duration(milliseconds: 100),
    this.goodWindow = const Duration(milliseconds: 150),
  });
}

class RhythmSystem extends ChangeNotifier {
  static const defaultTimingWindow = RhythmTimingWindow();

  final RhythmTimingWindow timingWindow;
  final Stopwatch _timingStopwatch = Stopwatch();

  // Target timing for rhythm beats
  DateTime? _lastBeatTime;
  int? _currentBpm;

  // Statistics
  int _totalInputs = 0;
  int _perfectCount = 0;
  int _greatCount = 0;
  int _goodCount = 0;
  int _missCount = 0;

  // Combo system
  int _currentCombo = 0;
  int _maxCombo = 0;
  int _feverModeThreshold = 20;
  bool _isFeverMode = false;

  // Score tracking
  int _currentScore = 0;
  int _highScore = 0;

  // Accuracy tracking
  double _averageTimingOffset = 0.0;
  final List<double> _timingOffsets = [];

  // Event streams
  final _accuracyController = StreamController<RhythmAccuracy>.broadcast();
  final _comboController = StreamController<int>.broadcast();
  final _feverController = StreamController<bool>.broadcast();

  Stream<RhythmAccuracy> get accuracyStream => _accuracyController.stream;
  Stream<int> get comboStream => _comboController.stream;
  Stream<bool> get feverStream => _feverController.stream;

  RhythmSystem({
    this.timingWindow = defaultTimingWindow,
  });

  // Getters
  int get currentCombo => _currentCombo;
  int get maxCombo => _maxCombo;
  bool get isFeverMode => _isFeverMode;
  int get currentScore => _currentScore;
  int get highScore => _highScore;
  int get totalInputs => _totalInputs;
  double get accuracyPercentage {
    if (_totalInputs == 0) return 0.0;
    final successfulInputs = _perfectCount + _greatCount + _goodCount;
    return (successfulInputs / _totalInputs) * 100;
  }

  // Start rhythm tracking
  void startRhythm(int bpm) {
    _currentBpm = bpm;
    _lastBeatTime = DateTime.now();
    _timingStopwatch.start();
    _resetSession();
  }

  // Stop rhythm tracking
  void stopRhythm() {
    _timingStopwatch.stop();
    _timingStopwatch.reset();
    _currentBpm = null;
    _lastBeatTime = null;

    // Update high score
    if (_currentScore > _highScore) {
      _highScore = _currentScore;
    }
  }

  // Register a rhythm input (e.g., puzzle match, button press)
  RhythmAccuracy registerInput() {
    if (!_timingStopwatch.isRunning) {
      return RhythmAccuracy.miss;
    }

    _totalInputs++;
    final accuracy = _evaluateAccuracy();

    // Update statistics
    switch (accuracy) {
      case RhythmAccuracy.perfect:
        _perfectCount++;
        break;
      case RhythmAccuracy.great:
        _greatCount++;
        break;
      case RhythmAccuracy.good:
        _goodCount++;
        break;
      case RhythmAccuracy.miss:
        _missCount++;
        break;
    }

    // Update combo
    if (accuracy == RhythmAccuracy.miss) {
      _currentCombo = 0;
      _isFeverMode = false;
      _feverController.add(false);
    } else {
      _currentCombo++;
      if (_currentCombo > _maxCombo) {
        _maxCombo = _currentCombo;
      }

      // Check for fever mode
      if (_currentCombo >= _feverModeThreshold && !_isFeverMode) {
        _isFeverMode = true;
        _feverController.add(true);
      }
    }

    // Calculate score with combo multiplier
    final basePoints = accuracy.points;
    final comboMultiplier = _getComboMultiplier();
    final feverMultiplier = _isFeverMode ? 2.0 : 1.0;
    final points = (basePoints * comboMultiplier * feverMultiplier).toInt();
    _currentScore += points;

    // Notify listeners
    _accuracyController.add(accuracy);
    _comboController.add(_currentCombo);
    notifyListeners();

    return accuracy;
  }

  // Evaluate timing accuracy
  RhythmAccuracy _evaluateAccuracy() {
    if (_lastBeatTime == null || _currentBpm == null) {
      return RhythmAccuracy.miss;
    }

    final now = DateTime.now();
    final offset = now.difference(_lastBeatTime!).abs();

    // Store timing offset for analysis
    final offsetMs = offset.inMilliseconds.toDouble();
    _timingOffsets.add(offsetMs);
    _averageTimingOffset = _timingOffsets.reduce((a, b) => a + b) / _timingOffsets.length;

    // Update last beat time based on BPM
    final beatInterval = 60000 ~/ _currentBpm!;
    _lastBeatTime = _lastBeatTime!.add(Duration(milliseconds: beatInterval));

    // Evaluate accuracy
    if (offset <= timingWindow.perfectWindow) {
      return RhythmAccuracy.perfect;
    } else if (offset <= timingWindow.greatWindow) {
      return RhythmAccuracy.great;
    } else if (offset <= timingWindow.goodWindow) {
      return RhythmAccuracy.good;
    } else {
      return RhythmAccuracy.miss;
    }
  }

  // Calculate combo multiplier
  double _getComboMultiplier() {
    if (_currentCombo < 5) return 1.0;
    if (_currentCombo < 10) return 1.2;
    if (_currentCombo < 20) return 1.5;
    if (_currentCombo < 30) return 1.8;
    return 2.0;
  }

  // Reset session statistics
  void _resetSession() {
    _totalInputs = 0;
    _perfectCount = 0;
    _greatCount = 0;
    _goodCount = 0;
    _missCount = 0;
    _currentCombo = 0;
    _currentScore = 0;
    _isFeverMode = false;
    _timingOffsets.clear();
    _averageTimingOffset = 0.0;
    notifyListeners();
  }

  // Get detailed statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalInputs': _totalInputs,
      'perfectCount': _perfectCount,
      'greatCount': _greatCount,
      'goodCount': _goodCount,
      'missCount': _missCount,
      'accuracyPercentage': accuracyPercentage,
      'currentCombo': _currentCombo,
      'maxCombo': _maxCombo,
      'currentScore': _currentScore,
      'highScore': _highScore,
      'isFeverMode': _isFeverMode,
      'averageTimingOffset': _averageTimingOffset,
    };
  }

  // Get accuracy distribution
  Map<RhythmAccuracy, int> getAccuracyDistribution() {
    return {
      RhythmAccuracy.perfect: _perfectCount,
      RhythmAccuracy.great: _greatCount,
      RhythmAccuracy.good: _goodCount,
      RhythmAccuracy.miss: _missCount,
    };
  }

  @override
  void dispose() {
    _accuracyController.close();
    _comboController.close();
    _feverController.close();
    _timingStopwatch.stop();
    super.dispose();
  }
}