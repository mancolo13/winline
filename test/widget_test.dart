import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_/models/quiz_models.dart';
import 'package:app_/screens/main_stub_screen.dart';
import 'package:app_/screens/quiz_play_screen.dart';
import 'package:app_/screens/word_puzzle_screen.dart';
import 'package:app_/screens/tabs/match_center_tab.dart';
import 'package:app_/screens/tabs/quiz_hub_tab.dart';
import 'package:app_/screens/tabs/daily_challenges_tab.dart';
import 'package:app_/screens/tabs/loyalty_profile_tab.dart';
import 'package:app_/services/quiz_service.dart';
import 'package:app_/theme/app_theme.dart';

void main() {
  setUp(() async {
    // Populate QuizService with sample RPL data to guarantee offline determinism in tests
    final service = QuizService();
    service.categories = [
      QuizCategory(
        id: 'clubs_derbies',
        title: 'Clubs & Epic Derbies',
        description: 'Historical rivalries and trophies',
        icon: 'shield',
        accentColor: '#FF5500',
        questions: [
          QuizQuestion(
            id: 101,
            question: 'Which fixture is known as the Main Moscow Derby?',
            options: ['Spartak vs CSKA', 'Zenit vs Dynamo', 'Lokomotiv vs Rostov', 'Krasnodar vs Rubin'],
            correctIndex: 0,
            explanation: 'The classic battle between Spartak and CSKA is the Main Moscow Derby.',
            points: 100,
          ),
          QuizQuestion(
            id: 102,
            question: 'Which club is known as The Armymen?',
            options: ['The Bulls', 'The Gladiators', 'The Armymen', 'The Railwaymen'],
            correctIndex: 2,
            explanation: 'CSKA has historic military roots.',
            points: 100,
          ),
        ],
        words: [
          WordPuzzle(
            word: 'DERBY',
            hint: 'A clash between two local rivals',
            difficulty: 'Easy',
            points: 100,
          ),
        ],
      ),
    ];

    service.liveMatches = [
      LiveMatch(
        id: 'match_101',
        homeTeam: 'Zenit St. Petersburg',
        awayTeam: 'Spartak Moscow',
        homeScore: 2,
        awayScore: 1,
        minute: "68'",
        status: 'LIVE',
        stadium: 'Gazprom Arena, St. Petersburg',
        attendance: '51,200',
        possession: '58% - 42%',
        shotsOnTarget: '7 - 4',
        corners: '5 - 3',
        highlights: ["18' GOAL: Volley (1-0)", "41' GOAL: Counter (1-1)"],
        matchTrivia: 'Over 160 league clashes between these two clubs.',
      ),
    ];

    service.dailyChallenges = [
      DailyChallenge(
        id: 'daily_1',
        title: 'Matchday Trivia Master',
        description: 'Answer 5 trivia questions correctly',
        rewardPoints: 250,
        progressTarget: 5,
        icon: 'military_tech',
      ),
    ];

    service.loyaltyStore = [
      LoyaltyReward(
        id: 'reward_vip_pass',
        title: 'VIP Match Pass Badge',
        cost: 500,
        icon: 'confirmation_number',
        description: 'Digital VIP pass badge granting match center priority.',
      ),
    ];

    service.fanRanks = [
      FanRank(title: 'Rookie Supporter', minPoints: 0, perk: 'Standard access'),
      FanRank(title: 'Season Ticket Holder', minPoints: 500, perk: '+10% bonus points'),
    ];

    service.isLoaded = true;
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: child,
    );
  }

  group('Navigation & 4 Tabs Verification', () {
    testWidgets('MainStubScreen displays exactly 4 tabs and allows switching', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const MainStubScreen()));
      await tester.pumpAndSettle();

      // Verify BottomNavigationBar exists with 4 items
      final navBarFinder = find.byType(BottomNavigationBar);
      expect(navBarFinder, findsOneWidget);

      final navBar = tester.widget<BottomNavigationBar>(navBarFinder);
      expect(navBar.items.length, 4);
      expect(navBar.items[0].label, 'Match Center');
      expect(navBar.items[1].label, 'Quizzes');
      expect(navBar.items[2].label, 'Daily');
      expect(navBar.items[3].label, 'Loyalty');

      // Verify first tab (Match Center) is active
      expect(find.text('MATCH CENTER'), findsWidgets);

      // Switch to Quizzes tab (index 1)
      await tester.tap(find.text('Quizzes'));
      await tester.pumpAndSettle();
      expect(find.text('RPL QUIZ HUB'), findsOneWidget);

      // Switch to Daily tab (index 2)
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();
      expect(find.text('DAILY CHALLENGES'), findsOneWidget);

      // Switch to Loyalty tab (index 3)
      await tester.tap(find.text('Loyalty'));
      await tester.pumpAndSettle();
      expect(find.text('LOYALTY & PROFILE'), findsOneWidget);
    });
  });

  group('Overflow & RenderFlex Resilience on Diverse Screen Sizes', () {
    const testScreenSizes = [
      Size(320, 568), // Compact iPhone SE 1st gen
      Size(375, 667), // iPhone 8
      Size(390, 844), // Modern iPhone 13/14
      Size(412, 915), // Tall Android (Pixel 7)
      Size(768, 1024), // Tablet / iPad
    ];

    for (final size in testScreenSizes) {
      testWidgets('No RenderFlex overflow on screen size ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // 1. Test MatchCenterTab
        await tester.pumpWidget(buildTestableWidget(const MatchCenterTab()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'RenderFlex overflow in MatchCenterTab at $size');

        // 2. Test QuizHubTab
        await tester.pumpWidget(buildTestableWidget(const QuizHubTab()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'RenderFlex overflow in QuizHubTab at $size');

        // 3. Test DailyChallengesTab
        await tester.pumpWidget(buildTestableWidget(const DailyChallengesTab()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'RenderFlex overflow in DailyChallengesTab at $size');

        // 4. Test LoyaltyProfileTab
        await tester.pumpWidget(buildTestableWidget(const LoyaltyProfileTab()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'RenderFlex overflow in LoyaltyProfileTab at $size');
      });
    }
  });

  group('Interactive Subscreens Smoke & Logic Tests', () {
    testWidgets('QuizPlayScreen handles question answer selection and flow', (tester) async {
      final category = QuizService().categories.first;
      await tester.pumpWidget(buildTestableWidget(QuizPlayScreen(category: category)));
      await tester.pumpAndSettle();

      // Check question text is rendered
      expect(find.text('Which fixture is known as the Main Moscow Derby?'), findsOneWidget);
      expect(find.text('Spartak vs CSKA'), findsOneWidget);

      // Tap first option
      await tester.tap(find.text('Spartak vs CSKA'));
      await tester.pumpAndSettle();

      // Verify explanation appeared and Next button is active
      final nextBtn = find.text('Next Question');
      expect(nextBtn, findsOneWidget);

      // Scroll to Next Question button if needed and tap
      await tester.ensureVisible(nextBtn);
      await tester.pumpAndSettle();
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      // Verify question 2 appeared
      expect(find.text('Which club is known as The Armymen?'), findsOneWidget);
    });

    testWidgets('WordPuzzleScreen renders keyboard, letter boxes and accepts input', (tester) async {
      final words = QuizService().categories.first.words;
      await tester.pumpWidget(buildTestableWidget(WordPuzzleScreen(words: words)));
      await tester.pumpAndSettle();

      expect(find.text('Football Word Guesser'), findsOneWidget);
      expect(find.text('A clash between two local rivals'), findsOneWidget);

      // Tap key 'D'
      final keyD = find.widgetWithText(InkWell, 'D');
      expect(keyD, findsWidgets);
      await tester.tap(keyD.first);
      await tester.pumpAndSettle();

      // Verify no exception occurred
      expect(tester.takeException(), isNull);
    });
  });
}
