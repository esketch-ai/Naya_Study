class CardModel {
  final String id;
  final String expression;
  final String meaning;
  
  CardModel({
    required this.id,
    required this.expression,
    required this.meaning,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] ?? '',
      expression: json['expression'] ?? '',
      meaning: json['meaning'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expression': expression,
      'meaning': meaning,
    };
  }
}
