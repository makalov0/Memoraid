// models.dart - Create this file for your data models

class Category {
  final int id;
  final String name;
  final String icon;
  final String color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
    );
  }
}

class StudyCard {
  final int id;
  final int categoryId;
  final String word;
  final String definition;

  StudyCard({
    required this.id,
    required this.categoryId,
    required this.word,
    required this.definition,
  });

  factory StudyCard.fromJson(Map<String, dynamic> json) {
    return StudyCard(
      id: json['id'],
      categoryId: json['category_id'],
      word: json['word'],
      definition: json['definition'],
    );
  }
}

class UserProgress {
  final int id;
  final int userId;
  final int cardId;
  final bool remembered;
  final int studyCount;
  final DateTime lastStudied;

  UserProgress({
    required this.id,
    required this.userId,
    required this.cardId,
    required this.remembered,
    required this.studyCount,
    required this.lastStudied,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'],
      userId: json['user_id'],
      cardId: json['card_id'],
      remembered: json['remembered'] == 1,
      studyCount: json['study_count'],
      lastStudied: DateTime.parse(json['last_studied']),
    );
  }
}

class StudySession {
  final int id;
  final int userId;
  final int categoryId;
  final int totalCards;
  final int rememberedCount;
  final DateTime sessionDate;

  StudySession({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.totalCards,
    required this.rememberedCount,
    required this.sessionDate,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      totalCards: json['total_cards'],
      rememberedCount: json['remembered_count'],
      sessionDate: DateTime.parse(json['session_date']),
    );
  }
}