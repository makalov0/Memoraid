import 'package:flutter/material.dart';

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
  late AnimationController _flipController;
  late AnimationController _slideController;
  late Animation<double> _flipAnimation;
  late Animation<Offset> _slideAnimation;

  // Sample flashcard data for different categories
  Map<String, List<Flashcard>> flashcardData = {
    'Travel': [
      Flashcard(question: 'Capital of France', answer: 'Paris'),
      Flashcard(question: 'Largest ocean', answer: 'Pacific Ocean'),
      Flashcard(question: 'Longest river', answer: 'Nile River'),
      Flashcard(question: 'Highest mountain', answer: 'Mount Everest'),
      Flashcard(question: 'Smallest country', answer: 'Vatican City'),
    ],
    'Animal': [
      Flashcard(question: 'Largest mammal', answer: 'Blue Whale'),
      Flashcard(question: 'Fastest land animal', answer: 'Cheetah'),
      Flashcard(question: 'Animal with longest neck', answer: 'Giraffe'),
      Flashcard(question: 'Largest bird', answer: 'Ostrich'),
      Flashcard(question: 'Animal that never sleeps', answer: 'Bullfrog'),
    ],
    'Job': [
      Flashcard(question: 'Treats sick people', answer: 'Doctor'),
      Flashcard(question: 'Teaches students', answer: 'Teacher'),
      Flashcard(question: 'Puts out fires', answer: 'Firefighter'),
      Flashcard(question: 'Flies airplanes', answer: 'Pilot'),
      Flashcard(question: 'Designs buildings', answer: 'Architect'),
    ],
    'CRC': [
      Flashcard(question: 'What does CRC stand for?', answer: 'Cyclic Redundancy Check'),
      Flashcard(question: 'CRC is used for?', answer: 'Error Detection'),
      Flashcard(question: 'CRC polynomial degree', answer: 'Depends on standard'),
      Flashcard(question: 'Common CRC-32 polynomial', answer: '0x04C11DB7'),
      Flashcard(question: 'CRC remainder size', answer: 'Same as polynomial degree'),
    ],
    'Read': [
      Flashcard(question: 'Author of Harry Potter', answer: 'J.K. Rowling'),
      Flashcard(question: 'Shakespeare\'s famous play', answer: 'Romeo and Juliet'),
      Flashcard(question: 'First book in Narnia series', answer: 'The Lion, the Witch and the Wardrobe'),
      Flashcard(question: 'Author of 1984', answer: 'George Orwell'),
      Flashcard(question: 'Longest book in Bible', answer: 'Psalms'),
    ],
    'Food': [
      Flashcard(question: 'Main ingredient in bread', answer: 'Flour'),
      Flashcard(question: 'Spice that makes food yellow', answer: 'Turmeric'),
      Flashcard(question: 'Fruit high in Vitamin C', answer: 'Orange'),
      Flashcard(question: 'National dish of Italy', answer: 'Pizza/Pasta'),
      Flashcard(question: 'Sweetest natural substance', answer: 'Honey'),
    ],
  };

  List<Flashcard> currentFlashcards = [];

  @override
  void initState() {
    super.initState();
    currentFlashcards = flashcardData[widget.category] ?? [];
    
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
      }
    });
    
    _slideController.reset();
    _flipController.reset();
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
      body: gameCompleted ? _buildGameCompleted() : _buildGameContent(),
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
          Text(
            currentFlashcards[currentIndex].answer,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
            textAlign: TextAlign.center,
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
    double percentage = (score / totalAnswered * 100);
    
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

class Flashcard {
  final String question;
  final String answer;

  Flashcard({
    required this.question,
    required this.answer,
  });
}