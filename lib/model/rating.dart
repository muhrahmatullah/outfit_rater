class Rating {
  final String name;
  final String description;
  final String personality;
  final String motivations;
  final String hiddenPotential;
  final int score;

  Rating({
    required this.name,
    required this.description,
    required this.personality,
    required this.motivations,
    required this.hiddenPotential,
    required this.score,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      name: json['name'],
      description: json['description'],
      personality: json['personality'],
      motivations: json['motivations'],
      hiddenPotential: json['hidden_potential'],
      score: json['score'],
    );
  }

  @override
  String toString() {
    return 'Rating(name: $name, description: $description, personality: $personality, motivations: $motivations, hiddenPotential: $hiddenPotential, score: $score)';
  }
}
