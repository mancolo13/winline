import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz_models.dart';
import '../services/quiz_service.dart';
import '../theme/app_theme.dart';

class WordPuzzleScreen extends StatefulWidget {
  final List<WordPuzzle> words;

  const WordPuzzleScreen({super.key, required this.words});

  @override
  State<WordPuzzleScreen> createState() => _WordPuzzleScreenState();
}

class _WordPuzzleScreenState extends State<WordPuzzleScreen> {
  int _wordIndex = 0;
  final Set<String> _guessedLetters = {};
  int _remainingLives = 5;
  int _totalPointsEarned = 0;
  bool _isWordSolved = false;
  bool _isGameOver = false;

  WordPuzzle get _currentPuzzle => widget.words[_wordIndex];
  String get _targetWord => _currentPuzzle.word.toUpperCase();

  void _onLetterPressed(String letter) {
    if (_isWordSolved || _isGameOver || _guessedLetters.contains(letter)) return;

    setState(() {
      _guessedLetters.add(letter);

      if (!_targetWord.contains(letter)) {
        _remainingLives--;
        if (_remainingLives <= 0) {
          _isGameOver = true;
        }
      } else {
        // Check if all letters are revealed
        bool allRevealed = true;
        for (int i = 0; i < _targetWord.length; i++) {
          final char = _targetWord[i];
          if (char != ' ' && char != '-' && !_guessedLetters.contains(char)) {
            allRevealed = false;
            break;
          }
        }
        if (allRevealed) {
          _isWordSolved = true;
          _totalPointsEarned += _currentPuzzle.points;
          QuizService().recordWordSolved(_currentPuzzle.points);
        }
      }
    });
  }

  void _nextWord() {
    if (_wordIndex < widget.words.length - 1) {
      setState(() {
        _wordIndex++;
        _guessedLetters.clear();
        _remainingLives = 5;
        _isWordSolved = false;
        _isGameOver = false;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _restartCurrent() {
    setState(() {
      _guessedLetters.clear();
      _remainingLives = 5;
      _isWordSolved = false;
      _isGameOver = false;
    });
  }

  void _showCompletionDialog() {
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
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withAlpha(35),
                  boxShadow: AppTheme.orangeGlow,
                ),
                child: const Icon(
                  Icons.spellcheck_rounded,
                  color: AppTheme.primary,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Все слова отгаданы!',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Вы успешно отгадали все футбольные термины тура!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: AppTheme.accentGold, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '+$_totalPointsEarned очков лояльности',
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
    if (widget.words.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Футбольные Слова')),
        body: const Center(
          child: Text(
            'Слова для игры пока не добавлены.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    final bool isRussian = RegExp(r'[А-ЯЁ]').hasMatch(_targetWord);
    final keyboardRows = isRussian
        ? [
            ['Й', 'Ц', 'У', 'К', 'Е', 'Н', 'Г', 'Ш', 'Щ', 'З', 'Х', 'Ъ'],
            ['Ф', 'Ы', 'В', 'А', 'П', 'Р', 'О', 'Л', 'Д', 'Ж', 'Э'],
            ['Я', 'Ч', 'С', 'М', 'И', 'Т', 'Ь', 'Б', 'Ю'],
          ]
        : [
            ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
            ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
            ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
          ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Футбольные Слова',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
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
                  '+${_currentPuzzle.points} pts',
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Word index & Lives
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Слово ${_wordIndex + 1} из ${widget.words.length}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: Icon(
                          index < _remainingLives
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: index < _remainingLives
                              ? AppTheme.accentRose
                              : AppTheme.textMuted,
                          size: 20,
                        ),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Clue Container
              Container(
                padding: const EdgeInsets.all(16),
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
                            'ПОДСКАЗКА',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _currentPuzzle.difficulty.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _currentPuzzle.hint,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Target Word Letter Boxes (Wrapped to prevent overflow)
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 8,
                  children: List.generate(_targetWord.length, (index) {
                    final char = _targetWord[index];
                    final isSpace = char == ' ';
                    final isSpecial = char == '-';
                    final isRevealed = _guessedLetters.contains(char) || _isWordSolved;

                    if (isSpace) {
                      return const SizedBox(width: 14);
                    }

                    return Container(
                      width: 36,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isRevealed
                            ? AppTheme.primary.withAlpha(40)
                            : AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isRevealed ? AppTheme.primary : AppTheme.surfaceBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        (isRevealed || isSpecial) ? char : '',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isRevealed ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 18),

              // Status Banner (Success or Out of Lives)
              if (_isWordSolved) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentEmerald.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentEmerald),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppTheme.accentEmerald),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Верно! +${_currentPuzzle.points} баллов!',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _nextWord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentEmerald,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Следующее', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ] else if (_isGameOver) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRose.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentRose),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cancel_rounded, color: AppTheme.accentRose),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Слово было: $_targetWord',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _restartCurrent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentRose,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Заново', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Virtual Keyboard (Scaled cleanly with FittedBox to prevent any overflow)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: keyboardRows.map((row) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: row.map((letter) {
                            final isGuessed = _guessedLetters.contains(letter);
                            final isCorrect = isGuessed && _targetWord.contains(letter);
                            final isWrong = isGuessed && !_targetWord.contains(letter);

                            Color keyBg = AppTheme.surfaceCard;
                            Color keyColor = AppTheme.textPrimary;
                            if (isCorrect) {
                              keyBg = AppTheme.accentEmerald.withAlpha(60);
                              keyColor = Colors.white;
                            } else if (isWrong) {
                              keyBg = AppTheme.surfaceBorder.withAlpha(40);
                              keyColor = AppTheme.textMuted;
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
                              child: InkWell(
                                onTap: isGuessed || _isWordSolved || _isGameOver
                                    ? null
                                    : () => _onLetterPressed(letter),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  width: isRussian ? 24 : 28,
                                  height: 42,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: keyBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isGuessed
                                          ? Colors.transparent
                                          : AppTheme.surfaceBorder,
                                    ),
                                  ),
                                  child: Text(
                                    letter,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: keyColor,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
