import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/quiz_service.dart';
import '../../theme/app_theme.dart';

class LoyaltyProfileTab extends StatelessWidget {
  const LoyaltyProfileTab({super.key});

  IconData _getRewardIcon(String iconName) {
    switch (iconName) {
      case 'confirmation_number':
        return Icons.confirmation_number_rounded;
      case 'sports_soccer':
        return Icons.sports_soccer_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'wb_incandescent':
        return Icons.wb_incandescent_rounded;
      case 'military_tech':
        return Icons.military_tech_rounded;
      default:
        return Icons.card_giftcard_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizService = QuizService();

    return AnimatedBuilder(
      animation: quizService,
      builder: (context, _) {
        final currentRank = quizService.currentRank;
        final nextRank = quizService.nextRank;
        final progress = quizService.progressToNextRank;
        final unlocked = quizService.unlockedRewardIds;
        final storeItems = quizService.loyaltyStore;

        final totalQuestions = quizService.questionsCorrect + (quizService.quizzesPlayed * 3);
        final accuracy = totalQuestions > 0
            ? ((quizService.questionsCorrect / totalQuestions) * 100).toInt()
            : 85;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: Text(
              'LOYALTY & PROFILE',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Fan Rank Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E1700), Color(0xFF141924)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primary, width: 1.5),
                      boxShadow: AppTheme.orangeGlow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primary.withAlpha(35),
                                border: Border.all(color: AppTheme.primary, width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Image.asset(
                                  'assets/logo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.workspace_premium_rounded,
                                    color: AppTheme.accentGold,
                                    size: 32,
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
                                    currentRank.title.toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentRank.perk,
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
                        const SizedBox(height: 16),

                        // Balance Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primary.withAlpha(50)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Loyalty Balance',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
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
                                  const Icon(Icons.stars_rounded, color: AppTheme.accentGold, size: 22),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${quizService.loyaltyPoints} PTS',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.accentGold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Rank Progress
                        if (nextRank != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Next Tier: ${nextRank.title}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${quizService.loyaltyPoints} / ${nextRank.minPoints} pts',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: AppTheme.surfaceElevated,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Maximum Fan Rank Reached!',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentEmerald,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Career Statistics
                  Text(
                    'FAN CAREER STATISTICS',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatCard('Quizzes', '${quizService.quizzesPlayed}', Icons.quiz_rounded),
                      const SizedBox(width: 10),
                      _buildStatCard('Correct', '${quizService.questionsCorrect}', Icons.check_circle_rounded),
                      const SizedBox(width: 10),
                      _buildStatCard('Accuracy', '$accuracy%', Icons.track_changes_rounded),
                      const SizedBox(width: 10),
                      _buildStatCard('Words', '${quizService.wordsSolved}', Icons.spellcheck_rounded),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Fan Shop / Loyalty Rewards Store
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'LOYALTY FAN SHOP',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textMuted,
                            letterSpacing: 1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${unlocked.length} of ${storeItems.length} Owned',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Store Items
                  ...storeItems.map((item) {
                    final isOwned = unlocked.contains(item.id);
                    final canAfford = quizService.loyaltyPoints >= item.cost;
                    final iconData = _getRewardIcon(item.icon);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isOwned
                              ? AppTheme.accentEmerald.withAlpha(90)
                              : AppTheme.surfaceBorder,
                        ),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOwned
                                  ? AppTheme.accentEmerald.withAlpha(25)
                                  : AppTheme.primary.withAlpha(25),
                            ),
                            child: Icon(
                              iconData,
                              color: isOwned ? AppTheme.accentEmerald : AppTheme.primary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.description,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.stars_rounded, color: AppTheme.accentGold, size: 16),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '${item.cost} Points',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.accentGold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (isOwned)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.accentEmerald.withAlpha(30),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.accentEmerald),
                              ),
                              child: Text(
                                'Unlocked',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentEmerald,
                                ),
                              ),
                            )
                          else
                            ElevatedButton(
                              onPressed: canAfford
                                  ? () {
                                      final success = quizService.purchaseReward(item);
                                      if (success) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Unlocked "${item.title}" successfully!',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            backgroundColor: AppTheme.accentEmerald,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                disabledBackgroundColor: AppTheme.surfaceElevated,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Redeem',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: canAfford ? Colors.white : AppTheme.textMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // Reset Progress Option
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _confirmReset(context, quizService),
                      icon: const Icon(Icons.restart_alt_rounded, size: 18, color: AppTheme.textMuted),
                      label: Text(
                        'Reset Fan Career Data',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppTheme.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, QuizService quizService) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: Text(
          'Reset Fan Progress?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        content: Text(
          'This will reset your points balance, quizzes played, and claimed daily rewards.',
          style: GoogleFonts.inter(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              quizService.resetProgress();
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRose),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
