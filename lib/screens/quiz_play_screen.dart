import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz_models.dart';
import '../services/quiz_service.dart';
import '../theme/app_theme.dart';

class QuizPlayScreen extends StatefulWidget {
  final QuizCategory category;

  const QuizPlayScreen({super.key, required this.category});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _correctCount = 0;
  int _pointsEarned = 0;

  List<QuizQuestion> get _questions => widget.category.questions;

  void _chooseOption(int index) {
    if (_answered) return;

    setState(() {
      _selectedOption = index;
      _answered = true;

      final currentQ = _questions[_currentIndex];
      if (index == currentQ.correctIndex) {
        _correctCount++;
        _pointsEarned += currentQ.points;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      // Quiz finished
      QuizService().recordQuizCompleted(
        correctAnswers: _correctCount,
        pointsGained: _pointsEarned,
      );
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    final total = _questions.length;
    final percent = total > 0 ? ((_correctCount / total) * 100).toInt() : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.surfaceBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withAlpha(35),
                  boxShadow: AppTheme.orangeGlow,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppTheme.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Викторина завершена!',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Правильных ответов: $_correctCount из $total ($percent%)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: AppTheme.accentGold, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '+$_pointsEarned очков лояльности',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Вернуться в меню',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: Text(widget.category.title)),
        body: const Center(
          child: Text(
            'No questions available in this category yet.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          widget.category.title,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Текущие очки в игре'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, color: AppTheme.accentGold, size: 18),
                const SizedBox(width: 4),
                Text(
                  '+${question.points} баллов',
                  style: GoogleFonts.inter(
                    fontSize: 12,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Вопрос ${_currentIndex + 1} из ${_questions.length}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    'Верно: $_correctCount',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  minHeight: 8,
                  backgroundColor: AppTheme.surfaceCard,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
              const SizedBox(height: 20),

              // Question Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceBorder),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ВОПРОС ТУРА',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question.question,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Options List
              ...List.generate(question.options.length, (index) {
                final optionText = question.options[index];
                final isSelected = _selectedOption == index;
                final isCorrect = index == question.correctIndex;

                Color cardBg = AppTheme.surfaceCard;
                Color borderColor = AppTheme.surfaceBorder;
                Color textColor = AppTheme.textPrimary;
                Widget? trailingIcon;

                if (_answered) {
                  if (isCorrect) {
                    cardBg = AppTheme.accentEmerald.withAlpha(35);
                    borderColor = AppTheme.accentEmerald;
                    textColor = Colors.white;
                    trailingIcon = const Icon(Icons.check_circle_rounded, color: AppTheme.accentEmerald);
                  } else if (isSelected) {
                    cardBg = AppTheme.accentRose.withAlpha(35);
                    borderColor = AppTheme.accentRose;
                    textColor = Colors.white;
                    trailingIcon = const Icon(Icons.cancel_rounded, color: AppTheme.accentRose);
                  }
                } else if (isSelected) {
                  cardBg = AppTheme.primary.withAlpha(40);
                  borderColor = AppTheme.primary;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: _answered ? null : () => _chooseOption(index),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.surfaceElevated,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              optionText,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                          ?trailingIcon,
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Explanation Box if answered
              if (_answered) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedOption == question.correctIndex
                          ? AppTheme.accentEmerald.withAlpha(80)
                          : AppTheme.primary.withAlpha(80),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _selectedOption == question.correctIndex
                            ? Icons.lightbulb_rounded
                            : Icons.info_outline_rounded,
                        color: _selectedOption == question.correctIndex
                            ? AppTheme.accentEmerald
                            : AppTheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          question.explanation,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    _currentIndex < _questions.length - 1 ? 'Следующий вопрос' : 'Посмотреть результаты',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
