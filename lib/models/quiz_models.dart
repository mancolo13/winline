class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int points;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.points,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as int? ?? 0,
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctIndex: json['correct_index'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
      points: json['points'] as int? ?? 100,
    );
  }
}

class WordPuzzle {
  final String word;
  final String hint;
  final String difficulty;
  final int points;

  WordPuzzle({
    required this.word,
    required this.hint,
    required this.difficulty,
    required this.points,
  });

  factory WordPuzzle.fromJson(Map<String, dynamic> json) {
    return WordPuzzle(
      word: (json['word'] as String? ?? '').toUpperCase(),
      hint: json['hint'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'Easy',
      points: json['points'] as int? ?? 100,
    );
  }
}

class QuizCategory {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String accentColor;
  final List<QuizQuestion> questions;
  final List<WordPuzzle> words;

  QuizCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.questions,
    required this.words,
  });

  factory QuizCategory.fromJson(Map<String, dynamic> json) {
    return QuizCategory(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'sports_soccer',
      accentColor: json['accent_color'] as String? ?? '#FF5500',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      words: (json['words'] as List<dynamic>?)
              ?.map((w) => WordPuzzle.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LiveMatch {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;
  final String minute;
  final String status;
  final String stadium;
  final String attendance;
  final String possession;
  final String shotsOnTarget;
  final String corners;
  final List<String> highlights;
  final String matchTrivia;

  LiveMatch({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.minute,
    required this.status,
    required this.stadium,
    required this.attendance,
    required this.possession,
    required this.shotsOnTarget,
    required this.corners,
    required this.highlights,
    required this.matchTrivia,
  });

  factory LiveMatch.fromJson(Map<String, dynamic> json) {
    return LiveMatch(
      id: json['id'] as String? ?? '',
      homeTeam: json['home_team'] as String? ?? '',
      awayTeam: json['away_team'] as String? ?? '',
      homeScore: json['home_score'] as int? ?? 0,
      awayScore: json['away_score'] as int? ?? 0,
      minute: json['minute'] as String? ?? '',
      status: json['status'] as String? ?? 'UPCOMING',
      stadium: json['stadium'] as String? ?? '',
      attendance: json['attendance'] as String? ?? '',
      possession: json['possession'] as String? ?? '',
      shotsOnTarget: json['shots_on_target'] as String? ?? '',
      corners: json['corners'] as String? ?? '',
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((h) => h.toString())
              .toList() ??
          [],
      matchTrivia: json['match_trivia'] as String? ?? '',
    );
  }
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final int rewardPoints;
  final int progressTarget;
  final String icon;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardPoints,
    required this.progressTarget,
    required this.icon,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rewardPoints: json['reward_points'] as int? ?? 100,
      progressTarget: json['progress_target'] as int? ?? 1,
      icon: json['icon'] as String? ?? 'military_tech',
    );
  }
}

class LoyaltyReward {
  final String id;
  final String title;
  final int cost;
  final String icon;
  final String description;

  LoyaltyReward({
    required this.id,
    required this.title,
    required this.cost,
    required this.icon,
    required this.description,
  });

  factory LoyaltyReward.fromJson(Map<String, dynamic> json) {
    return LoyaltyReward(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      cost: json['cost'] as int? ?? 500,
      icon: json['icon'] as String? ?? 'card_giftcard',
      description: json['description'] as String? ?? '',
    );
  }
}

class FanRank {
  final String title;
  final int minPoints;
  final String perk;

  FanRank({
    required this.title,
    required this.minPoints,
    required this.perk,
  });

  factory FanRank.fromJson(Map<String, dynamic> json) {
    return FanRank(
      title: json['title'] as String? ?? 'Rookie Supporter',
      minPoints: json['min_points'] as int? ?? 0,
      perk: json['perk'] as String? ?? '',
    );
  }
}
