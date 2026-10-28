import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/quiz_models.dart';
import '../../services/quiz_service.dart';
import '../../theme/app_theme.dart';

class MatchCenterTab extends StatefulWidget {
  const MatchCenterTab({super.key});

  @override
  State<MatchCenterTab> createState() => _MatchCenterTabState();
}

class _MatchCenterTabState extends State<MatchCenterTab> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final quizService = QuizService();

    return AnimatedBuilder(
      animation: quizService,
      builder: (context, _) {
        final allMatches = quizService.liveMatches;
        final filteredMatches = allMatches.where((m) {
          if (_selectedFilter == 'ALL') return true;
          return m.status.toUpperCase() == _selectedFilter;
        }).toList();

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accentEmerald,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'МАТЧ-ЦЕНТР',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Баллы лояльности: ${quizService.loyaltyPoints}'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: AppTheme.accentGold, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '${quizService.loyaltyPoints}',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Matchweek Live Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF241408), Color(0xFF141924)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primary.withAlpha(80)),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppTheme.orangeGlow,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppTheme.primary.withAlpha(35),
                                child: const Icon(
                                  Icons.sports_soccer_rounded,
                                  color: AppTheme.primary,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ПРЕМЬЕР-ЛИГА',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Матч-центр и статистика тура',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Следи за играми, делай прогнозы и получай баллы',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('ALL', 'Все матчи'),
                        _buildFilterChip('LIVE', 'Прямой эфир'),
                        _buildFilterChip('UPCOMING', 'Предстоящие'),
                        _buildFilterChip('FINISHED', 'Завершенные'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Match Cards
                  if (filteredMatches.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Text(
                        'Матчей по данному фильтру не найдено.',
                        style: GoogleFonts.inter(color: AppTheme.textSecondary),
                      ),
                    )
                  else
                    ...filteredMatches.map((match) => _buildMatchCard(context, match, quizService)),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String filterId, String label) {
    final isSelected = _selectedFilter == filterId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedFilter = filterId;
          });
        },
        selectedColor: AppTheme.primary,
        backgroundColor: AppTheme.surfaceCard,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : AppTheme.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppTheme.primary : AppTheme.surfaceBorder,
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, LiveMatch match, QuizService quizService) {
    final isLive = match.status == 'LIVE';
    final isFinished = match.status == 'FINISHED';

    Color statusColor = AppTheme.accentGold;
    if (isLive) statusColor = AppTheme.accentEmerald;
    if (isFinished) statusColor = AppTheme.textMuted;

    String displayStatus = match.status;
    if (isLive) {
      displayStatus = 'ЭФИР • ${match.minute}';
    } else if (isFinished) {
      displayStatus = 'ЗАВЕРШЕН';
    } else if (match.status == 'UPCOMING') {
      displayStatus = 'СКОРО';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLive ? AppTheme.primary.withAlpha(90) : AppTheme.surfaceBorder,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: InkWell(
        onTap: () => _showMatchDetails(context, match, quizService),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header: Status tag & Stadium
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLive) ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.accentEmerald,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          displayStatus,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Text(
                      match.stadium,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Teams & Scores
              Row(
                children: [
                  // Home Team
                  Expanded(
                    child: Text(
                      match.homeTeam,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Score / Time Center
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Text(
                      isFinished || isLive
                          ? '${match.homeScore} : ${match.awayScore}'
                          : match.minute,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isLive ? AppTheme.primary : AppTheme.textPrimary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Away Team
                  Expanded(
                    child: Text(
                      match.awayTeam,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Footer: Quick stats summary & Action
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Владение: ${match.possession}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Матч и прогноз',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.primary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMatchDetails(BuildContext context, LiveMatch match, QuizService quizService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final userPrediction = quizService.userPredictions[match.id];

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Teams Match Header
                    Text(
                      '${match.homeTeam} vs ${match.awayTeam}',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${match.stadium} • ${match.attendance}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Match Predictor Widget
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.primary.withAlpha(60)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.psychology_rounded, color: AppTheme.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Прогноз на матч (+50 баллов)',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildPredictButton(
                                label: '1 (Хозяева)',
                                choice: 'HOME',
                                currentChoice: userPrediction,
                                onSelect: () {
                                  quizService.setMatchPrediction(match.id, 'HOME');
                                  setModalState(() {});
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildPredictButton(
                                label: 'X (Ничья)',
                                choice: 'DRAW',
                                currentChoice: userPrediction,
                                onSelect: () {
                                  quizService.setMatchPrediction(match.id, 'DRAW');
                                  setModalState(() {});
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildPredictButton(
                                label: '2 (Гости)',
                                choice: 'AWAY',
                                currentChoice: userPrediction,
                                onSelect: () {
                                  quizService.setMatchPrediction(match.id, 'AWAY');
                                  setModalState(() {});
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Key Stats
                    Text(
                      'СТАТИСТИКА МАТЧА',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStatRow('Владение мячом', match.possession),
                    _buildStatRow('Удары в створ', match.shotsOnTarget),
                    _buildStatRow('Угловые', match.corners),
                    const SizedBox(height: 18),

                    // Match Incidents Timeline
                    Text(
                      'ХРОНИКА СОБЫТИЙ',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...match.highlights.map((event) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.circle, size: 8, color: AppTheme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                event,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 18),

                    // Trivia Note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.primary.withAlpha(50)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: AppTheme.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              match.matchTrivia,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPredictButton({
    required String label,
    required String choice,
    required String? currentChoice,
    required VoidCallback onSelect,
  }) {
    final isSelected = currentChoice == choice;
    return Expanded(
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.surfaceBorder,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
          Text(val, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
