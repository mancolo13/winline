import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/quiz_service.dart';
import '../theme/app_theme.dart';
import 'tabs/match_center_tab.dart';
import 'tabs/quiz_hub_tab.dart';
import 'tabs/daily_challenges_tab.dart';
import 'tabs/loyalty_profile_tab.dart';

class MainStubScreen extends StatefulWidget {
  const MainStubScreen({super.key});

  @override
  State<MainStubScreen> createState() => _MainStubScreenState();
}

class _MainStubScreenState extends State<MainStubScreen> {
  int _currentIndex = 0;
  late bool _isLoading;

  final List<Widget> _tabs = const [
    MatchCenterTab(),
    QuizHubTab(),
    DailyChallengesTab(),
    LoyaltyProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _isLoading = !QuizService().isLoaded;
    if (_isLoading) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    await QuizService().init();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(color: AppTheme.surfaceBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: AppTheme.surface,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textMuted,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_soccer_rounded),
              activeIcon: Icon(Icons.sports_soccer_rounded, color: AppTheme.primary),
              label: 'Match Center',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.quiz_rounded),
              activeIcon: Icon(Icons.quiz_rounded, color: AppTheme.primary),
              label: 'Quizzes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_rounded),
              activeIcon: Icon(Icons.emoji_events_rounded, color: AppTheme.primary),
              label: 'Daily',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.stars_rounded),
              activeIcon: Icon(Icons.stars_rounded, color: AppTheme.primary),
              label: 'Loyalty',
            ),
          ],
        ),
      ),
    );
  }
}
