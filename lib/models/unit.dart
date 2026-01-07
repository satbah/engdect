class Unit {
  final String unitId;
  final String title;
  final String level;
  final String description;
  final List<Exercise> exercises;
  final Settings settings;

  Unit({
    required this.unitId,
    required this.title,
    required this.level,
    required this.description,
    required this.exercises,
    required this.settings,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      unitId: json['unit_id'],
      title: json['title'],
      level: json['level'],
      description: json['description'],
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
      settings: Settings.fromJson(json['settings']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unit_id': unitId,
      'title': title,
      'level': level,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }
}

class Exercise {
  final int id;
  final String text;
  final String hint;
  final String difficulty;
  final String? japanese; // Optional Japanese translation

  Exercise({
    required this.id,
    required this.text,
    required this.hint,
    required this.difficulty,
    this.japanese,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      text: json['text'],
      hint: json['hint'],
      difficulty: json['difficulty'],
      japanese: json['japanese'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'hint': hint,
      'difficulty': difficulty,
      if (japanese != null) 'japanese': japanese,
    };
  }
}

class Settings {
  final String voice;
  final double speed;
  final int repeatAllowed;

  Settings({
    required this.voice,
    required this.speed,
    required this.repeatAllowed,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      voice: json['voice'],
      speed: json['speed'],
      repeatAllowed: json['repeat_allowed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voice': voice,
      'speed': speed,
      'repeat_allowed': repeatAllowed,
    };
  }
}