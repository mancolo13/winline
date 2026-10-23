import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winline/models/quiz_models.dart';
import 'package:winline/screens/main_stub_screen.dart';
import 'package:winline/screens/quiz_play_screen.dart';
import 'package:winline/screens/word_puzzle_screen.dart';
import 'package:winline/screens/tabs/match_center_tab.dart';
import 'package:winline/screens/tabs/quiz_hub_tab.dart';
import 'package:winline/screens/tabs/daily_challenges_tab.dart';
import 'package:winline/screens/tabs/loyalty_profile_tab.dart';
import 'package:winline/services/quiz_service.dart';
import 'package:winline/theme/app_theme.dart';

void main() {
  setUp(() async {
    // Populate QuizService with sample RPL data to guarantee offline determinism in tests
    final service = QuizService();
    service.categories = [
      QuizCategory(
        id: 'clubs_derbies',
        title: 'Клубы и Дерби РПЛ',
        description: 'Исторические противостояния и трофеи',
        icon: 'shield',
        accentColor: '#FF5500',
        questions: [
          QuizQuestion(
            id: 101,
            question: 'Какое противостояние называют Главным московским дерби?',
            options: ['Спартак vs ЦСКА', 'Зенит vs Динамо', 'Локомотив vs Ростов', 'Краснодар vs Рубин'],
            correctIndex: 0,
            explanation: 'Классическое сражение между Спартаком и ЦСКА — Главное московское дерби.',
            points: 100,
          ),
          QuizQuestion(
            id: 102,
            question: 'Какой клуб традиционно называют Армейцами?',
            options: ['Быки', 'Гладиаторы', 'Армейцы', 'Железнодорожники'],
            correctIndex: 2,
            explanation: 'ЦСКА имеет армейское историческое происхождение.',
            points: 100,
          ),
        ],
        words: [
          WordPuzzle(
            word: 'ДЕРБИ',
            hint: 'Принципиальный матч между двумя соперниками',
            difficulty: 'Легко',
            points: 100,
          ),
        ],
      ),
    ];

    service.liveMatches = [
      LiveMatch(
        id: 'match_101',
        homeTeam: 'Зенит Санкт-Петербург',
        awayTeam: 'Спартак Москва',
        homeScore: 2,
        awayScore: 1,
        minute: "68'",
        status: 'LIVE',
        stadium: 'Газпром Арена, Санкт-Петербург',
        attendance: '51 200',
        possession: '58% — 42%',
        shotsOnTarget: '7 — 4',
        corners: '5 — 3',
        highlights: ["18' ГОЛ (1:0)", "41' ГОЛ (1:1)"],
        matchTrivia: 'Более 160 матчей между этими клубами.',
      ),
    ];

    service.dailyChallenges = [
      DailyChallenge(
        id: 'daily_1',
        title: 'Знаток Матчдэя',
        description: 'Ответьте правильно на 5 вопросов',
        rewardPoints: 250,
        progressTarget: 5,
        icon: 'military_tech',
      ),
    ];

    service.loyaltyStore = [
      LoyaltyReward(
        id: 'reward_vip_pass',
        title: 'Бейдж VIP Матч-Пасс',
        cost: 500,
        icon: 'confirmation_number',
        description: 'Цифровой VIP-бейдж с приоритетом в матч-центре.',
      ),
    ];

    service.fanRanks = [
      FanRank(title: 'Новичок Трибун', minPoints: 0, perk: 'Стандартный доступ'),
      FanRank(title: 'Владелец Абонемента', minPoints: 500, perk: '+10% бонусных очков'),
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
      expect(navBar.items[0].label, 'Матч-центр');
      expect(navBar.items[1].label, 'Викторины');
      expect(navBar.items[2].label, 'Задания');
      expect(navBar.items[3].label, 'Лояльность');

      // Verify first tab (Match Center) is active
      expect(find.text('МАТЧ-ЦЕНТР'), findsWidgets);

      // Switch to Quizzes tab (index 1)
      await tester.tap(find.text('Викторины'));
      await tester.pumpAndSettle();
      expect(find.text('ВИКТОРИНЫ РПЛ'), findsOneWidget);

      // Switch to Daily tab (index 2)
      await tester.tap(find.text('Задания'));
      await tester.pumpAndSettle();
      expect(find.text('ЕЖЕДНЕВНЫЕ ЗАДАНИЯ'), findsOneWidget);

      // Switch to Loyalty tab (index 3)
      await tester.tap(find.text('Лояльность'));
      await tester.pumpAndSettle();
      expect(find.text('ЛОЯЛЬНОСТЬ И ПРОФИЛЬ'), findsOneWidget);
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
      expect(find.text('Какое противостояние называют Главным московским дерби?'), findsOneWidget);
      expect(find.text('Спартак vs ЦСКА'), findsOneWidget);

      // Tap first option
      await tester.tap(find.text('Спартак vs ЦСКА'));
      await tester.pumpAndSettle();

      // Verify explanation appeared and Next button is active
      final nextBtn = find.text('Следующий вопрос');
      expect(nextBtn, findsOneWidget);

      // Scroll to Next Question button if needed and tap
      await tester.ensureVisible(nextBtn);
      await tester.pumpAndSettle();
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      // Verify question 2 appeared
      expect(find.text('Какой клуб традиционно называют Армейцами?'), findsOneWidget);
    });

    testWidgets('WordPuzzleScreen renders keyboard, letter boxes and accepts input', (tester) async {
      final words = QuizService().categories.first.words;
      await tester.pumpWidget(buildTestableWidget(WordPuzzleScreen(words: words)));
      await tester.pumpAndSettle();

      expect(find.text('Футбольные Слова'), findsOneWidget);
      expect(find.text('Принципиальный матч между двумя соперниками'), findsOneWidget);

      // Tap Cyrillic key 'Д'
      final keyD = find.widgetWithText(InkWell, 'Д');
      expect(keyD, findsWidgets);
      await tester.tap(keyD.first);
      await tester.pumpAndSettle();

      // Verify no exception occurred
      expect(tester.takeException(), isNull);
    });
  });
}
