import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_models.dart';

class QuizService extends ChangeNotifier {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  bool isLoaded = false;

  String appTitle = "Match Center Pro";
  String appSubtitle = "Premier League Match Hub & Loyalty";

  List<QuizCategory> categories = [];
  List<LiveMatch> liveMatches = [];
  List<DailyChallenge> dailyChallenges = [];
  List<LoyaltyReward> loyaltyStore = [];
  List<FanRank> fanRanks = [];

  // User Stats & State
  int _loyaltyPoints = 650;
  int get loyaltyPoints => _loyaltyPoints;

  int _quizzesPlayed = 3;
  int get quizzesPlayed => _quizzesPlayed;

  int _questionsCorrect = 11;
  int get questionsCorrect => _questionsCorrect;

  int _wordsSolved = 2;
  int get wordsSolved => _wordsSolved;

  int _streakDays = 5;
  int get streakDays => _streakDays;

  Set<String> _claimedDailyChallenges = {};
  Set<String> get claimedDailyChallenges => _claimedDailyChallenges;

  Set<String> _unlockedRewardIds = {'reward_vip_pass'};
  Set<String> get unlockedRewardIds => _unlockedRewardIds;

  final Map<String, String> _userPredictions = {};
  Map<String, String> get userPredictions => _userPredictions;

  Future<void> init() async {
    if (isLoaded) return;
    await _loadFromJson();
    await _loadPersistedUserData();
    isLoaded = true;
    notifyListeners();
  }

  Future<void> _loadFromJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/quiz_data.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);

      if (data.containsKey('app_info')) {
        appTitle = data['app_info']['title'] ?? appTitle;
        appSubtitle = data['app_info']['subtitle'] ?? appSubtitle;
      }

      if (data.containsKey('categories')) {
        categories = (data['categories'] as List<dynamic>)
            .map((c) => QuizCategory.fromJson(c as Map<String, dynamic>))
            .toList();
      }

      if (data.containsKey('live_matches')) {
        liveMatches = (data['live_matches'] as List<dynamic>)
            .map((m) => LiveMatch.fromJson(m as Map<String, dynamic>))
            .toList();
      }

      if (data.containsKey('daily_challenges')) {
        dailyChallenges = (data['daily_challenges'] as List<dynamic>)
            .map((d) => DailyChallenge.fromJson(d as Map<String, dynamic>))
            .toList();
      }

      if (data.containsKey('loyalty_store')) {
        loyaltyStore = (data['loyalty_store'] as List<dynamic>)
            .map((r) => LoyaltyReward.fromJson(r as Map<String, dynamic>))
            .toList();
      }

      if (data.containsKey('fan_ranks')) {
        fanRanks = (data['fan_ranks'] as List<dynamic>)
            .map((fr) => FanRank.fromJson(fr as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('[QuizService] Error loading quiz data: $e');
      }
    }
  }

  Future<void> _loadPersistedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _loyaltyPoints = prefs.getInt('mc_loyalty_points') ?? _loyaltyPoints;
      _quizzesPlayed = prefs.getInt('mc_quizzes_played') ?? _quizzesPlayed;
      _questionsCorrect = prefs.getInt('mc_questions_correct') ?? _questionsCorrect;
      _wordsSolved = prefs.getInt('mc_words_solved') ?? _wordsSolved;
      _streakDays = prefs.getInt('mc_streak_days') ?? _streakDays;

      final claimedList = prefs.getStringList('mc_claimed_challenges');
      if (claimedList != null) {
        _claimedDailyChallenges = claimedList.toSet();
      }

      final rewardsList = prefs.getStringList('mc_unlocked_rewards');
      if (rewardsList != null) {
        _unlockedRewardIds = rewardsList.toSet();
      }
    } catch (e) {
      if (kDebugMode) {
        print('[QuizService] Preferences load error: $e');
      }
    }
  }

  Future<void> _savePersistedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('mc_loyalty_points', _loyaltyPoints);
      await prefs.setInt('mc_quizzes_played', _quizzesPlayed);
      await prefs.setInt('mc_questions_correct', _questionsCorrect);
      await prefs.setInt('mc_words_solved', _wordsSolved);
      await prefs.setInt('mc_streak_days', _streakDays);
      await prefs.setStringList('mc_claimed_challenges', _claimedDailyChallenges.toList());
      await prefs.setStringList('mc_unlocked_rewards', _unlockedRewardIds.toList());
    } catch (_) {}
  }

  void addPoints(int points) {
    _loyaltyPoints += points;
    _savePersistedUserData();
    notifyListeners();
  }

  void recordQuizCompleted({required int correctAnswers, required int pointsGained}) {
    _quizzesPlayed += 1;
    _questionsCorrect += correctAnswers;
    _loyaltyPoints += pointsGained;
    _savePersistedUserData();
    notifyListeners();
  }

  void recordWordSolved(int pointsGained) {
    _wordsSolved += 1;
    _loyaltyPoints += pointsGained;
    _savePersistedUserData();
    notifyListeners();
  }

  bool claimDailyChallenge(DailyChallenge challenge) {
    if (_claimedDailyChallenges.contains(challenge.id)) return false;
    _claimedDailyChallenges.add(challenge.id);
    _loyaltyPoints += challenge.rewardPoints;
    _savePersistedUserData();
    notifyListeners();
    return true;
  }

  bool purchaseReward(LoyaltyReward reward) {
    if (_unlockedRewardIds.contains(reward.id)) return false;
    if (_loyaltyPoints < reward.cost) return false;

    _loyaltyPoints -= reward.cost;
    _unlockedRewardIds.add(reward.id);
    _savePersistedUserData();
    notifyListeners();
    return true;
  }

  void setMatchPrediction(String matchId, String prediction) {
    _userPredictions[matchId] = prediction;
    _loyaltyPoints += 50; // reward for participating in match predictor
    notifyListeners();
  }

  FanRank get currentRank {
    if (fanRanks.isEmpty) {
      return FanRank(title: 'Rookie Supporter', minPoints: 0, perk: 'Standard access');
    }
    FanRank active = fanRanks.first;
    for (final rank in fanRanks) {
      if (_loyaltyPoints >= rank.minPoints) {
        active = rank;
      }
    }
    return active;
  }

  FanRank? get nextRank {
    if (fanRanks.isEmpty) return null;
    for (final rank in fanRanks) {
      if (rank.minPoints > _loyaltyPoints) {
        return rank;
      }
    }
    return null;
  }

  double get progressToNextRank {
    final next = nextRank;
    if (next == null) return 1.0;
    final curr = currentRank;
    final needed = next.minPoints - curr.minPoints;
    if (needed <= 0) return 1.0;
    final progress = (_loyaltyPoints - curr.minPoints) / needed;
    return progress.clamp(0.0, 1.0);
  }

  Future<void> resetProgress() async {
    _loyaltyPoints = 500;
    _quizzesPlayed = 0;
    _questionsCorrect = 0;
    _wordsSolved = 0;
    _claimedDailyChallenges.clear();
    _unlockedRewardIds = {'reward_vip_pass'};
    _userPredictions.clear();
    await _savePersistedUserData();
    notifyListeners();
  }
}
