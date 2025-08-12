import 'package:flutter/material.dart';

import 'api_service.dart';
import 'models.dart';

class QuizletFlashcardGame extends StatefulWidget {
  final String category;
  final Color categoryColor;
  final IconData categoryIcon;

  const QuizletFlashcardGame({
    Key? key,
    required this.category,
    required this.categoryColor,
    required this.categoryIcon,
  }) : super(key: key);

  @override
  _QuizletFlashcardGameState createState() => _QuizletFlashcardGameState();
}

class _QuizletFlashcardGameState extends State<QuizletFlashcardGame>
    with TickerProviderStateMixin {
  int currentIndex = 0;
  bool showDefinition = false;
  int rememberedCount = 0;
  int notRememberedCount = 0;
  bool gameCompleted = false;
  bool isLoading = true;
  String errorMessage = '';
  int? categoryId;
  int? userId;
  
  late AnimationController _flipController;
  late AnimationController _swipeController;
  late Animation<double> _flipAnimation;
  late Animation<Offset> _swipeAnimation;
  double _dragDistance = 0.0;
  bool _isDragging = false;

  // Replace hardcoded data with dynamic lists
  List<StudyCard> currentCards = [];
  List<StudyCard> rememberedCards = [];
  List<StudyCard> notRememberedCards = [];

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
    
    _swipeController = AnimationController(
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
    
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
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

      // Convert JSON to StudyCard objects
      final cardsList = cardsResponse['cards'] as List;
      currentCards = cardsList.map((card) => StudyCard.fromJson(card)).toList();

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
    _swipeController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (!showDefinition) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      showDefinition = !showDefinition;
    });
  }

  void _handleSwipe(bool remember) async {
    final currentCard = currentCards[currentIndex];
    
    // Save progress to database
    if (userId != null) {
      await ApiService.saveCardProgress(
        userId: userId!,
        cardId: currentCard.id,
        remembered: remember,
      );
    }
    
    if (remember) {
      rememberedCards.add(currentCard);
      rememberedCount++;
    } else {
      notRememberedCards.add(currentCard);
      notRememberedCount++;
    }
    
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: remember ? Offset(1.5, 0.0) : Offset(-1.5, 0.0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeInOut,
    ));
    
    await _swipeController.forward();
    
    setState(() {
      if (currentIndex < currentCards.length - 1) {
        currentIndex++;
        showDefinition = false;
      } else {
        gameCompleted = true;
        _saveSession();
      }
    });
    
    _swipeController.reset();
    _flipController.reset();
  }

  Future<void> _saveSession() async {
    if (userId != null && categoryId != null) {
      await ApiService.saveStudySession(
        userId: userId!,
        categoryId: categoryId!,
        totalCards: currentCards.length,
        rememberedCount: rememberedCount,
      );
    }
  }

  void _restartGame() {
    setState(() {
      currentIndex = 0;
      showDefinition = false;
      rememberedCount = 0;
      notRememberedCount = 0;
      gameCompleted = false;
      rememberedCards.clear();
      notRememberedCards.clear();
    });
    _flipController.reset();
    _swipeController.reset();
  }

  void _studyAgain() {
    setState(() {
      currentCards = List.from(notRememberedCards);
      currentIndex = 0;
      showDefinition = false;
      rememberedCount = 0;
      notRememberedCount = 0;
      gameCompleted = false;
      rememberedCards.clear();
      notRememberedCards.clear();
    });
    _flipController.reset();
    _swipeController.reset();
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
              '${widget.category} Study Cards',
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
            'Loading study cards...',
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
    if (currentCards.isEmpty) {
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
              'No study cards available for ${widget.category}',
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
          // Progress and Stats
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
                      '${currentIndex + 1} / ${currentCards.length}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        Text(
                          ' $rememberedCount',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.cancel, color: Colors.red, size: 16),
                        Text(
                          ' $notRememberedCount',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (currentIndex + 1) / currentCards.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(widget.categoryColor),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          
          // Flashcard
          Expanded(
            child: GestureDetector(
              onPanStart: showDefinition ? (details) {
                setState(() {
                  _isDragging = true;
                });
              } : null,
              onPanUpdate: showDefinition ? (details) {
                setState(() {
                  _dragDistance = details.delta.dx;
                });
              } : null,
              onPanEnd: showDefinition ? (details) {
                setState(() {
                  _isDragging = false;
                  _dragDistance = 0.0;
                });
                
                if (details.velocity.pixelsPerSecond.dx > 500) {
                  _handleSwipe(true);
                } else if (details.velocity.pixelsPerSecond.dx < -500) {
                  _handleSwipe(false);
                }
              } : null,
              onTap: showDefinition ? null : _flipCard,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: _isDragging ? Offset(_dragDistance * 0.5, 0) : Offset.zero,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_flipAnimation.value * 3.14159),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _isDragging 
                              ? (_dragDistance > 0 ? Colors.green[50] : Colors.red[50])
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: _isDragging
                              ? Border.all(
                                  color: _dragDistance > 0 ? Colors.green : Colors.red,
                                  width: 2,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: _flipAnimation.value < 0.5
                            ? _buildWordSide()
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(3.14159),
                                child: _buildDefinitionSide(),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          // Instructions and Action Buttons
          if (!showDefinition) ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.touch_app, color: Colors.blue[600]),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tap the card to see the definition',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.swipe, color: Colors.amber[700]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Swipe left if you don\'t know, right if you remember',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.amber[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleSwipe(false),
                          icon: Icon(Icons.thumb_down, size: 18),
                          label: Text('Don\'t Know'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleSwipe(true),
                          icon: Icon(Icons.thumb_up, size: 18),
                          label: Text('Remember'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWordSide() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 60,
            color: widget.categoryColor,
          ),
          SizedBox(height: 30),
          Text(
            currentCards[currentIndex].word,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          Text(
            'Tap to see definition',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefinitionSide() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 60,
            color: Colors.orange,
          ),
          SizedBox(height: 20),
          Text(
            currentCards[currentIndex].word,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
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
              currentCards[currentIndex].definition,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCompleted() {
    double percentage = rememberedCount > 0 
        ? (rememberedCount / (rememberedCount + notRememberedCount) * 100) 
        : 0;
    
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
                  percentage >= 70 ? Icons.emoji_events : Icons.school,
                  size: 80,
                  color: percentage >= 70 ? Colors.amber : Colors.blue,
                ),
                SizedBox(height: 20),
                Text(
                  'Study Session Complete!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 40),
                        SizedBox(height: 8),
                        Text(
                          '$rememberedCount',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text('Remembered'),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.cancel, color: Colors.red, size: 40),
                        SizedBox(height: 8),
                        Text(
                          '$notRememberedCount',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text('Need Practice'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  '${percentage.toStringAsFixed(1)}% Mastery',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          if (notRememberedCards.isNotEmpty) ...[
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _studyAgain,
                icon: Icon(Icons.refresh),
                label: Text('Study Difficult Cards Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.home),
                  label: Text('Back Home'),
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
                  icon: Icon(Icons.replay),
                  label: Text('Start Over'),
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

// Keep your existing WordCard class or replace it with StudyCard
class WordCard {
  final String word;
  final String definition;

  WordCard({
    required this.word,
    required this.definition,
  });
}