import 'dart:convert';
import 'package:http/http.dart' as http;

class LearningService {
  final String _baseUrl = 'https://api.naya.app/api/v1';
  
  Future<Map<String, dynamic>> getZombieCards() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/learning/zombie-card'),
        headers: {'Authorization': 'Bearer YOUR_TOKEN'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching zombie cards: $e');
    }
    
    return {};
  }
  
  Future<Map<String, dynamic>> submitQuiz(String cardId, int answerIndex) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/learning/quiz/submit'),
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cardId': cardId,
          'answerIndex': answerIndex,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error submitting quiz: $e');
    }
    
    return {'success': false};
  }
}
