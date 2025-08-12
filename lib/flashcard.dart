import 'package:flutter/material.dart';

import 'api_service.dart';
import 'models.dart';

class FlashcardGame extends StatefulWidget {
  final String category;
  final Color categoryColor;
  final IconData categoryIcon;

  const FlashcardGame({
    Key? key,
    required this.category,
    required this.categoryColor,
    required this.categoryIcon,
  }) : super(key: key);

  @override
  _FlashcardGameState createState() => _FlashcardGameState();
}

class _FlashcardGameState extends State<FlashcardGame>
    with TickerProviderStateMixin {
  int currentIndex = 0;
  bool showAnswer = false;
  int score = 0;
  int totalAnswered = 0;
  bool gameCompleted = false;
  bool isLoading = true;
  String errorMessage = '';
  int? categoryId;
  int? userId;
  
  late AnimationController _flipController;
  late AnimationController _slideController;
  late Animation<double> _flipAnimation;
  late Animation<Offset> _slideAnimation;

  // Replace hardcoded data with dynamic lists
  List<QuizCard> currentFlashcards = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadGameData();
  }

  void _initializeAnimations() {
    _flipController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadGameData() async {
    try {
      // Get user session
      final session = await ApiService.getUserSession();
      if (!session['isLoggedIn']) {
        setState(() {
          errorMessage = 'Please log in to play';
          isLoading = false;
        });
        return;
      }
      userId = session['user_id'];

      // Get category by name
      final categoryResponse = await ApiService.getCategoryByName(widget.category);
      if (!categoryResponse['success']) {
        setState(() {
          errorMessage = categoryResponse['message'];
          isLoading = false;
        });
        return;
      }

      categoryId = categoryResponse['category']['id'];

      // Get study cards for this category
      final cardsResponse = await ApiService.getStudyCards(categoryId!);
      if (!cardsResponse['success']) {
        setState(() {
          errorMessage = cardsResponse['message'];
          isLoading = false;
        });
        return;
      }

      // Convert StudyCard to QuizCard format (word as question, definition as answer)
      final cardsList = cardsResponse['cards'] as List;
      currentFlashcards = cardsList.map((card) => QuizCard(
        id: card['id'],
        question: card['word'],
        answer: card['definition'],
      )).toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading game: $e';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (!showAnswer) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  void _nextCard({required bool isCorrect}) async {
    // Save progress to database
    if (userId != null) {
      await ApiService.saveCardProgress(
        userId: userId!,
        cardId: currentFlashcards[currentIndex].id,
        remembered: isCorrect,
      );
    }

    if (isCorrect) {
      score++;
    }
    totalAnswered++;
    
    await _slideController.forward();
    
    setState(() {
      if (currentIndex < currentFlashcards.length - 1) {
        currentIndex++;
        showAnswer = false;
      } else {
        gameCompleted = true;
        _saveSession();
      }
    });
    
    _slideController.reset();
    _flipController.reset();
  }

  Future<void> _saveSession() async {
    if (userId != null && categoryId != null) {
      await ApiService.saveStudySession(
        userId: userId!,
        categoryId: categoryId!,
        totalCards: currentFlashcards.length,
        rememberedCount: score,
      );
    }
  }

  void _restartGame() {
    setState(() {
      currentIndex = 0;
      showAnswer = false;
      score = 0;
      totalAnswered = 0;
      gameCompleted = false;
    });
    _flipController.reset();
    _slideController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F4FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Row(
          children: [
            Icon(widget.categoryIcon, color: Colors.grey[700]),
            SizedBox(width: 8),
            Text(
              '${widget.category} Flashcards',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: isLoading ? _buildLoading() : (errorMessage.isNotEmpty ? _buildError() : (gameCompleted ? _buildGameCompleted() : _buildGameContent())),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: widget.categoryColor),
          SizedBox(height: 20),
          Text(
            'Loading flashcards...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = '';
              });
              _loadGameData();
            },
            child: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.categoryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    if (currentFlashcards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 20),
            Text(
              'No flashcards available for ${widget.category}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Progress Bar
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Card ${currentIndex + 1} of ${currentFlashcards.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      'Score: $score/$totalAnswered',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (currentIndex + 1) / currentFlashcards.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(widget.categoryColor),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          
          // Flashcard
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_flipAnimation.value * 3.14159),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: _flipAnimation.value < 0.5
                            ? _buildQuestionSide()
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(3.14159),
                                child: _buildAnswerSide(),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          SizedBox(height: 30),
          
          // Action Buttons
          if (showAnswer) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _nextCard(isCorrect: false),
                    icon: Icon(Icons.close),
                    label: Text('Incorrect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _nextCard(isCorrect: true),
                    icon: Icon(Icons.check),
                    label: Text('Correct'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _flipCard,
                icon: Icon(Icons.flip_to_back),
                label: Text('Show Answer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.categoryColor,
                  foregroundColor: Colors.grey[800],
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionSide() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.help_outline,
            size: 60,
            color: widget.categoryColor,
          ),
          SizedBox(height: 30),
          Text(
            'Question',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20),
          Text(
            currentFlashcards[currentIndex].question,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          Text(
            'Tap to reveal answer',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSide() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 60,
            color: Colors.orange,
          ),
          SizedBox(height: 30),
          Text(
            'Answer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              currentFlashcards[currentIndex].answer,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 40),
          Text(
            'Did you get it right?',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCompleted() {
    double percentage = totalAnswered > 0 ? (score / totalAnswered * 100) : 0;
    
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  percentage >= 70 ? Icons.emoji_events : Icons.thumb_up,
                  size: 80,
                  color: percentage >= 70 ? Colors.amber : Colors.blue,
                ),
                SizedBox(height: 20),
                Text(
                  percentage >= 70 ? 'Excellent!' : 'Good Job!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'You scored',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '$score out of $totalAnswered',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.home),
                  label: Text('Back to Categories'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _restartGame,
                  icon: Icon(Icons.refresh),
                  label: Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.categoryColor,
                    foregroundColor: Colors.grey[800],
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// QuizCard class for the flashcard game
class QuizCard {
  final int id;
  final String question;
  final String answer;

  QuizCard({
    required this.id,
    required this.question,
    required this.answer,
  });
}

// Keep your existing Flashcard class for backward compatibility if needed
class Flashcard {
  final String question;
  final String answer;

  Flashcard({
    required this.question,
    required this.answer,
  });
}